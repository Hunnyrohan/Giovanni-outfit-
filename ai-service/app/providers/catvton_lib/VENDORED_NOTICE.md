# Vendored code notice

The files in this directory (`model/pipeline.py`, `model/attn_processor.py`,
`model/utils.py`, `utils.py`, `resource/img/NSFW.jpg`) are copied **verbatim,
unmodified** from the official CatVTON repository:

- Source: https://github.com/Zheng-Chong/CatVTON
- Commit: `7818397f25613beedb3d861a34769f607cfcf3b1`
- License: Creative Commons Attribution-NonCommercial-ShareAlike 4.0
  International (CC BY-NC-SA 4.0) — see `UPSTREAM_LICENSE.txt`. **Non-commercial
  use only.** Fine for this final-year academic project; would need a
  different license/model before any commercial use.
- Paper: Zheng et al., "CatVTON: Concatenation Is All You Need for
  Virtual Try-On with Diffusion Models" (ICLR 2025).

Deliberately NOT vendored: `model/cloth_masker.py` (`AutoMasker`) and the
`DensePose`/`SCHP`/`detectron2`/`densepose` directories from upstream —
`detectron2` ships a Linux-only precompiled binary
(`detectron2/_C.cpython-39-x86_64-linux-gnu.so`) with no official Windows
build, so automatic mask generation is replaced by our own implementation
in `app/providers/mask_generator.py` (mediapipe + OpenCV, no detectron2).

Everything else in `app/providers/catvton_provider.py` and
`app/providers/mask_generator.py` is original code written for this project.
