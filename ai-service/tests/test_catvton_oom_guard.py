"""Deterministic, fully-mocked test of CatVTONProvider's CUDA-OOM handling.

This does NOT load the real model or need a GPU - it verifies the control
flow itself (clear cache -> retry once -> permanent CPU fallback -> never
raise) by injecting a fake pipeline callable. The real end-to-end behavior
(genuine CUDA OOM on an oversized resolution, falling back to a real CPU
reload) was separately verified manually against the actual RTX 3050 - see
README.md's "Verified behavior on real hardware" section.
"""

from unittest.mock import MagicMock, patch

import pytest
import torch
from PIL import Image

from app.providers.catvton_provider import CatVTONProvider


def _make_provider_without_loading() -> CatVTONProvider:
    """Builds a CatVTONProvider without running its real __init__ (which
    would load actual model weights), so we can drive _run_with_oom_guard
    in isolation."""
    provider = CatVTONProvider.__new__(CatVTONProvider)
    provider.precision = "fp16"
    provider.enable_cpu_offload = False
    provider.enable_attention_slicing = False
    provider.enable_vae_slicing = True
    provider.image_width = 384
    provider.image_height = 512
    provider._active_device = "cuda"
    return provider


@pytest.mark.asyncio
async def test_oom_then_success_on_retry():
    provider = _make_provider_without_loading()
    fake_image = Image.new("RGB", (384, 512))

    call_count = {"n": 0}

    def fake_pipeline(**kwargs):
        call_count["n"] += 1
        if call_count["n"] == 1:
            raise torch.cuda.OutOfMemoryError("simulated OOM")
        return [fake_image]

    provider._pipeline = fake_pipeline

    with patch("torch.cuda.empty_cache"), patch("torch.cuda.is_available", return_value=True):
        result = await provider._run_with_oom_guard(fake_image, fake_image, fake_image)

    assert result is fake_image
    assert call_count["n"] == 2  # first attempt OOM'd, retry succeeded


@pytest.mark.asyncio
async def test_oom_twice_falls_back_to_cpu_permanently():
    provider = _make_provider_without_loading()
    fake_image = Image.new("RGB", (384, 512))

    call_count = {"n": 0}

    def fake_pipeline(**kwargs):
        call_count["n"] += 1
        if call_count["n"] <= 2:
            raise torch.cuda.OutOfMemoryError("simulated OOM")
        return [fake_image]

    provider._pipeline = fake_pipeline

    def fake_reload_on_cpu():
        # Stands in for the real reload (which would load actual weights on
        # CPU); just prove it's invoked and that it flips the active device.
        provider._active_device = "cpu"

    with patch("torch.cuda.empty_cache"), patch("torch.cuda.is_available", return_value=True):
        provider._reload_on_cpu = MagicMock(side_effect=fake_reload_on_cpu)
        result = await provider._run_with_oom_guard(fake_image, fake_image, fake_image)

    assert result is fake_image
    assert call_count["n"] == 3  # first attempt + one retry OOM'd, third (post-fallback) succeeded
    provider._reload_on_cpu.assert_called_once()
    assert provider._active_device == "cpu"


@pytest.mark.asyncio
async def test_non_oom_errors_are_not_retried():
    """A non-OOM error (e.g. a real bug) must propagate immediately, not be
    silently swallowed by the OOM-specific retry logic."""
    provider = _make_provider_without_loading()
    fake_image = Image.new("RGB", (384, 512))

    def fake_pipeline(**kwargs):
        raise ValueError("not an OOM - a real bug")

    provider._pipeline = fake_pipeline

    with pytest.raises(ValueError, match="not an OOM"):
        await provider._run_with_oom_guard(fake_image, fake_image, fake_image)
