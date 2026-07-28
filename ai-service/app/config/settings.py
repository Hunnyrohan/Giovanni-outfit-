"""Application configuration, sourced from environment variables / .env file."""

from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Central configuration for the AI Service.

    All values have safe local-development defaults so the service boots
    without a .env file; override via environment variables or .env in
    staging/production.
    """

    # Server
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    ENVIRONMENT: str = "development"

    # Active model provider
    MODEL_PROVIDER: str = "catvton"
    MODEL_DEVICE: str = "auto"  # "auto" | "cuda" | "cpu" - "auto" picks cuda if available
    MODEL_PRECISION: str = "fp16"  # "fp16" | "bf16" | "fp32" (ignored on CPU, always fp32 there)

    # Memory optimization (tuned for constrained/low-VRAM GPUs).
    # ENABLE_CPU_OFFLOAD and ENABLE_ATTENTION_SLICING default to False: both
    # were verified on real RTX 3050 (4GB) hardware to crash CatVTON's custom
    # attention architecture (see app/providers/catvton_provider.py for the
    # exact errors). Setting them to true does not raise an error but is
    # logged and NOT applied - see CatVTONProvider._load_pipeline. fp16 +
    # VAE slicing alone measured ~2.4GB peak VRAM at 384x512 on that GPU.
    ENABLE_CPU_OFFLOAD: bool = False
    ENABLE_ATTENTION_SLICING: bool = False
    ENABLE_VAE_SLICING: bool = True
    IMAGE_WIDTH: int = 384
    IMAGE_HEIGHT: int = 512

    # Storage
    UPLOAD_DIR: str = "uploads"
    OUTPUT_DIR: str = "outputs"
    MAX_UPLOAD_SIZE_MB: int = 10

    # Logging
    LOG_LEVEL: str = "INFO"

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")


@lru_cache
def get_settings() -> Settings:
    """Returns a cached Settings instance (env is only read once per process)."""
    return Settings()
