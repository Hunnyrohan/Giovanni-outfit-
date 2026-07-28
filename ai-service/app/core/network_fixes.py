"""Environment-specific network workarounds, verified necessary on the
target Windows development machine - see README.md's Troubleshooting section
for the exact errors these fix.

Both are applied unconditionally at process startup (see main.py) because
they are harmless no-ops on machines that don't need them:
  - Forcing IPv4 only matters if IPv6 routing to a host is actually broken;
    otherwise it just skips trying AAAA records first.
  - Disabling HF Hub's symlink cache only matters on Windows without
    Developer Mode/admin; elsewhere it just means one extra file copy
    instead of a symlink.
"""

import os
import platform
import socket

from app.core.logging import get_logger

logger = get_logger(__name__)


def apply_network_fixes() -> None:
    _force_ipv4()
    _disable_symlinks_on_windows()


def _force_ipv4() -> None:
    """Some networks have broken IPv6 routing to huggingface.co - Python's
    resolver tries AAAA records first and the TLS handshake resets, even
    though `curl -4` succeeds immediately. Verified on the target machine:
    without this, model downloads fail with
    `ConnectionResetError(10054, ...)` deep inside huggingface_hub/requests.
    """
    original_getaddrinfo = socket.getaddrinfo

    def _ipv4_only_getaddrinfo(host, port, family=0, type=0, proto=0, flags=0):
        return original_getaddrinfo(host, port, socket.AF_INET, type, proto, flags)

    socket.getaddrinfo = _ipv4_only_getaddrinfo
    logger.info("Network fix applied: forcing IPv4 for all outbound connections")


def _disable_symlinks_on_windows() -> None:
    """Windows blocks creating symlinks without Developer Mode or admin
    rights. huggingface_hub's cache uses symlinks by default; without this,
    model downloads fail with
    `OSError: [WinError 1314] A required privilege is not held by the client`.
    """
    if platform.system() != "Windows":
        return

    os.environ.setdefault("HF_HUB_DISABLE_SYMLINKS", "1")
    logger.info("Network fix applied: disabled huggingface_hub symlink cache (Windows)")
