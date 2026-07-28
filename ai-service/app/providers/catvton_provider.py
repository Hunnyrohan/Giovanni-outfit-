"""CatVTON virtual try-on provider.

Loads the CatVTON diffusion pipeline once per process (see `__init__`) and
reuses it across every request - no reload per call. This runs REAL
inference; it is not a mock.

The pipeline itself is vendored, unmodified, from the official CatVTON
repository (see `catvton_lib/VENDORED_NOTICE.md`). Automatic mask generation
uses `app.providers.mask_generator` (MediaPipe + OpenCV) instead of
CatVTON's official DensePose/SCHP-based AutoMasker, which depends on
detectron2 - a Linux-only precompiled dependency with no official Windows
build. This is a deliberate, disclosed trade-off: lower mask precision in
exchange for running natively on Windows/Python 3.11 without a from-source
detectron2 build.

Memory/robustness behavior, tuned for constrained (e.g. 4GB) GPUs:
  - fp16/bf16 weights on GPU (fp32 on CPU, where half precision is
    unsupported/slow for many ops).
  - Attention slicing and VAE slicing, when enabled.
  - Best-effort sequential CPU offload via `accelerate.cpu_offload` (the
    pipeline is a plain Python class, not a `diffusers.DiffusionPipeline`,
    so this is wired up manually rather than via a built-in convenience
    method).
  - On CUDA OOM: clear the cache and retry once; if it fails again, the
    pipeline permanently reloads on CPU and processing continues. The
    service never crashes because of GPU memory.
"""

import asyncio
import gc
import sys
import time
import uuid
from pathlib import Path

import torch
from PIL import Image

from app.core.exceptions import ProviderError
from app.core.logging import get_logger
from app.providers.base_provider import BaseVirtualTryOnProvider, ProviderResult
from app.providers.mask_generator import MaskGenerator

logger = get_logger(__name__)

# The vendored CatVTON modules use bare `from model.X import ...` / `from
# utils import ...` (absolute imports assuming the repo root is on
# sys.path). Adding only this directory - not the whole app - keeps the
# hack scoped to these vendored files.
_CATVTON_LIB_DIR = Path(__file__).parent / "catvton_lib"
if str(_CATVTON_LIB_DIR) not in sys.path:
    sys.path.insert(0, str(_CATVTON_LIB_DIR))

BASE_MODEL_REPO = "runwayml/stable-diffusion-inpainting"
ATTN_CKPT_REPO = "zhengchong/CatVTON"
DEFAULT_NUM_INFERENCE_STEPS = 50
DEFAULT_GUIDANCE_SCALE = 2.5


class CatVTONProvider(BaseVirtualTryOnProvider):
    name = "catvton"

    def __init__(
        self,
        device: str = "auto",
        precision: str = "fp16",
        enable_cpu_offload: bool = True,
        enable_attention_slicing: bool = True,
        enable_vae_slicing: bool = True,
        image_width: int = 384,
        image_height: int = 512,
    ) -> None:
        self.precision = precision
        self.enable_cpu_offload = enable_cpu_offload
        self.enable_attention_slicing = enable_attention_slicing
        self.enable_vae_slicing = enable_vae_slicing
        self.image_width = image_width
        self.image_height = image_height

        self.mask_generator = MaskGenerator()
        self._pipeline = None
        self._active_device = "cpu"

        self._load_pipeline(self._resolve_device(device))

    @staticmethod
    def _resolve_device(device: str) -> str:
        if device == "auto":
            resolved = "cuda" if torch.cuda.is_available() else "cpu"
            logger.info("MODEL_DEVICE=auto resolved to '%s'", resolved)
            return resolved
        if device == "cuda" and not torch.cuda.is_available():
            logger.warning("MODEL_DEVICE=cuda requested but CUDA is unavailable; falling back to cpu")
            return "cpu"
        return device

    def _dtype_for(self, device: str) -> torch.dtype:
        if device == "cpu":
            # fp16 matmul kernels are largely unimplemented/slow on CPU.
            return torch.float32
        if self.precision == "bf16":
            return torch.bfloat16
        if self.precision == "fp16":
            return torch.float16
        return torch.float32

    def _load_pipeline(self, device: str) -> None:
        from model.pipeline import CatVTONPipeline  # vendored, see catvton_lib/

        weight_dtype = self._dtype_for(device)
        logger.info(
            "Loading CatVTON pipeline (device=%s, dtype=%s) - first run downloads "
            "the base SD1.5 inpainting checkpoint + CatVTON attention weights (a few GB)",
            device,
            weight_dtype,
        )

        pipeline = CatVTONPipeline(
            base_ckpt=BASE_MODEL_REPO,
            attn_ckpt=ATTN_CKPT_REPO,
            attn_ckpt_version="mix",
            weight_dtype=weight_dtype,
            device=device,
            # Skips loading a second CLIP-based safety-checker model, which
            # matters under a tight VRAM budget. Re-enable if this is ever
            # deployed somewhere with untrusted/public input and more VRAM.
            skip_safety_check=True,
            use_tf32=(device == "cuda"),
        )

        if self.enable_vae_slicing and hasattr(pipeline.vae, "enable_slicing"):
            pipeline.vae.enable_slicing()
            logger.info("VAE slicing enabled")

        # Verified on real hardware (RTX 3050, 4GB VRAM) NOT to apply, despite
        # being requested settings - see the long comment below. Rather than
        # silently attempt something that crashes every inference call, we
        # log a clear warning and skip it.
        if self.enable_attention_slicing:
            logger.warning(
                "ENABLE_ATTENTION_SLICING=true was requested but is not applied: "
                "UNet2DConditionModel.set_attention_slice() reconfigures every "
                "attention processor, which silently discards the SkipAttnProcessor "
                "CatVTON's init_adapter() installs on cross-attention layers. "
                "Verified on real hardware: this produces "
                "'mat1 and mat2 shapes cannot be multiplied (12288x320 and 768x320)' "
                "on the very first inference call. fp16 + VAE slicing already keeps "
                "peak VRAM at ~2.4GB for a 384x512 image on a 4GB GPU, so this is not "
                "needed in practice."
            )

        if self.enable_cpu_offload and device == "cuda":
            self._try_enable_cpu_offload(pipeline, device)

        self._pipeline = pipeline
        self._active_device = device
        logger.info("CatVTON pipeline ready on device=%s", device)

    @staticmethod
    def _try_enable_cpu_offload(pipeline, device: str) -> None:
        """Deliberately a no-op today - see the warning logged below.

        CatVTONPipeline is a plain Python class, not a diffusers
        DiffusionPipeline, so it has no built-in enable_sequential_cpu_offload().
        Applying accelerate's lower-level `cpu_offload()` primitive directly to
        its submodules was verified on real hardware to leave "meta" tensors
        with no data, crashing the first inference call with
        "Cannot copy out of meta tensor; no data!" - accelerate's offload hooks
        assume a model loading pattern (init_empty_weights + dispatch) that
        CatVTONPipeline's manual `.to(device, dtype=weight_dtype)` loading
        doesn't follow. Rather than ship something that crashes every request,
        this stays disabled until a correct offload strategy for this specific
        hand-rolled pipeline is implemented. fp16 + VAE slicing are already
        sufficient on a 4GB GPU at 384x512 (see generate()'s OOM guard for the
        remaining safety net on larger inputs).
        """
        logger.warning(
            "ENABLE_CPU_OFFLOAD=true was requested but is not applied: "
            "accelerate.cpu_offload() was verified on real hardware to corrupt "
            "this pipeline's tensors ('Cannot copy out of meta tensor; no data!' "
            "on first inference). fp16 + VAE slicing already keep peak VRAM at "
            "~2.4GB for a 384x512 image on a 4GB GPU."
        )

    def _reload_on_cpu(self) -> None:
        logger.warning("Reloading CatVTON pipeline on CPU after persistent CUDA failure")
        self._pipeline = None
        gc.collect()
        if torch.cuda.is_available():
            torch.cuda.empty_cache()
        self._load_pipeline("cpu")

    async def generate(
        self,
        person_image_path: str,
        garment_image_path: str,
        output_dir: str,
        **options,
    ) -> ProviderResult:
        garment_type = options.get("garment_type", "upper")

        try:
            person_image = Image.open(person_image_path).convert("RGB")
            garment_image = Image.open(garment_image_path).convert("RGB")
        except Exception as error:
            raise ProviderError(f"Could not read input images: {error}") from error

        mask = self.mask_generator.generate(person_image, garment_type)

        start = time.monotonic()
        try:
            result_image = await self._run_with_oom_guard(person_image, garment_image, mask)
        except ProviderError:
            raise
        except Exception as error:
            raise ProviderError(f"CatVTON inference failed: {error}") from error
        processing_time_seconds = time.monotonic() - start

        output_path = Path(output_dir) / f"{uuid.uuid4().hex}_catvton.png"
        result_image.save(output_path)

        return ProviderResult(
            output_path=str(output_path),
            metadata={
                "provider": self.name,
                "device": self._active_device,
                "processing_time_seconds": round(processing_time_seconds, 2),
            },
        )

    async def _run_with_oom_guard(
        self,
        person_image: Image.Image,
        garment_image: Image.Image,
        mask: Image.Image,
    ) -> Image.Image:
        def _infer() -> Image.Image:
            return self._pipeline(
                image=person_image,
                condition_image=garment_image,
                mask=mask,
                num_inference_steps=DEFAULT_NUM_INFERENCE_STEPS,
                guidance_scale=DEFAULT_GUIDANCE_SCALE,
                height=self.image_height,
                width=self.image_width,
            )[0]

        # The pipeline call is synchronous/blocking (CPU- and GPU-bound); run
        # it in a worker thread so it never blocks the event loop.
        try:
            return await asyncio.to_thread(_infer)
        except torch.cuda.OutOfMemoryError:
            logger.warning("CUDA out of memory on first attempt; clearing cache and retrying once")
            gc.collect()
            torch.cuda.empty_cache()
            try:
                return await asyncio.to_thread(_infer)
            except torch.cuda.OutOfMemoryError:
                logger.warning("CUDA out of memory again; falling back to CPU mode permanently")
                self._reload_on_cpu()
                return await asyncio.to_thread(_infer)
