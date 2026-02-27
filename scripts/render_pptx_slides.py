#!/usr/bin/env python3
"""Render PPTX slides to PNG files via LibreOffice + PyMuPDF."""

import argparse
import shutil
import subprocess
import tempfile
from pathlib import Path

import fitz  # PyMuPDF


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Render PPTX slides to PNG files (page1.png, page2.png, ...)."
    )
    parser.add_argument("pptx_path", help="Path to .pptx file")
    parser.add_argument("output_dir", help="Directory to write slide images")
    parser.add_argument(
        "--dpi",
        type=int,
        default=200,
        help="Render DPI (higher = larger images)",
    )
    return parser.parse_args()


def find_soffice() -> str:
    for name in ("soffice", "libreoffice"):
        path = shutil.which(name)
        if path:
            return path
    raise FileNotFoundError("LibreOffice (soffice) not found in PATH")


def convert_to_pdf(soffice: str, pptx_path: Path, tmp_dir: Path) -> Path:
    cmd = [
        soffice,
        "--headless",
        "--convert-to",
        "pdf",
        "--outdir",
        str(tmp_dir),
        str(pptx_path),
    ]
    subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    pdf_path = tmp_dir / (pptx_path.stem + ".pdf")
    if not pdf_path.exists():
        raise FileNotFoundError("PDF export failed; output PDF not found")
    return pdf_path


def render_pdf_to_png(pdf_path: Path, out_dir: Path, dpi: int) -> int:
    out_dir.mkdir(parents=True, exist_ok=True)
    # Silence benign structure-tree warnings from some PDFs
    try:
        fitz.TOOLS.mupdf_display_errors(False)
    except Exception:
        pass
    doc = fitz.open(pdf_path)
    for i, page in enumerate(doc, start=1):
        pix = page.get_pixmap(dpi=dpi)
        out_path = out_dir / f"page{i}.png"
        pix.save(out_path)
    return doc.page_count


def main() -> None:
    args = parse_args()
    pptx_path = Path(args.pptx_path)
    out_dir = Path(args.output_dir)

    if not pptx_path.exists():
        raise FileNotFoundError(pptx_path)

    soffice = find_soffice()

    with tempfile.TemporaryDirectory() as tmp:
        tmp_dir = Path(tmp)
        pdf_path = convert_to_pdf(soffice, pptx_path, tmp_dir)
        count = render_pdf_to_png(pdf_path, out_dir, args.dpi)

    print(f"Rendered {count} slides to {out_dir}")


if __name__ == "__main__":
    main()
