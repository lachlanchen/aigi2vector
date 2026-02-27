#!/usr/bin/env python3
"""Extract a specific part from an image using GRS AI Nano Banana API."""

import argparse
import base64
import json
import os
import sys
import time
import urllib.request
from pathlib import Path
from typing import Any, Dict, Optional


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Extract a specific part from an image using GRS AI Nano Banana API."
    )
    parser.add_argument("--image", required=True, help="Path to input image")
    parser.add_argument(
        "--prompt",
        default="",
        help="Prompt to guide extraction (if empty, uses default microfluidics prompt)",
    )
    parser.add_argument(
        "--output-dir",
        required=True,
        help="Directory to write output image and prompt",
    )
    parser.add_argument(
        "--output-name",
        default="extracted_part.png",
        help="Output filename",
    )
    parser.add_argument(
        "--model",
        default="nano-banana-fast",
        help="Model name (default: nano-banana-fast)",
    )
    parser.add_argument(
        "--host",
        default="https://grsai.dakka.com.cn",
        help="API host, e.g. https://grsai.dakka.com.cn",
    )
    parser.add_argument(
        "--aspect",
        default="auto",
        help="Aspect ratio, e.g. auto, 1:1, 16:9",
    )
    parser.add_argument(
        "--image-size",
        default="1K",
        help="Image size (only for supported models), e.g. 1K, 2K, 4K",
    )
    return parser.parse_args()


def default_microfluidics_prompt() -> str:
    return (
        "Goal: Extract only the microfluidics module from the provided slide image. "
        "Do NOT change layout or geometry. Preserve shapes, colors, and relative positions. "
        "Remove all text labels and captions. Remove anything outside the microfluidics module. "
        "The output should be a tight crop around the microfluidics apparatus (housing, channels, "
        "oil/water lines, tubing, heater/cooler blocks if they are part of the microfluidics module). "
        "No background margin. Output a clean image suitable for vectorization (e.g., TikZ)."
    )


def image_to_data_url(path: Path) -> str:
    mime = "image/png"
    if path.suffix.lower() in {".jpg", ".jpeg"}:
        mime = "image/jpeg"
    elif path.suffix.lower() == ".webp":
        mime = "image/webp"
    data = path.read_bytes()
    b64 = base64.b64encode(data).decode("utf-8")
    return f"data:{mime};base64,{b64}"


def request_json(url: str, payload: Dict[str, Any], api_key: str) -> Dict[str, Any]:
    body = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(url, data=body, method="POST")
    req.add_header("Content-Type", "application/json")
    req.add_header("Authorization", f"Bearer {api_key}")

    with urllib.request.urlopen(req, timeout=600) as resp:
        raw = resp.read().decode("utf-8", errors="ignore")

    # Try parse as single JSON
    try:
        return json.loads(raw)
    except Exception:
        pass

    # Try parse line-delimited JSON (stream)
    last_obj: Optional[Dict[str, Any]] = None
    for line in raw.splitlines():
        line = line.strip()
        if not line:
            continue
        if line.startswith("data:"):
            line = line[5:].strip()
        try:
            obj = json.loads(line)
            if isinstance(obj, dict):
                last_obj = obj
        except Exception:
            continue

    if last_obj is None:
        raise RuntimeError("Failed to parse API response")
    return last_obj


def download_file(url: str, dest: Path) -> None:
    with urllib.request.urlopen(url, timeout=600) as resp:
        dest.write_bytes(resp.read())


def main() -> None:
    args = parse_args()

    api_key = os.environ.get("GRSAI")
    if not api_key:
        print("Missing GRSAI env var. Export GRSAI=...", file=sys.stderr)
        sys.exit(1)

    image_path = Path(args.image)
    if not image_path.exists():
        raise FileNotFoundError(image_path)

    prompt = args.prompt.strip() or default_microfluidics_prompt()

    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    out_image = output_dir / args.output_name
    out_prompt = output_dir / (Path(args.output_name).stem + ".prompt.txt")

    payload: Dict[str, Any] = {
        "model": args.model,
        "urls": [image_to_data_url(image_path)],
        "prompt": prompt,
        "aspectRatio": args.aspect,
    }

    # Only attach imageSize when provided
    if args.image_size:
        payload["imageSize"] = args.image_size

    url = args.host.rstrip("/") + "/v1/draw/nano-banana"

    result = request_json(url, payload, api_key)

    results = result.get("results") or []
    if not results:
        raise RuntimeError(f"No results in response: {result}")

    image_url = results[0].get("url")
    if not image_url:
        raise RuntimeError(f"Missing image URL in response: {result}")

    download_file(image_url, out_image)
    out_prompt.write_text(prompt + "\n", encoding="utf-8")

    print(f"Saved: {out_image}")


if __name__ == "__main__":
    main()
