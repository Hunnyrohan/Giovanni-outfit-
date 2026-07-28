"""Structured logging configuration for the AI Service."""

import logging
import sys

from app.config.settings import get_settings

_LOG_FORMAT = (
    "%(asctime)s | %(levelname)-8s | %(name)s | %(message)s"
)


def setup_logging() -> None:
    """Configures the root logger once at application startup.

    Uses a plain structured text format (timestamp | level | logger | message)
    rather than a third-party JSON logger, keeping the dependency footprint
    minimal while still being easy to parse/grep in production.
    """
    settings = get_settings()

    root_logger = logging.getLogger()
    root_logger.setLevel(settings.LOG_LEVEL.upper())

    # Avoid duplicate handlers if setup_logging() is called more than once
    # (e.g. under a test runner that imports the app multiple times).
    if root_logger.handlers:
        return

    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(logging.Formatter(_LOG_FORMAT))
    root_logger.addHandler(handler)


def get_logger(name: str) -> logging.Logger:
    """Returns a module-scoped logger, e.g. `get_logger(__name__)`."""
    return logging.getLogger(name)
