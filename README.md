# aigi2vector

Convert AI-generated raster images into clean vector plot SVGs.

This tool detects edges or binary shapes in an image and writes them as SVG paths. It is meant for stylized/plotter-friendly vectors, not photorealistic tracing.

## Quick Start

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

python aigi2vector.py input.png output.svg
```

## Usage

```bash
python aigi2vector.py <input_image> <output_svg> [options]
```

### Options

- `--mode edges|binary` (default: `edges`)
- `--canny 100 200` (low/high thresholds for edges)
- `--threshold 128` (binary threshold for `binary` mode)
- `--invert` (invert black/white)
- `--blur 3` (gaussian blur kernel size, odd integer)
- `--epsilon 1.5` (curve simplification; higher = fewer points)

### Examples

Edges (good for line art):

```bash
python aigi2vector.py input.png output.svg --mode edges --canny 80 180 --epsilon 2.0
```

Binary shapes (good for logos / flat art):

```bash
python aigi2vector.py input.png output.svg --mode binary --threshold 140 --invert
```

## Notes

- The output SVG uses the input pixel dimensions. Scale in your vector editor if needed.
- For best results, start with a high-contrast image.

## PPTX Image Extraction

If you need to extract embedded images from a `.pptx` (e.g., one or two images per slide), use:

```bash
bash scripts/setup_conda_env.sh
conda activate aigi2vector-pptx
python scripts/extract_pptx_images.py /path/to/file.pptx /path/to/output_dir
```

Add `--dedupe` to skip duplicate images across slides. Add `--png` to save files as `p{slide}image{index}.png`.

### Render Slides to Images

To render each slide to `page1.png`, `page2.png`, ... you need LibreOffice (`soffice`) installed:

```bash
bash scripts/render_pptx_slides.sh /path/to/file.pptx /path/to/output_dir
```

## License

MIT
