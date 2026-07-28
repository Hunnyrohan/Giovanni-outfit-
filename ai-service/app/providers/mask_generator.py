"""Garment-region mask generation without detectron2/DensePose.

CatVTON's own automatic masker (`model/cloth_masker.py` upstream) depends on
detectron2 + Facebook's DensePose extension, which ships a Linux-only
precompiled binary (`detectron2/_C.cpython-39-x86_64-linux-gnu.so`) with no
official Windows build - see catvton_lib/VENDORED_NOTICE.md.

This module is a deliberate, disclosed simplification: it uses MediaPipe's
Pose Landmarker (pure pip package, Windows-compatible) to locate shoulder/
hip/ankle keypoints, then rasterizes a soft-edged rectangular region as the
inpainting mask. This is lower-precision than the official DensePose+SCHP
segmentation (a rectangle vs. a precise garment silhouette) but requires no
native build tooling and runs entirely on Windows/Python 3.11.
"""

import urllib.request
from pathlib import Path

import cv2
import numpy as np
from PIL import Image, ImageFilter

import mediapipe as mp
from mediapipe.tasks.python import vision
from mediapipe.tasks.python.core.base_options import BaseOptions

from app.core.logging import get_logger

logger = get_logger(__name__)

# Official Google-hosted model asset - downloaded once and cached locally.
_MODEL_URL = (
    "https://storage.googleapis.com/mediapipe-models/pose_landmarker/"
    "pose_landmarker_lite/float16/1/pose_landmarker_lite.task"
)
_MODEL_CACHE_DIR = Path.home() / ".cache" / "stylesense-ai" / "mediapipe"
_MODEL_PATH = _MODEL_CACHE_DIR / "pose_landmarker_lite.task"

# Standard BlazePose 33-keypoint indices (stable across MediaPipe versions).
_LEFT_SHOULDER, _RIGHT_SHOULDER = 11, 12
_LEFT_ELBOW, _RIGHT_ELBOW = 13, 14
_LEFT_WRIST, _RIGHT_WRIST = 15, 16
_LEFT_HIP, _RIGHT_HIP = 23, 24
_LEFT_KNEE, _RIGHT_KNEE = 25, 26
_LEFT_ANKLE, _RIGHT_ANKLE = 27, 28


def _ensure_model_downloaded() -> Path:
    if _MODEL_PATH.exists():
        return _MODEL_PATH

    _MODEL_CACHE_DIR.mkdir(parents=True, exist_ok=True)
    logger.info("Downloading MediaPipe pose landmarker model to %s", _MODEL_PATH)
    urllib.request.urlretrieve(_MODEL_URL, _MODEL_PATH)
    return _MODEL_PATH


class MaskGenerator:
    """Lazily loads the pose landmarker once and reuses it across requests."""

    def __init__(self) -> None:
        self._landmarker = None

    def _get_landmarker(self):
        if self._landmarker is None:
            model_path = _ensure_model_downloaded()
            options = vision.PoseLandmarkerOptions(
                base_options=BaseOptions(model_asset_path=str(model_path)),
                running_mode=vision.RunningMode.IMAGE,
            )
            self._landmarker = vision.PoseLandmarker.create_from_options(options)
        return self._landmarker

    def generate(self, person_image: Image.Image, garment_type: str = "upper") -> Image.Image:
        """Returns an 'L'-mode mask the same size as person_image."""
        width, height = person_image.size
        rgb = np.array(person_image.convert("RGB"))
        mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb)

        try:
            result = self._get_landmarker().detect(mp_image)
        except Exception:
            logger.exception("Pose detection failed; falling back to a fixed proportional mask")
            return self._fallback_mask(width, height, garment_type)

        if not result.pose_landmarks:
            logger.warning("No pose detected in person image; falling back to a fixed proportional mask")
            return self._fallback_mask(width, height, garment_type)

        landmarks = result.pose_landmarks[0]

        def point(index: int) -> tuple[float, float]:
            landmark = landmarks[index]
            return landmark.x * width, landmark.y * height

        try:
            mask_array = self._draw_garment_region(point, garment_type, width, height)
        except (IndexError, ValueError):
            logger.warning("Could not derive garment region from landmarks; using fallback mask")
            return self._fallback_mask(width, height, garment_type)

        mask = Image.fromarray(mask_array, mode="L")
        return mask.filter(ImageFilter.GaussianBlur(radius=9))

    @staticmethod
    def _draw_garment_region(point, garment_type: str, width: int, height: int) -> np.ndarray:
        """Rasterizes the region a garment actually occupies.

        The torso is a padded quadrilateral; each limb is a thick "capsule"
        traced along its landmark segments (shoulder->elbow->wrist for arms,
        hip->knee->ankle for legs). Limb coverage is what lets the model
        replace sleeves and trouser legs - a torso-only rectangle leaves the
        original sleeves in place and forces the model to improvise a seam,
        which shows up as cropped sleeves / hallucinated shoulder artifacts.
        """
        left_shoulder, right_shoulder = point(_LEFT_SHOULDER), point(_RIGHT_SHOULDER)
        left_hip, right_hip = point(_LEFT_HIP), point(_RIGHT_HIP)

        shoulder_width = float(np.hypot(
            right_shoulder[0] - left_shoulder[0],
            right_shoulder[1] - left_shoulder[1],
        ))
        if shoulder_width < 1.0:
            raise ValueError("Degenerate shoulder landmarks")

        # Limb capsule thickness scales with body size in the frame.
        arm_thickness = max(10, int(shoulder_width * 0.45))
        leg_thickness = max(12, int(shoulder_width * 0.60))

        mask_array = np.zeros((height, width), dtype=np.uint8)

        def draw_limb(joints: list[tuple[float, float]], thickness: int) -> None:
            pts = np.array(joints, dtype=np.int32)
            cv2.polylines(mask_array, [pts], isClosed=False, color=255, thickness=thickness)
            for x, y in joints:
                cv2.circle(mask_array, (int(x), int(y)), thickness // 2, 255, -1)

        def draw_torso(top_pad: float, bottom_pad: float, side_pad: float) -> None:
            quad = np.array(
                [
                    (left_shoulder[0] - side_pad, left_shoulder[1] - top_pad),
                    (right_shoulder[0] + side_pad, right_shoulder[1] - top_pad),
                    (right_hip[0] + side_pad, right_hip[1] + bottom_pad),
                    (left_hip[0] - side_pad, left_hip[1] + bottom_pad),
                ],
                dtype=np.int32,
            )
            cv2.fillPoly(mask_array, [quad], color=255)

        side_pad = shoulder_width * 0.22
        neck_pad = shoulder_width * 0.35  # covers collars/necklines above the shoulder line

        if garment_type in ("upper", "upper_sleeveless", "overall"):
            # Kept minimal deliberately: this was 0.30 originally (a visible
            # trailing strip hallucinated over the jeans), then 0.14 (smaller
            # but still present) - every extra pixel past the true hip line
            # is room for the model to invent a hem "tail" dangling into the
            # pants, so this only keeps enough margin to avoid a hard seam
            # exactly on the landmark line itself.
            draw_torso(top_pad=neck_pad, bottom_pad=shoulder_width * 0.04, side_pad=side_pad)
            # Sleeveless garments have no sleeve fabric in the reference image
            # for the model to work from, so masking the arms too forces it to
            # hallucinate sleeve content from nothing - that's what produced
            # the tan cardigan-shaped artifact on an actual sleeveless vest.
            if garment_type != "upper_sleeveless":
                draw_limb([left_shoulder, point(_LEFT_ELBOW), point(_LEFT_WRIST)], arm_thickness)
                draw_limb([right_shoulder, point(_RIGHT_ELBOW), point(_RIGHT_WRIST)], arm_thickness)

        if garment_type in ("lower", "overall"):
            hip_quad = np.array(
                [
                    (left_hip[0] - side_pad, left_hip[1] - shoulder_width * 0.20),
                    (right_hip[0] + side_pad, right_hip[1] - shoulder_width * 0.20),
                    (right_hip[0] + side_pad, right_hip[1] + shoulder_width * 0.30),
                    (left_hip[0] - side_pad, left_hip[1] + shoulder_width * 0.30),
                ],
                dtype=np.int32,
            )
            cv2.fillPoly(mask_array, [hip_quad], color=255)
            draw_limb([left_hip, point(_LEFT_KNEE), point(_LEFT_ANKLE)], leg_thickness)
            draw_limb([right_hip, point(_RIGHT_KNEE), point(_RIGHT_ANKLE)], leg_thickness)

        if not mask_array.any():
            raise ValueError("Degenerate garment region")

        # A modest dilation closes gaps between the torso quad and limb
        # capsules so the model sees one continuous region to redraw.
        kernel_size = max(3, int(shoulder_width * 0.10)) | 1  # odd
        kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (kernel_size, kernel_size))
        mask_array = cv2.dilate(mask_array, kernel)
        return mask_array

    @staticmethod
    def _fallback_mask(width: int, height: int, garment_type: str) -> Image.Image:
        mask_array = np.zeros((height, width), dtype=np.uint8)
        if garment_type == "lower":
            y0, y1 = int(height * 0.45), int(height * 0.98)
        elif garment_type == "overall":
            y0, y1 = int(height * 0.12), int(height * 0.98)
        else:
            y0, y1 = int(height * 0.15), int(height * 0.55)
        x0, x1 = int(width * 0.15), int(width * 0.85)
        mask_array[y0:y1, x0:x1] = 255
        mask = Image.fromarray(mask_array, mode="L")
        return mask.filter(ImageFilter.GaussianBlur(radius=9))
