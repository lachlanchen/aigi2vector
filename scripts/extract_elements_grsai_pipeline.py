#!/usr/bin/env python3
"""Pipeline: read layout JSON -> generate prompts -> extract each element with GRS AI."""

import argparse
import base64
import json
import os
import re
import sys
import time
import urllib.request
from pathlib import Path
from typing import Any, Dict, List, Optional


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Extract elements via GRS AI using layout JSON.")
    p.add_argument("--image", required=True, help="Path to input image")
    p.add_argument("--layout", required=True, help="Path to layout JSON (v2 preferred)")
    p.add_argument("--output-dir", required=True, help="Directory to write outputs")
    p.add_argument("--model", default="nano-banana-fast", help="Model name")
    p.add_argument("--host", default="https://grsai.dakka.com.cn", help="API host")
    p.add_argument("--aspect", default="auto", help="Aspect ratio")
    p.add_argument("--image-size", default="1K", help="Image size (if supported)")
    p.add_argument("--limit", type=int, default=0, help="Limit number of elements (0 = all)")
    p.add_argument("--skip-text", action="store_true", help="Skip elements of type 'text'")
    p.add_argument("--retries", type=int, default=2, help="Retries per element on error")
    p.add_argument("--resume", action="store_true", help="Skip elements whose output already exists")
    p.add_argument("--verbose", action="store_true", help="Print progress for each element")
    return p.parse_args()


def sanitize(text: str) -> str:
    if not text:
        return "none"
    text = text.lower().strip()
    text = re.sub(r"[^a-z0-9_-]+", "_", text)
    text = re.sub(r"_+", "_", text).strip("_")
    return text or "none"


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

    try:
        return json.loads(raw)
    except Exception:
        pass

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


def build_guard_prompt() -> str:
    return (
        "You are extracting a part from the given image. "
        "Preserve geometry, layout, and visual style. Do NOT add or invent content. "
        "Remove ALL text. No labels, captions, or annotations. "
        "Output only the requested element as a tight crop with no margin or background. "
        "Keep colors and shapes faithful to the original."
    )


def build_element_prompt(el: Dict[str, Any]) -> str:
    el_type = str(el.get("type", "element"))
    notes = str(el.get("notes", ""))
    text = str(el.get("text", ""))

    parts = [
        f"Target element type: {el_type}.",
        f"Description: {notes or 'no additional notes'}.",
    ]
    if text:
        parts.append("There may be text inside the element, but REMOVE all text in the output.")
    parts.append("Focus only on this element; exclude surrounding elements.")
    return " ".join(parts)


def main() -> None:
    args = parse_args()
    api_key = os.environ.get("GRSAI")
    if not api_key:
        print("Missing GRSAI env var. Export GRSAI=...", file=sys.stderr)
        sys.exit(1)

    image_path = Path(args.image)
    layout_path = Path(args.layout)
    if not image_path.exists():
        raise FileNotFoundError(image_path)
    if not layout_path.exists():
        raise FileNotFoundError(layout_path)

    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    data = json.loads(layout_path.read_text(encoding="utf-8"))
    elements: List[Dict[str, Any]] = data.get("elements", [])
    if args.skip_text:
        elements = [e for e in elements if str(e.get("type", "")).lower() != "text"]
    if args.limit and args.limit > 0:
        elements = elements[: args.limit]

    guard = build_guard_prompt()

    img_data_url = image_to_data_url(image_path)
    url = args.host.rstrip("/") + "/v1/draw/nano-banana"

    total = len(elements)
    saved_count = 0
    for idx, el in enumerate(elements, start=1):
        el_notes = sanitize(str(el.get("notes", "")))
        el_type = sanitize(str(el.get("type", "element")))
        base_name = f"{idx:03d}_{el_type}_{el_notes}".strip("_")
        out_image = output_dir / f"{base_name}.png"
        out_prompt = output_dir / f"{base_name}.prompt.txt"
        if args.resume and out_image.exists():
            if args.verbose:
                print(f"[{idx}/{total}] Skip existing: {out_image}", flush=True)
            continue

        prompt = guard + " " + build_element_prompt(el)

        payload: Dict[str, Any] = {
            "model": args.model,
            "urls": [img_data_url],
            "prompt": prompt,
            "aspectRatio": args.aspect,
        }
        if args.image_size:
            payload["imageSize"] = args.image_size

        if args.verbose:
            print(f"[{idx}/{total}] Requesting: {base_name}", flush=True)
        last_err: Optional[str] = None
        for attempt in range(args.retries + 1):
            try:
                result = request_json(url, payload, api_key)
            except Exception as exc:
                last_err = f"{type(exc).__name__}: {exc}"
                if args.verbose:
                    print(f"[{idx}/{total}] attempt {attempt+1} error: {last_err}", flush=True)
                time.sleep(2.0 + attempt * 1.5)
                continue
            results = result.get("results") or []
            if results and results[0].get("url"):
                download_file(results[0]["url"], out_image)
                out_prompt.write_text(prompt + "\n", encoding="utf-8")
                print(f"Saved: {out_image}", flush=True)
                saved_count += 1
                break
            last_err = json.dumps(result, ensure_ascii=False)
            if args.verbose:
                print(f"[{idx}/{total}] attempt {attempt+1} no result URL", flush=True)
            time.sleep(1.5 + attempt * 1.5)
        else:
            raise RuntimeError(f"No result URL for {base_name}: {last_err}")

        # small pause to be polite to API
        time.sleep(0.4)

    print(f"Done. Extracted {saved_count} elements to {output_dir}", flush=True)


if __name__ == "__main__":
    main()
