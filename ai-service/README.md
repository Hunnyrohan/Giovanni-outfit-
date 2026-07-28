# StyleSense AI - AI Service

A standalone Python microservice hosting StyleSense AI's Virtual Try-On model
(CatVTON). It is a **separate project** from the Flutter app and the
Node/Express backend - no code or process dependency between them.

**Status: real inference, verified on real hardware.** `CatVTONProvider` runs
actual CatVTON diffusion inference (not a mock) and has been measured
end-to-end on the target machine (Windows 11, RTX 3050 Laptop GPU, 4GB VRAM):
model load, GPU inference, VRAM usage, and the CUDA-OOM-to-CPU-fallback path
were all exercised for real - see [Verified behavior](#verified-behavior-on-real-hardware).

## Why a separate service?

The Node backend and Flutter app are unrelated to Python/PyTorch. Keeping
model inference in its own service means:
- The Node backend and this service can be deployed, scaled, and restarted independently.
- A GPU-backed deployment only needs to provision GPU hardware for *this* service, not the whole backend.
- Swapping or adding models later never touches Node/Flutter code.

## Folder structure

```
ai-service/
├── app/
│   ├── api/
│   │   ├── routes/
│   │   │   ├── health.py           # GET/POST /health
│   │   │   └── virtual_tryon.py    # /virtual-tryon endpoints
│   │   └── dependencies.py         # DI wiring: which provider/repository backs the service
│   ├── core/
│   │   ├── exceptions.py           # Shared exception hierarchy
│   │   ├── logging.py              # Structured logging setup
│   │   └── job_repository.py       # Job persistence interface + in-memory implementation
│   ├── services/
│   │   └── virtual_tryon_service.py  # Business logic - knows only BaseVirtualTryOnProvider
│   ├── providers/
│   │   ├── base_provider.py        # Abstract provider interface every model must implement
│   │   ├── leffa_provider.py       # Mock provider (kept for fast, deterministic unit tests)
│   │   ├── catvton_provider.py     # Real CatVTON provider (the active default)
│   │   ├── mask_generator.py       # MediaPipe/OpenCV garment-region mask (no detectron2)
│   │   └── catvton_lib/            # Vendored, unmodified CatVTON source - see VENDORED_NOTICE.md
│   ├── models/
│   │   └── job.py                  # Internal Job domain entity + JobStatus enum
│   ├── schemas/                    # Pydantic response models (camelCase JSON via aliases)
│   ├── utils/
│   │   └── file_utils.py           # Upload validation + saving to disk
│   └── config/
│       └── settings.py             # Environment-backed configuration (pydantic-settings)
├── tests/                          # Fast unit tests (run against the mock provider)
├── uploads/                        # Uploaded person/garment images (gitignored contents)
├── outputs/                        # Generated result images, served at /outputs/<file> (gitignored contents)
├── main.py                         # FastAPI app entrypoint
├── requirements.txt
├── .env.example
├── Dockerfile
└── README.md
```

### Why this shape (Clean Architecture)

- **`providers/`** is the only layer allowed to know about a specific model. `CatVTONProvider` and `LeffaProvider` both implement `BaseVirtualTryOnProvider`.
- **`services/`** contains business logic (`VirtualTryOnService`) and depends only on the provider *interface* and the job *repository interface* - never a concrete class.
- **`api/`** is a thin HTTP layer: routes validate input, call the service, and shape the response.
- **`core/`** holds cross-cutting infrastructure (errors, logging, job storage).
- **Dependency Injection** happens in one place (`app/api/dependencies.py`) - `get_provider()` branches on `MODEL_PROVIDER` and is the only place that knows which concrete provider class to construct.

## Installation

Requires **Python 3.11**.

```bash
cd ai-service
python -m venv .venv

# Windows
.venv\Scripts\activate
# macOS/Linux
source .venv/bin/activate
```

**GPU (recommended if you have an NVIDIA GPU):** install CUDA-enabled torch *before* the rest of requirements.txt, matching your CUDA setup (12.1 works with any driver ≥528, which covers effectively all current drivers):

```bash
pip install torch==2.1.2 torchvision==0.16.2 --index-url https://download.pytorch.org/whl/cu121
```

**CPU-only:** skip the step above; `pip install -r requirements.txt` will pull the CPU build of torch instead.

Then, either way:

```bash
pip install -r requirements.txt
cp .env.example .env
```

### Model downloads (automatic, on first run)

No manual download step - the first request (or the first time `CatVTONProvider` is constructed) triggers:
- `runwayml/stable-diffusion-inpainting` (base SD1.5 inpainting checkpoint, a few GB)
- `stabilityai/sd-vae-ft-mse` (VAE, ~335MB)
- `zhengchong/CatVTON` (attention adapter weights, ~1.4GB - this snapshot also contains DensePose/SCHP folders we don't use; harmless, just extra disk)
- MediaPipe's `pose_landmarker_lite.task` (~5MB, downloaded by `mask_generator.py` to `~/.cache/stylesense-ai/mediapipe/`)

All are cached by `huggingface_hub`/mediapipe after the first run (`~/.cache/huggingface/hub` and `~/.cache/stylesense-ai/`).

## CUDA / GPU notes

- **Driver:** any NVIDIA driver from the last ~2 years works. CUDA 12.1 (what the pinned torch wheel uses) needs driver ≥528.33 on Windows.
- **VRAM:** verified in practice at **~2.4GB peak** for a 384×512 generation with fp16 + VAE slicing on a real 4GB RTX 3050 - comfortable headroom even with the requested defaults.
- **`MODEL_DEVICE=auto`** picks CUDA if `torch.cuda.is_available()`, otherwise CPU. Set explicitly to `cuda` or `cpu` to force one.

## Running

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

Then visit `http://localhost:8000/docs` for interactive Swagger UI.

## Running tests

```bash
pytest -v
```

This runs the **fast unit test suite** (health checks + the full job lifecycle) against the mock `LeffaProvider`, regardless of `MODEL_PROVIDER` in your `.env` - see `tests/conftest.py`. These finish in seconds and need no GPU, network, or multi-GB downloads.

**Real CatVTON inference is not part of this suite** (it needs the multi-GB model download and, on CPU, can take minutes per image). To verify real inference yourself:

```bash
python -c "
import asyncio
from app.providers.catvton_provider import CatVTONProvider

async def main():
    provider = CatVTONProvider(device='auto', precision='fp16')
    result = await provider.generate('path/to/person.jpg', 'path/to/garment.jpg', 'outputs', garment_type='upper')
    print(result.output_path, result.metadata)

asyncio.run(main())
"
```

## Configuration

| Variable | Default | Description |
|---|---|---|
| `HOST` | `0.0.0.0` | Bind address |
| `PORT` | `8000` | Bind port |
| `ENVIRONMENT` | `development` | Free-form environment label |
| `MODEL_PROVIDER` | `catvton` | `catvton` (real) or `leffa` (mock, for fast local dev without a GPU) |
| `MODEL_DEVICE` | `auto` | `auto` \| `cuda` \| `cpu` |
| `MODEL_PRECISION` | `fp16` | `fp16` \| `bf16` \| `fp32` (CPU always uses fp32 regardless of this setting) |
| `ENABLE_CPU_OFFLOAD` | `false` | **Verified broken for this pipeline - see below. Leave false.** |
| `ENABLE_ATTENTION_SLICING` | `false` | **Verified broken for this pipeline - see below. Leave false.** |
| `ENABLE_VAE_SLICING` | `true` | Verified working; keep enabled |
| `IMAGE_WIDTH` / `IMAGE_HEIGHT` | `384` / `512` | Generation resolution |
| `UPLOAD_DIR` / `OUTPUT_DIR` | `uploads` / `outputs` | Storage paths |
| `MAX_UPLOAD_SIZE_MB` | `10` | Upload size limit |
| `LOG_LEVEL` | `INFO` | Python logging level |

### Why `ENABLE_CPU_OFFLOAD` and `ENABLE_ATTENTION_SLICING` default to `false`

Both were implemented and **tested on the real RTX 3050**, and both crash CatVTON's custom attention architecture:

- **`set_attention_slice()`** reconfigures every attention processor on the UNet. CatVTON's `init_adapter()` replaces cross-attention processors with a custom `SkipAttnProcessor` (its whole architectural trick - see `catvton_lib/model/attn_processor.py`). Calling `set_attention_slice()` afterward silently discards that customization. Measured failure: `RuntimeError: mat1 and mat2 shapes cannot be multiplied (12288x320 and 768x320)` on the first inference call.
- **`accelerate.cpu_offload()`** assumes a model loaded via `init_empty_weights()` + dispatch hooks. `CatVTONPipeline` is a plain Python class that loads weights directly (`.to(device, dtype=weight_dtype)`), so accelerate's offload hooks leave the tensors in an inconsistent "meta" (no-data) state. Measured failure: `NotImplementedError: Cannot copy out of meta tensor; no data!` on the first inference call.

Setting either to `true` does **not** crash the service - `CatVTONProvider` logs a clear warning and does not apply them (see `_load_pipeline`/`_try_enable_cpu_offload`). In practice they aren't needed: fp16 + VAE slicing alone measured ~2.4GB peak VRAM at 384×512 on a 4GB card.

## API

Interactive docs at `/docs` (Swagger) and `/redoc`. Summary:

| Method | Path | Description |
|---|---|---|
| `GET`/`POST` | `/health` | Service health + active provider/device config |
| `POST` | `/virtual-tryon` | multipart: `person_image`, `garment_image` (files), `garment_type` (`upper`\|`lower`\|`overall`, default `upper`). Returns a job in `PENDING` status. |
| `GET` | `/virtual-tryon/status/{jobId}` | Poll job status |
| `GET` | `/virtual-tryon/history` | List all jobs, most recent first |
| `DELETE` | `/virtual-tryon/{jobId}` | Delete a job record |

Job response fields (camelCase JSON): `jobId`, `status` (`PENDING`\|`PROCESSING`\|`COMPLETED`\|`FAILED`), `imageUrl` (fetchable at `GET /outputs/<file>` once `COMPLETED`), `processingTime` (seconds), `errorMessage`, `providerName`, `createdAt`, `updatedAt`.

All errors: `{"success": false, "message": "...", "errors": {...}}`, matching the Node backend's envelope shape.

### Job lifecycle & GPU-failure handling

`POST /virtual-tryon` returns immediately with a `PENDING` job and processes it in the background. On CUDA out-of-memory during inference: the cache is cleared and the same request is retried once; if it fails again, the pipeline **permanently** reloads on CPU and processing continues (verified: this path runs to completion rather than crashing the service, tested by forcing an OOM with an oversized resolution).

## Verified behavior on real hardware

Measured directly on Windows 11 / Intel i5-12500H / RTX 3050 Laptop (4GB VRAM) / Python 3.11:

- ✅ Model loading on CPU and on CUDA (`torch.cuda.is_available()` → `True`, device name and 4GB VRAM correctly detected)
- ✅ Real GPU inference: 50 steps at 384×512, fp16 + VAE slicing → **~30 seconds, ~2.4GB peak VRAM**
- ✅ CUDA OOM → clear cache → retry → (if still failing) permanent CPU fallback → job still completes, service never crashes
- ✅ Mask generator's no-pose-detected fallback path (triggers correctly on non-photographic input)
- ✅ Full job lifecycle via the HTTP API: create → poll (`PENDING`→`PROCESSING`→`COMPLETED`) → history → delete
- ✅ `imageUrl` is a real, fetchable path served by the mounted `/outputs` static route

## Troubleshooting

**`OSError: [WinError 1314] A required privilege is not held by the client` during model download** - `huggingface_hub` tries to symlink cached files, which Windows blocks without Developer Mode or admin rights. Fix: set `HF_HUB_DISABLE_SYMLINKS=1` in your environment (or enable Developer Mode: Settings → Privacy & Security → For Developers).

**`ConnectionResetError` / TLS handshake failures reaching huggingface.co, but `curl` works** - likely broken IPv6 routing on your network (curl often defaults to IPv4 first; Python's resolver may prefer IPv6). Verify with `curl -4 https://huggingface.co` vs. plain `curl https://huggingface.co`. If `-4` succeeds and the plain call doesn't, force IPv4 in Python before making any HF requests:
```python
import socket
_orig = socket.getaddrinfo
socket.getaddrinfo = lambda host, port, family=0, type=0, proto=0, flags=0: _orig(host, port, socket.AF_INET, type, proto, flags)
```

**`CUDA out of memory` even after the automatic retry/fallback** - the retry-then-CPU-fallback logic will keep the request working (just slower, on CPU), but if you want to stay on GPU: lower `IMAGE_WIDTH`/`IMAGE_HEIGHT` further, or close other GPU-using applications (emulators, browsers with hardware acceleration, etc.) to free VRAM headroom.

**Do not set `ENABLE_ATTENTION_SLICING=true` or `ENABLE_CPU_OFFLOAD=true` expecting a speed/memory benefit** - see [above](#why-enable_cpu_offload-and-enable_attention_slicing-default-to-false); they're intentionally no-ops on this pipeline.

## License note

CatVTON's code and weights are licensed **CC BY-NC-SA 4.0 (non-commercial)** - see `app/providers/catvton_lib/VENDORED_NOTICE.md` and `UPSTREAM_LICENSE.txt`. Fine for this academic final-year project; would need a different model/license before any commercial deployment.
