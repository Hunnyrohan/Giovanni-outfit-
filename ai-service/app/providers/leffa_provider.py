"""Leffa virtual try-on provider.

This is a MOCK implementation. It defines the shape the real integration
will take (constructor reads MODEL_NAME/MODEL_DEVICE, `generate()` matches
the provider interface) but does NOT install the `leffa` package, download
any weights, or run inference - per the current phase of this project.

To wire up real inference later:
  1. Add the Leffa dependencies to requirements.txt.
  2. Load the model/weights once in `__init__` (guarded by MODEL_DEVICE).
  3. Replace the body of `generate()` with an actual forward pass, keeping
     the same signature and return type so `VirtualTryOnService` and the
     API layer require no changes.
"""

import asyncio
import shutil
import time
import uuid
from pathlib import Path

from app.core.exceptions import ProviderError
from app.core.logging import get_logger
from app.providers.base_provider import BaseVirtualTryOnProvider, ProviderResult

logger = get_logger(__name__)


class LeffaProvider(BaseVirtualTryOnProvider):
    name = "leffa"

    def __init__(self, device: str = "cpu") -> None:
        self.device = device
        logger.info("LeffaProvider initialized in MOCK mode (device=%s)", device)

    async def generate(
        self,
        person_image_path: str,
        garment_image_path: str,
        output_dir: str,
        **options,
    ) -> ProviderResult:
        if not Path(person_image_path).exists():
            raise ProviderError(
                "Person image could not be found for inference",
                {"personImagePath": person_image_path},
            )

        if not Path(garment_image_path).exists():
            raise ProviderError(
                "Garment image could not be found for inference",
                {"garmentImagePath": garment_image_path},
            )

        # Simulate model latency without doing any real inference.
        start = time.monotonic()
        await asyncio.sleep(1)

        try:
            output_path = Path(output_dir) / f"{uuid.uuid4().hex}_mock_result.png"
            # Stand in for a generated image so the job pipeline is fully
            # exercisable end-to-end; replace with real model output later.
            shutil.copyfile(person_image_path, output_path)
        except OSError as error:
            raise ProviderError(f"Failed to write mock provider output: {error}") from error

        return ProviderResult(
            output_path=str(output_path),
            metadata={
                "mock": True,
                "provider": self.name,
                "device": self.device,
                "processing_time_seconds": round(time.monotonic() - start, 2),
                **options,
            },
        )
