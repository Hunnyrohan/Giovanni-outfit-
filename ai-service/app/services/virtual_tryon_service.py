"""Virtual Try-On business logic.

This service is intentionally provider-agnostic: it only ever calls
`BaseVirtualTryOnProvider.generate(...)`. It has no knowledge of Leffa,
CatVTON, IDM-VTON, or any other specific model, so the active model can be
swapped in DI wiring alone.
"""

import asyncio
import uuid

from app.core.exceptions import ImageError
from app.core.job_repository import JobRepository
from app.core.logging import get_logger
from app.models.job import Job, JobStatus
from app.providers.base_provider import BaseVirtualTryOnProvider

logger = get_logger(__name__)


class VirtualTryOnService:
    def __init__(
        self,
        provider: BaseVirtualTryOnProvider,
        job_repository: JobRepository,
        output_dir: str,
    ) -> None:
        self._provider = provider
        self._jobs = job_repository
        self._output_dir = output_dir

    async def create_job(self, person_image_path: str, garment_image_path: str, **options) -> Job:
        if not person_image_path or not garment_image_path:
            raise ImageError("Both a person image and a garment image are required")

        job = Job(
            id=uuid.uuid4().hex,
            person_image_path=person_image_path,
            garment_image_path=garment_image_path,
            status=JobStatus.PENDING,
            provider_name=self._provider.name,
        )
        await self._jobs.save(job)

        # Fire-and-forget: the job is returned immediately in PENDING state:
        # the caller polls GET /virtual-tryon/status/{jobId} for progress,
        # matching the async job architecture this service is built around.
        asyncio.create_task(self._process(job, options))

        return job

    async def _process(self, job: Job, options: dict) -> None:
        try:
            job.mark_processing()
            await self._jobs.save(job)

            result = await self._provider.generate(
                job.person_image_path,
                job.garment_image_path,
                self._output_dir,
                **options,
            )

            processing_time = (result.metadata or {}).get("processing_time_seconds")
            job.mark_completed(result.output_path, processing_time_seconds=processing_time)
            await self._jobs.save(job)
            logger.info("Job %s completed via provider '%s'", job.id, job.provider_name)
        except Exception as error:  # noqa: BLE001 - job failures must never crash the loop
            job.mark_failed(str(error))
            await self._jobs.save(job)
            logger.exception("Job %s failed", job.id)

    async def get_status(self, job_id: str) -> Job:
        return await self._jobs.get(job_id)

    async def list_history(self) -> list[Job]:
        return await self._jobs.list_all()

    async def delete_job(self, job_id: str) -> None:
        await self._jobs.delete(job_id)
