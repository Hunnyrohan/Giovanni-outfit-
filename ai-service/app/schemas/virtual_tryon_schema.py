from datetime import datetime
from pathlib import PurePath

from pydantic import BaseModel, ConfigDict, Field

from app.models.job import JobStatus


def _to_image_url(result_path: str | None) -> str | None:
    if not result_path:
        return None
    return f"/outputs/{PurePath(result_path).name}"


class JobResponse(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    job_id: str = Field(alias="jobId")
    status: JobStatus
    image_url: str | None = Field(default=None, alias="imageUrl")
    processing_time: float | None = Field(default=None, alias="processingTime")
    error_message: str | None = Field(default=None, alias="errorMessage")
    provider_name: str = Field(alias="providerName")
    created_at: datetime = Field(alias="createdAt")
    updated_at: datetime = Field(alias="updatedAt")

    @classmethod
    def from_job(cls, job) -> "JobResponse":
        return cls(
            job_id=job.id,
            status=job.status,
            image_url=_to_image_url(job.result_path),
            processing_time=job.processing_time_seconds,
            error_message=job.error_message,
            provider_name=job.provider_name,
            created_at=job.created_at,
            updated_at=job.updated_at,
        )


class HistoryResponse(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    jobs: list[JobResponse]
    total: int


class ErrorResponse(BaseModel):
    success: bool = False
    message: str
    errors: dict = {}
