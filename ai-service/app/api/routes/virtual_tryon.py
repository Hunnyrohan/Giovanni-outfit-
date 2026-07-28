from typing import Literal

from fastapi import APIRouter, Depends, File, Form, UploadFile

from app.api.dependencies import get_virtual_tryon_service
from app.config.settings import get_settings
from app.schemas.virtual_tryon_schema import HistoryResponse, JobResponse
from app.services.virtual_tryon_service import VirtualTryOnService
from app.utils.file_utils import save_upload

router = APIRouter(prefix="/virtual-tryon", tags=["Virtual Try-On"])


@router.post("", response_model=JobResponse, status_code=202)
async def create_virtual_tryon_job(
    person_image: UploadFile = File(...),
    garment_image: UploadFile = File(...),
    garment_type: Literal["upper", "upper_sleeveless", "lower", "overall"] = Form("upper"),
    service: VirtualTryOnService = Depends(get_virtual_tryon_service),
) -> JobResponse:
    settings = get_settings()

    person_path = await save_upload(person_image, settings.UPLOAD_DIR, settings.MAX_UPLOAD_SIZE_MB)
    garment_path = await save_upload(garment_image, settings.UPLOAD_DIR, settings.MAX_UPLOAD_SIZE_MB)

    job = await service.create_job(person_path, garment_path, garment_type=garment_type)

    return JobResponse.from_job(job)


@router.get("/status/{job_id}", response_model=JobResponse)
async def get_job_status(
    job_id: str,
    service: VirtualTryOnService = Depends(get_virtual_tryon_service),
) -> JobResponse:
    job = await service.get_status(job_id)
    return JobResponse.from_job(job)


@router.get("/history", response_model=HistoryResponse)
async def get_job_history(
    service: VirtualTryOnService = Depends(get_virtual_tryon_service),
) -> HistoryResponse:
    jobs = await service.list_history()
    return HistoryResponse(jobs=[JobResponse.from_job(job) for job in jobs], total=len(jobs))


@router.delete("/{job_id}", status_code=204)
async def delete_job(
    job_id: str,
    service: VirtualTryOnService = Depends(get_virtual_tryon_service),
) -> None:
    await service.delete_job(job_id)
