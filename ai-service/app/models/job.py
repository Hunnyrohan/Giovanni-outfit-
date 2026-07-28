"""Domain model for an asynchronous Virtual Try-On job.

This is the internal representation used by the service/repository layer -
distinct from the Pydantic request/response schemas in `app/schemas`, which
shape what crosses the HTTP boundary.
"""

from dataclasses import dataclass, field
from datetime import datetime, timezone
from enum import Enum


class JobStatus(str, Enum):
    PENDING = "PENDING"
    PROCESSING = "PROCESSING"
    COMPLETED = "COMPLETED"
    FAILED = "FAILED"


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


@dataclass
class Job:
    id: str
    person_image_path: str
    garment_image_path: str
    status: JobStatus = JobStatus.PENDING
    result_path: str | None = None
    error_message: str | None = None
    provider_name: str = ""
    processing_time_seconds: float | None = None
    created_at: datetime = field(default_factory=_utcnow)
    updated_at: datetime = field(default_factory=_utcnow)

    def mark_processing(self) -> None:
        self.status = JobStatus.PROCESSING
        self.updated_at = _utcnow()

    def mark_completed(self, result_path: str, processing_time_seconds: float | None = None) -> None:
        self.status = JobStatus.COMPLETED
        self.result_path = result_path
        self.processing_time_seconds = processing_time_seconds
        self.updated_at = _utcnow()

    def mark_failed(self, error_message: str) -> None:
        self.status = JobStatus.FAILED
        self.error_message = error_message
        self.updated_at = _utcnow()
