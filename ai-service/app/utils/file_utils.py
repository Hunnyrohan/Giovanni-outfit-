"""Filesystem helpers for storing uploaded and generated images."""

import uuid
from pathlib import Path

from fastapi import UploadFile

from app.core.exceptions import ImageError

ALLOWED_CONTENT_TYPES = {"image/jpeg", "image/png", "image/webp"}


def ensure_dir(path: str) -> Path:
    directory = Path(path)
    directory.mkdir(parents=True, exist_ok=True)
    return directory


async def save_upload(upload: UploadFile, destination_dir: str, max_size_mb: int) -> str:
    """Validates and persists an uploaded image, returning its saved path."""
    if upload.content_type not in ALLOWED_CONTENT_TYPES:
        raise ImageError(
            f"Unsupported image type '{upload.content_type}'. Allowed: jpeg, png, webp.",
            {"contentType": upload.content_type},
        )

    contents = await upload.read()
    max_bytes = max_size_mb * 1024 * 1024

    if len(contents) == 0:
        raise ImageError("Uploaded image is empty")

    if len(contents) > max_bytes:
        raise ImageError(
            f"Image exceeds the {max_size_mb}MB upload limit",
            {"maxSizeMb": max_size_mb},
        )

    directory = ensure_dir(destination_dir)
    extension = Path(upload.filename or "").suffix or ".jpg"
    saved_path = directory / f"{uuid.uuid4().hex}{extension}"
    saved_path.write_bytes(contents)

    return str(saved_path)
