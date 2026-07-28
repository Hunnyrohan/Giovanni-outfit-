import shutil
from pathlib import Path

import pytest
from fastapi.testclient import TestClient

from app.api import dependencies
from main import app


@pytest.fixture(autouse=True)
def _isolated_storage(tmp_path, monkeypatch):
    """Points UPLOAD_DIR/OUTPUT_DIR at a temp directory and clears cached
    singletons so every test starts with a clean job repository."""
    upload_dir = tmp_path / "uploads"
    output_dir = tmp_path / "outputs"
    upload_dir.mkdir()
    output_dir.mkdir()

    monkeypatch.setenv("UPLOAD_DIR", str(upload_dir))
    monkeypatch.setenv("OUTPUT_DIR", str(output_dir))
    # These fast unit tests exercise the job pipeline/API contract and must
    # stay quick and deterministic - they intentionally run against the mock
    # LeffaProvider rather than downloading/running the real CatVTON model.
    # Real-inference verification lives in tests/test_catvton_real_inference.py
    # (opt-in, not part of the default suite - see its module docstring).
    monkeypatch.setenv("MODEL_PROVIDER", "leffa")

    from app.config.settings import get_settings

    get_settings.cache_clear()
    dependencies.get_job_repository.cache_clear()
    dependencies.get_provider.cache_clear()
    dependencies.get_virtual_tryon_service.cache_clear()

    yield

    shutil.rmtree(tmp_path, ignore_errors=True)


@pytest.fixture
def client():
    # Must be used as a context manager: this keeps a single persistent
    # event loop alive for the fixture's lifetime, so background
    # asyncio.create_task() work (the async job processing loop) keeps
    # running between separate polling requests in a test.
    with TestClient(app) as test_client:
        yield test_client


@pytest.fixture
def sample_image_bytes() -> bytes:
    # Minimal valid 1x1 PNG.
    return bytes.fromhex(
        "89504e470d0a1a0a0000000d49484452000000010000000108020000009077"
        "53de0000000c4944415478da6360000000020001e221bc330000000049454e"
        "44ae426082"
    )
