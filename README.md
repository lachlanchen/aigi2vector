[English](README.md) · [العربية](i18n/README.ar.md) · [Español](i18n/README.es.md) · [Français](i18n/README.fr.md) · [日本語](i18n/README.ja.md) · [한국어](i18n/README.ko.md) · [Tiếng Việt](i18n/README.vi.md) · [中文 (简体)](i18n/README.zh-Hans.md) · [中文（繁體）](i18n/README.zh-Hant.md) · [Deutsch](i18n/README.de.md) · [Русский](i18n/README.ru.md)


[![LazyingArt banner](https://github.com/lachlanchen/lachlanchen/raw/main/figs/banner.png)](https://github.com/lachlanchen/lachlanchen/blob/main/figs/banner.png)

# aigi2vector

[![Python 3](https://img.shields.io/badge/Python-3.x-blue.svg)](https://www.python.org/)
[![OpenCV](https://img.shields.io/badge/OpenCV-Enabled-5C3EE8.svg)](https://opencv.org/)
[![NumPy](https://img.shields.io/badge/NumPy-Required-4DABCF.svg)](https://numpy.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](#license)

Convert AI-generated raster images into clean vector plot SVGs.

This repository provides a Python CLI that detects edges or binary shapes in an image and writes them as SVG paths. It is designed for stylized, plotter-friendly vectorization rather than photorealistic tracing.

## 🎯 At a Glance

| Layer | Description | Location |
|---|---|---|
| Core CLI | Convert raster images into SVG paths from a single command | [`aigi2vector.py`](aigi2vector.py) |
| PPTX helpers | Pull slide content and render pages for downstream vectorization | `scripts/` |
| Optional automation | Larger AI-assisted, extraction, and composition workflows | `AutoAppDev/`, `scripts/` |

## ✨ Overview

`aigi2vector` includes:

- A core raster-to-SVG CLI: [`aigi2vector.py`](aigi2vector.py)
- Optional PPTX helpers for extracting embedded images and rendering slides to PNG
- Additional workflow scripts under `scripts/` for layout extraction, cropping, and AI-assisted pipelines
- An `AutoAppDev/` submodule (external tooling; not required for the main CLI)

| Item | Details |
|---|---|
| Core purpose | Convert raster images to SVG path output |
| Primary mode | Single-file Python CLI |
| Core dependencies | `opencv-python`, `numpy` |
| Optional workflows | PPTX extraction/rendering, AI-assisted script pipelines |

## 🚀 Features

- Convert raster images to SVG paths using two modes:
  - `edges`: Canny-based edge detection
  - `binary`: thresholded shape extraction
- Preprocessing controls:
  - Gaussian blur (`--blur`)
  - Optional inversion (`--invert`)
- Path simplification using Douglas-Peucker approximation (`--epsilon`)
- SVG output that preserves input pixel dimensions via `width`, `height`, and `viewBox`
- PPTX image utilities:
  - Extract embedded images by slide
  - Render slide pages to `page1.png`, `page2.png`, ...

## 🗂️ Project Structure

```text
.
├── aigi2vector.py
├── README.md
├── requirements.txt
├── AGENTS.md
├── AutoAppDev/                      # Git submodule (optional for core CLI)
├── i18n/                            # Translation directory (currently scaffold/empty)
└── scripts/
    ├── extract_pptx_images.py
    ├── render_pptx_slides.py
    ├── render_pptx_slides.sh
    ├── setup_conda_env.sh
    ├── crop_elements_from_layout.py
    ├── crop_elements_from_layout_v2.py
    ├── extract_part_grsai.py
    ├── extract_elements_grsai_pipeline.py
    ├── extract_elements_from_prompt_json.py
    ├── run_grsai_three_step.sh
    ├── codex_describe_images_to_md.sh
    ├── codex_extract_layout_elements.sh
    ├── codex_extract_layout_elements_v2.sh
    ├── codex_generate_tikz_from_parts.sh
    ├── codex_compile_tikz_pdf.sh
    └── run_tikz_prompt_pipeline.sh
```

## 📦 Prerequisites

### Core CLI

- Python 3
- `pip`
- Dependencies from [`requirements.txt`](requirements.txt):
  - `opencv-python`
  - `numpy`

### Optional PPTX Helpers

- For `scripts/extract_pptx_images.py`:
  - `python-pptx`
  - `Pillow`
- For `scripts/render_pptx_slides.py`:
  - LibreOffice (`soffice` or `libreoffice` in `PATH`)
  - `PyMuPDF` (`fitz`)
- Optional helper setup:
  - Conda (for `scripts/setup_conda_env.sh`)

### Optional Advanced Pipelines

Several scripts under `scripts/` rely on external tools/services (for example `codex` CLI and GRS AI APIs). These are optional and not required to run `aigi2vector.py`.

## 🛠️ Installation

### Quick Start (existing canonical flow)

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

python aigi2vector.py input.png output.svg
```

### Optional Conda setup for PPTX utilities

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
```

## ▶️ Usage

```bash
python aigi2vector.py <input_image> <output_svg> [options]
```

### CLI Options

| Option | Default | Description |
|---|---|---|
| `--mode edges|binary` | `edges` | Vectorization mode |
| `--canny LOW HIGH` | `100 200` | Low/high thresholds for edges mode |
| `--threshold N` | `128` | Binary threshold used in `binary` mode |
| `--invert` | off | Invert black/white before contour detection |
| `--blur K` | `3` | Gaussian blur kernel size (odd integer) |
| `--epsilon E` | `1.5` | Curve simplification; higher = fewer points |

### How Modes Work

- `edges` mode runs Canny edge detection and traces external contours.
- `binary` mode thresholds grayscale pixels and traces external contours of the resulting mask.

## ⚙️ Configuration

### Main CLI parameter tuning

- `--canny LOW HIGH`:
  - Lower values capture more detail/noise.
  - Higher values produce cleaner but potentially sparser contours.
- `--threshold` (binary mode):
  - Lower threshold keeps more light regions as foreground.
  - Higher threshold keeps mostly dark/high-contrast regions.
- `--blur`:
  - Automatically normalized to a positive odd kernel internally.
  - Larger values smooth noise before contour detection.
- `--epsilon`:
  - Larger values simplify paths more aggressively (fewer points).
  - Smaller values preserve shape detail.

### Environment variables (advanced scripts)

- `GRSAI` is required by GRS AI extraction scripts (for example `extract_part_grsai.py`, `extract_elements_grsai_pipeline.py`, `extract_elements_from_prompt_json.py`).

Assumption note: advanced scripts are environment-specific and partially undocumented in the current README baseline; commands below keep repository-accurate behavior without guaranteeing portability across all machines.

## 🧪 Examples

### Raster to SVG

Edges (good for line art):

```bash
python aigi2vector.py input.png output.svg --mode edges --canny 80 180 --epsilon 2.0
```

Binary shapes (good for logos / flat art):

```bash
python aigi2vector.py input.png output.svg --mode binary --threshold 140 --invert
```

### PPTX image extraction

If you need to extract embedded images from a `.pptx` (e.g., one or two images per slide), use:

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
python scripts/extract_pptx_images.py /path/to/file.pptx /path/to/output_dir
```

Add `--dedupe` to skip duplicate images across slides. Add `--png` to save files as `p{slide}image{index}.png`.

### Render slides to images

To render each slide to `page1.png`, `page2.png`, ... you need LibreOffice (`soffice`) installed:

```bash
bash scripts/render_pptx_slides.sh /path/to/file.pptx /path/to/output_dir
```

Or use the Python renderer (also uses LibreOffice, then converts PDF pages to PNG):

```bash
python scripts/render_pptx_slides.py /path/to/file.pptx /path/to/output_dir --dpi 200
```

### Optional advanced workflows (scripts)

These scripts exist in-repo and can be used for larger decomposition/reconstruction pipelines:

- `scripts/run_grsai_three_step.sh`
- `scripts/codex_describe_images_to_md.sh`
- `scripts/codex_extract_layout_elements.sh`
- `scripts/codex_extract_layout_elements_v2.sh`
- `scripts/run_tikz_prompt_pipeline.sh`

Important: some of these scripts currently contain machine-specific absolute paths and external service dependencies; adapt them before production use.

## 🧰 Development Notes

- Primary implementation is a single-file Python CLI: [`aigi2vector.py`](aigi2vector.py)
- Keep function/variable names in `snake_case`, constants in `UPPER_SNAKE_CASE`
- Prefer small, testable functions over monolithic blocks
- No formal test suite is currently present
- `AIGI/` is ignored by git and intended for local assets

## 🛟 Troubleshooting

- `FileNotFoundError` for input image/PPTX:
  - Verify the input path is correct and readable.
- `Could not read image`:
  - Confirm file format is supported by OpenCV and not corrupted.
- Empty or poor SVG output:
  - Try `--mode binary` with tuned `--threshold`.
  - Adjust `--canny` thresholds in `edges` mode.
  - Reduce `--epsilon` to preserve more contour points.
  - Start from a higher-contrast source image.
- `LibreOffice (soffice) not found in PATH`:
  - Install LibreOffice and ensure `soffice` or `libreoffice` is discoverable in your shell.
- Missing Python packages for script flows:
  - Install required deps for that script path (`python-pptx`, `Pillow`, `PyMuPDF`, etc.).
- GRS AI scripts fail with auth errors:
  - Export your key, for example: `export GRSAI=...`.

## 🗺️ Roadmap

Potential next improvements:

- Add automated tests under `tests/` with deterministic sample images
- Publish unified optional dependency groups for script workflows
- Improve portability of advanced shell pipelines (remove hardcoded absolute paths)
- Add reference input/output examples under versioned sample assets
- Populate `i18n/` with maintained translated README variants

## 🤝 Contributing

Contributions are welcome.

Suggested process:

1. Fork or branch from the current mainline.
2. Keep changes focused and use short, imperative commit messages.
3. Run the relevant commands you changed (CLI/script path) and verify output.
4. Update README usage notes when behavior changes.

If you add tests, place them under `tests/` and name files `test_*.py`.

## 📝 Notes

- The output SVG uses the input pixel dimensions. Scale in your vector editor if needed.
- For best results, start with a high-contrast image.

## ❤️ Support

| Donate | PayPal | Stripe |
|---|---|---|
| [![Donate](https://img.shields.io/badge/Donate-LazyingArt-0EA5E9?style=for-the-badge&logo=ko-fi&logoColor=white)](https://chat.lazying.art/donate) | [![PayPal](https://img.shields.io/badge/PayPal-RongzhouChen-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/RongzhouChen) | [![Stripe](https://img.shields.io/badge/Stripe-Donate-635BFF?style=for-the-badge&logo=stripe&logoColor=white)](https://buy.stripe.com/aFadR8gIaflgfQV6T4fw400) |

## License

MIT
