"""AI Service entrypoint.

Run with:
    uvicorn main:app --host 0.0.0.0 --port 8000 --reload
"""

from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles

from app.core.logging import get_logger, setup_logging
from app.core.network_fixes import apply_network_fixes

setup_logging()
apply_network_fixes()  # must run before any huggingface_hub/requests call

from app.api.routes import health, virtual_tryon  # noqa: E402
from app.config.settings import get_settings  # noqa: E402
from app.core.exceptions import AIServiceError  # noqa: E402
from app.utils.file_utils import ensure_dir  # noqa: E402

logger = get_logger(__name__)
settings = get_settings()


@asynccontextmanager
async def lifespan(_: FastAPI):
    ensure_dir(settings.UPLOAD_DIR)
    ensure_dir(settings.OUTPUT_DIR)
    logger.info(
        "AI Service starting | provider=%s device=%s precision=%s upload_dir=%s output_dir=%s",
        settings.MODEL_PROVIDER,
        settings.MODEL_DEVICE,
        settings.MODEL_PRECISION,
        settings.UPLOAD_DIR,
        settings.OUTPUT_DIR,
    )
    yield
    logger.info("AI Service shutting down")


app = FastAPI(
    title="StyleSense AI - AI Service",
    description=(
        "Standalone AI inference service for StyleSense AI. Hosts a real "
        "Virtual Try-On pipeline (CatVTON) behind a provider abstraction, "
        "designed so additional models can be added without changing API "
        "or business logic."
    ),
    version="0.2.0",
    lifespan=lifespan,
)

# Serves generated result images so job responses' imageUrl is a real,
# fetchable path (e.g. "/outputs/<file>.png") rather than a bare filesystem path.
app.mount("/outputs", StaticFiles(directory=ensure_dir(settings.OUTPUT_DIR)), name="outputs")


@app.exception_handler(AIServiceError)
async def ai_service_error_handler(request: Request, exc: AIServiceError) -> JSONResponse:
    logger.warning("%s: %s | path=%s", type(exc).__name__, exc.message, request.url.path)
    return JSONResponse(
        status_code=exc.status_code,
        content={"success": False, "message": exc.message, "errors": exc.errors},
    )


app.include_router(health.router)
app.include_router(virtual_tryon.router)
