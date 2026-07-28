"""Reusable exception hierarchy for the AI Service.

Every exception carries an HTTP status code and a machine-readable `errors`
payload so the global exception handler (see main.py) can translate any of
these into the same `{success, message, errors}` envelope used by the rest
of StyleSense AI's backend, keeping error shapes consistent across services.
"""

from typing import Any


class AIServiceError(Exception):
    """Base class for all AI Service errors."""

    status_code: int = 500

    def __init__(self, message: str, errors: dict[str, Any] | None = None) -> None:
        super().__init__(message)
        self.message = message
        self.errors = errors or {}


class ValidationError(AIServiceError):
    """Raised when request input fails validation (bad fields, missing data)."""

    status_code = 400


class ImageError(AIServiceError):
    """Raised when an uploaded image is missing, unreadable, or unsupported."""

    status_code = 400


class JobNotFoundError(AIServiceError):
    """Raised when a job id does not exist."""

    status_code = 404


class ProviderError(AIServiceError):
    """Raised when an AI provider (e.g. Leffa) fails to produce a result."""

    status_code = 502


class ServerError(AIServiceError):
    """Raised for unexpected internal failures."""

    status_code = 500
