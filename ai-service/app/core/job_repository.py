"""Job persistence abstraction.

An in-memory implementation is provided for now. Because the service layer
only depends on the `JobRepository` interface (not on the in-memory
implementation directly), swapping this for a Redis- or database-backed
repository later is a one-line change in the DI wiring, not a rewrite.
"""

from abc import ABC, abstractmethod

from app.core.exceptions import JobNotFoundError
from app.models.job import Job


class JobRepository(ABC):
    @abstractmethod
    async def save(self, job: Job) -> Job: ...

    @abstractmethod
    async def get(self, job_id: str) -> Job: ...

    @abstractmethod
    async def list_all(self) -> list[Job]: ...

    @abstractmethod
    async def delete(self, job_id: str) -> None: ...


class InMemoryJobRepository(JobRepository):
    """Process-local job store. Fine for local development and single-instance
    deployments; replace with a shared store before scaling horizontally.
    """

    def __init__(self) -> None:
        self._jobs: dict[str, Job] = {}

    async def save(self, job: Job) -> Job:
        self._jobs[job.id] = job
        return job

    async def get(self, job_id: str) -> Job:
        job = self._jobs.get(job_id)
        if job is None:
            raise JobNotFoundError(f"Job '{job_id}' was not found", {"jobId": job_id})
        return job

    async def list_all(self) -> list[Job]:
        return sorted(self._jobs.values(), key=lambda job: job.created_at, reverse=True)

    async def delete(self, job_id: str) -> None:
        if job_id not in self._jobs:
            raise JobNotFoundError(f"Job '{job_id}' was not found", {"jobId": job_id})
        del self._jobs[job_id]
