"""Dependency injection wiring for FastAPI routes.

This is the single place that decides which concrete provider and
repository back the service - everything else (routes, service, provider
interface) is wired together here and nowhere else.
"""

from functools import lru_cache

from app.config.settings import get_settings
from app.core.job_repository import InMemoryJobRepository, JobRepository
from app.providers.base_provider import BaseVirtualTryOnProvider
from app.providers.leffa_provider import LeffaProvider
from app.services.virtual_tryon_service import VirtualTryOnService


@lru_cache
def get_job_repository() -> JobRepository:
    return InMemoryJobRepository()


@lru_cache
def get_provider() -> BaseVirtualTryOnProvider:
    settings = get_settings()

    # MODEL_PROVIDER selects the active provider. Adding a new model later
    # means adding a branch here (and a new provider class) - nothing else
    # in the service/API layers changes.
    if settings.MODEL_PROVIDER == "catvton":
        from app.providers.catvton_provider import CatVTONProvider

        return CatVTONProvider(
            device=settings.MODEL_DEVICE,
            precision=settings.MODEL_PRECISION,
            enable_cpu_offload=settings.ENABLE_CPU_OFFLOAD,
            enable_attention_slicing=settings.ENABLE_ATTENTION_SLICING,
            enable_vae_slicing=settings.ENABLE_VAE_SLICING,
            image_width=settings.IMAGE_WIDTH,
            image_height=settings.IMAGE_HEIGHT,
        )

    if settings.MODEL_PROVIDER == "leffa":
        return LeffaProvider(device=settings.MODEL_DEVICE)

    raise ValueError(f"Unknown MODEL_PROVIDER '{settings.MODEL_PROVIDER}'")


@lru_cache
def get_virtual_tryon_service() -> VirtualTryOnService:
    settings = get_settings()
    return VirtualTryOnService(
        provider=get_provider(),
        job_repository=get_job_repository(),
        output_dir=settings.OUTPUT_DIR,
    )
