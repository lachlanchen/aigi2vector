#!/usr/bin/env python3
"""Extract elements using a JSON prompt list and GRS AI Nano Banana API."""

import argparse
import base64
import json
import os
import re
import sys
import time
import urllib.request
from pathlib import Path
from typing import Any, Dict, Optional


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Extract elements using prompt JSON.")
    p.add_argument("--image", required=True, help="Path to input image")
    p.add_argument("--prompts", required=True, help="Path to prompts JSON")
    p.add_argument("--output-dir", required=True, help="Output directory")
    p.add_argument("--guard", required=True, help="Guard prompt to prepend")
    p.add_argument("--model", default="nano-banana-fast", help="Model name")
    p.add_argument("--host", default="https://grsai.dakka.com.cn", help="API host")
    p.add_argument("--aspect", default="auto", help="Aspect ratio")
    p.add_argument("--image-size", default="1K", help="Image size")
    p.add_argument("--retries", type=int, default=2, help="Retries per element")
    p.add_argument("--no-poll", action="store_true", help="Disable polling mode")
    p.add_argument("--poll-interval", type=float, default=3.0, help="Polling interval seconds")
    p.add_argument("--poll-timeout", type=float, default=600.0, help="Polling timeout seconds")
    p.add_argument("--verbose", action="store_true", help="Verbose logging")
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


def poll_result(host: str, task_id: str, api_key: str, interval: float, timeout_s: float, verbose: bool) -> Dict[str, Any]:
    url = host.rstrip("/") + "/v1/draw/result"
    payload = {"id": task_id}
    start = time.time()
    while True:
        result = request_json(url, payload, api_key)
        status = result.get("status") or (result.get("data") or {}).get("status")
        if verbose:
            print(f"poll status={status} id={task_id}", flush=True)
        if status in {"succeeded", "failed"}:
            return result
        if time.time() - start > timeout_s:
            raise RuntimeError(f"Polling timeout after {timeout_s}s for id {task_id}")
        time.sleep(interval)


def main() -> None:
    args = parse_args()
    api_key = os.environ.get("GRSAI")
    if not api_key:
        print("Missing GRSAI env var. Export GRSAI=...", file=sys.stderr)
        sys.exit(1)

    image_path = Path(args.image)
    prompts_path = Path(args.prompts)
    if not image_path.exists():
        raise FileNotFoundError(image_path)
    if not prompts_path.exists():
        raise FileNotFoundError(prompts_path)

    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    data = json.loads(prompts_path.read_text(encoding="utf-8"))
    prompts = data.get("prompts", [])
    if not prompts:
        raise RuntimeError("No prompts found in JSON")

    img_data_url = image_to_data_url(image_path)
    url = args.host.rstrip("/") + "/v1/draw/nano-banana"

    for idx, item in enumerate(prompts, start=1):
        label = sanitize(str(item.get("label", f"item_{idx}")))
        pid = sanitize(str(item.get("id", f"e{idx:02d}")))
        prompt = args.guard + " " + str(item.get("prompt", ""))

        out_image = output_dir / f"{idx:03d}_{pid}_{label}.png"
        out_prompt = output_dir / f"{idx:03d}_{pid}_{label}.prompt.txt"

        if args.verbose:
            print(f"[{idx}/{len(prompts)}] Requesting {out_image.name}", flush=True)

        payload: Dict[str, Any] = {
            "model": args.model,
            "urls": [img_data_url],
            "prompt": prompt,
            "aspectRatio": args.aspect,
        }
        if args.image_size:
            payload["imageSize"] = args.image_size
        if not args.no_poll:
            payload["webHook"] = "-1"
            payload["shutProgress"] = True

        last_err: Optional[str] = None
        for attempt in range(args.retries + 1):
            if args.verbose:
                print(f"[{idx}] attempt {attempt+1} sending request...", flush=True)
            try:
                result = request_json(url, payload, api_key)
            except Exception as exc:
                last_err = f"{type(exc).__name__}: {exc}"
                if args.verbose:
                    print(f"[{idx}] attempt {attempt+1} error: {last_err}", flush=True)
                time.sleep(2.0 + attempt * 1.5)
                continue
            if not args.no_poll:
                task_id = result.get("id") or (result.get("data") or {}).get("id")
                if not task_id:
                    last_err = json.dumps(result, ensure_ascii=False)
                    if args.verbose:
                        print(f"[{idx}] attempt {attempt+1} missing id. Response: {last_err}", flush=True)
                    time.sleep(1.5 + attempt * 1.5)
                    continue
                final = poll_result(args.host, task_id, api_key, args.poll_interval, args.poll_timeout, args.verbose)
                results = final.get("results") or (final.get("data") or {}).get("results") or []
                if results and results[0].get("url"):
                    download_file(results[0]["url"], out_image)
                    out_prompt.write_text(prompt + "\n", encoding="utf-8")
                    if args.verbose:
                        print(f"[{idx}] Saved: {out_image}", flush=True)
                    break
                last_err = json.dumps(final, ensure_ascii=False)
                if args.verbose:
                    print(f"[{idx}] attempt {attempt+1} no result URL after poll. Response: {last_err}", flush=True)
                time.sleep(1.5 + attempt * 1.5)
            else:
                results = result.get("results") or []
                if results and results[0].get("url"):
                    download_file(results[0]["url"], out_image)
                    out_prompt.write_text(prompt + "\n", encoding="utf-8")
                    if args.verbose:
                        print(f"[{idx}] Saved: {out_image}", flush=True)
                    break
                last_err = json.dumps(result, ensure_ascii=False)
                if args.verbose:
                    print(f"[{idx}] attempt {attempt+1} no result URL. Response: {last_err}", flush=True)
                time.sleep(1.5 + attempt * 1.5)
        else:
            raise RuntimeError(f"No result URL for {out_image.name}: {last_err}")

        time.sleep(0.4)

    print(f"Done. Extracted {len(prompts)} elements to {output_dir}", flush=True)


if __name__ == "__main__":
    main()
