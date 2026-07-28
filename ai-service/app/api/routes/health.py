from datetime import datetime, timezone

from fastapi import APIRouter

from app.config.settings import get_settings
from app.schemas.health_schema import HealthResponse

router = APIRouter(tags=["Health"])


def _health_response() -> HealthResponse:
    settings = get_settings()
    return HealthResponse(
        model_name=settings.MODEL_PROVIDER,
        model_device=settings.MODEL_DEVICE,
        timestamp=datetime.now(timezone.utc),
    )


@router.get("/health", response_model=HealthResponse)
async def health_get() -> HealthResponse:
    return _health_response()


@router.post("/health", response_model=HealthResponse)
async def health_post() -> HealthResponse:
    """POST variant kept for monitoring tools that only support POST checks."""
    return _health_response()
