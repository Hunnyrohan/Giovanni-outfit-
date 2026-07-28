"""Provider interface that every AI model backend must implement.

`VirtualTryOnService` (see app/services) depends only on this abstraction,
never on a concrete provider - so swapping Leffa for CatVTON, IDM-VTON, or
any future model is a matter of implementing this interface and changing
the DI wiring, with zero changes to business logic or API routes.
"""

from abc import ABC, abstractmethod
from dataclasses import dataclass


@dataclass
class ProviderResult:
    """What a provider returns after (mock or real) inference."""

    output_path: str
    metadata: dict | None = None


class BaseVirtualTryOnProvider(ABC):
    """Abstract virtual try-on model provider."""

    name: str = "base"

    @abstractmethod
    async def generate(
        self,
        person_image_path: str,
        garment_image_path: str,
        output_dir: str,
        **options,
    ) -> ProviderResult:
        """Runs inference and returns a ProviderResult pointing at the output image.

        Implementations should raise `app.core.exceptions.ProviderError` on
        failure (invalid image, model error, timeout, etc.) rather than
        letting raw exceptions escape.
        """
        raise NotImplementedError
