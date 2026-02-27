#!/usr/bin/env python3
"""Crop elements from page images using layout JSON files."""

import argparse
import json
import re
from pathlib import Path

from PIL import Image


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Crop elements using layout JSON.")
    parser.add_argument("--image-dir", required=True, help="Directory of page images")
    parser.add_argument("--layout-dir", required=True, help="Directory of layout JSON files")
    parser.add_argument("--output-dir", required=True, help="Output directory for crops")
    parser.add_argument("--pad", type=int, default=0, help="Padding in pixels around each box")
    parser.add_argument("--min-size", type=int, default=2, help="Skip crops smaller than this")
    return parser.parse_args()


def sanitize(text: str) -> str:
    if not text:
        return "none"
    text = text.lower().strip()
    text = re.sub(r"[^a-z0-9_-]+", "_", text)
    text = re.sub(r"_+", "_", text).strip("_")
    return text or "none"


def clamp(value: int, lo: int, hi: int) -> int:
    return max(lo, min(hi, value))


def main() -> None:
    args = parse_args()
    image_dir = Path(args.image_dir)
    layout_dir = Path(args.layout_dir)
    output_dir = Path(args.output_dir)

    output_dir.mkdir(parents=True, exist_ok=True)

    for json_path in sorted(layout_dir.glob("*.json")):
        stem = json_path.stem
        image_path = image_dir / f"{stem}.png"
        if not image_path.exists():
            image_path = image_dir / f"{stem}.jpg"
        if not image_path.exists():
            image_path = image_dir / f"{stem}.jpeg"
        if not image_path.exists():
            image_path = image_dir / f"{stem}.webp"
        if not image_path.exists():
            print(f"Missing image for {json_path.name}")
            continue

        with open(json_path, "r", encoding="utf-8") as f:
            data = json.load(f)

        elements = data.get("elements", [])
        if not elements:
            continue

        page_out = output_dir / stem
        page_out.mkdir(parents=True, exist_ok=True)

        with Image.open(image_path) as img:
            width, height = img.size

            for idx, el in enumerate(elements, start=1):
                try:
                    x = int(el.get("x", 0))
                    y = int(el.get("y", 0))
                    w = int(el.get("width", 0))
                    h = int(el.get("height", 0))
                except Exception:
                    continue

                if w < args.min_size or h < args.min_size:
                    continue

                x1 = clamp(x - args.pad, 0, width)
                y1 = clamp(y - args.pad, 0, height)
                x2 = clamp(x + w + args.pad, 0, width)
                y2 = clamp(y + h + args.pad, 0, height)

                if x2 <= x1 or y2 <= y1:
                    continue

                el_type = sanitize(str(el.get("type", "other")))
                notes = sanitize(str(el.get("notes", "")))

                name = (
                    f"{idx:03d}_{el_type}_x{int(x):04d}_y{int(y):04d}_"
                    f"{notes}.png"
                )

                crop = img.crop((x1, y1, x2, y2))
                crop.save(page_out / name)

    print(f"Done. Crops written to {output_dir}")


if __name__ == "__main__":
    main()
