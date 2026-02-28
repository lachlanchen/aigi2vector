#!/usr/bin/env python3
"""Extract elements using a JSON prompt list and GRS AI Nano Banana API."""

import argparse
import base64
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
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
    p.add_argument(
        "--max-side",
        type=int,
        default=0,
        help="Optional resize max side (pixels) for upload image via sips; 0 disables",
    )
    p.add_argument("--retries", type=int, default=2, help="Retries per element")
    p.add_argument("--no-poll", action="store_true", help="Disable polling mode")
    p.add_argument("--poll-interval", type=float, default=3.0, help="Polling interval seconds")
    p.add_argument("--poll-timeout", type=float, default=600.0, help="Polling timeout seconds")
    p.add_argument(
        "--stalled-timeout",
        type=float,
        default=120.0,
        help="Fail and retry if poll status/progress does not change for this many seconds",
    )
    p.add_argument("--resume", action="store_true", help="Skip existing output files")
    p.add_argument(
        "--enforce-no-text-pass",
        action="store_true",
        help="After extraction, run an extra redraw pass to aggressively remove any remaining text",
    )
    p.add_argument(
        "--no-text-pass-retries",
        type=int,
        default=1,
        help="Retries for the no-text cleanup pass",
    )
    p.add_argument("--verbose", action="store_true", help="Verbose logging")
    return p.parse_args()


def _as_int(value: Any, fallback: int) -> int:
    try:
        return int(value)
    except Exception:
        return fallback


def sanitize(text: str) -> str:
    if not text:
        return "none"
    text = text.lower().strip()
    text = re.sub(r"[^a-z0-9_-]+", "_", text)
    text = re.sub(r"_+", "_", text).strip("_")
    return text or "none"


ALLOWED_ASPECTS = {
    "auto",
    "1:1",
    "16:9",
    "9:16",
    "4:3",
    "3:4",
    "3:2",
    "2:3",
    "5:4",
    "4:5",
    "21:9",
}


def pick_aspect(item: Dict[str, Any], default_aspect: str) -> str:
    raw = str(item.get("aspect_ratio", default_aspect)).strip()
    return raw if raw in ALLOWED_ASPECTS else default_aspect


def image_to_data_url(path: Path) -> str:
    mime = "image/png"
    if path.suffix.lower() in {".jpg", ".jpeg"}:
        mime = "image/jpeg"
    elif path.suffix.lower() == ".webp":
        mime = "image/webp"
    data = path.read_bytes()
    b64 = base64.b64encode(data).decode("utf-8")
    return f"data:{mime};base64,{b64}"


def prepare_upload_image(path: Path, max_side: int, verbose: bool) -> tuple[Path, Optional[tempfile.TemporaryDirectory[str]]]:
    if max_side <= 0:
        return path, None
    if shutil.which("sips") is None:
        if verbose:
            print("sips not found; using original image for upload", flush=True)
        return path, None

    tmpdir = tempfile.TemporaryDirectory(prefix="grsai_upload_")
    out = Path(tmpdir.name) / f"{path.stem}_upload.jpg"
    cmd = ["sips", "-Z", str(max_side), str(path), "--out", str(out)]
    try:
        subprocess.run(cmd, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except Exception as exc:
        if verbose:
            print(f"image resize failed ({exc}); using original image", flush=True)
        tmpdir.cleanup()
        return path, None
    if verbose:
        orig_mb = path.stat().st_size / (1024 * 1024)
        new_mb = out.stat().st_size / (1024 * 1024)
        print(f"upload image resized: {path.name} {orig_mb:.2f}MB -> {out.name} {new_mb:.2f}MB", flush=True)
    return out, tmpdir


def request_raw(url: str, payload: Dict[str, Any], api_key: str) -> str:
    body = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(url, data=body, method="POST")
    req.add_header("Content-Type", "application/json")
    req.add_header("Authorization", f"Bearer {api_key}")
    with urllib.request.urlopen(req, timeout=120) as resp:
        raw = resp.read().decode("utf-8", errors="ignore")
    return raw


def parse_json(raw: str) -> Dict[str, Any]:
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


def download_file(url: str, dest: Path, retries: int = 3, verbose: bool = False) -> None:
    last_err: Optional[Exception] = None
    for i in range(retries + 1):
        try:
            with urllib.request.urlopen(url, timeout=120) as resp:
                dest.write_bytes(resp.read())
            return
        except Exception as exc:
            last_err = exc
            if verbose:
                print(f"download attempt {i+1} failed: {exc}", flush=True)
            time.sleep(1.5 + i)
    raise RuntimeError(f"Failed to download {url}: {last_err}")


def enforce_no_text_cleanup(
    image_path: Path,
    model: str,
    host: str,
    api_key: str,
    aspect: str,
    image_size: str,
    poll_interval: float,
    poll_timeout: float,
    stalled_timeout: float,
    retries: int,
    verbose: bool,
) -> bool:
    prompt = (
        "Text-removal cleanup pass for this extracted element. "
        "Keep object geometry, colors, and layout unchanged. "
        "Remove ALL text and glyphs: letters, words, numbers, Chinese characters, labels, captions, annotations, symbols used as text. "
        "NO TEXT. NO TEXT. NO TEXT. NO TEXT. NO TEXT. "
        "Do not add new content. Keep clean standalone object with tight framing."
    )
    url = host.rstrip("/") + "/v1/draw/nano-banana"
    data_url = image_to_data_url(image_path)

    payload: Dict[str, Any] = {
        "model": model,
        "urls": [data_url],
        "prompt": prompt,
        "aspectRatio": aspect,
        "webHook": "-1",
        "shutProgress": True,
    }
    if image_size:
        payload["imageSize"] = image_size

    for attempt in range(retries + 1):
        try:
            raw = request_raw(url, payload, api_key)
            result = parse_json(raw)
            task_id = result.get("id") or (result.get("data") or {}).get("id")
            if not task_id:
                if verbose:
                    print(f"no-text pass attempt {attempt+1}: missing task id", flush=True)
                time.sleep(1.5 + attempt)
                continue
            final = poll_result(host, task_id, api_key, poll_interval, poll_timeout, stalled_timeout, verbose)
            results = final.get("results") or (final.get("data") or {}).get("results") or []
            if not results or not results[0].get("url"):
                if verbose:
                    print(f"no-text pass attempt {attempt+1}: no result URL", flush=True)
                time.sleep(1.5 + attempt)
                continue
            tmp = image_path.with_suffix(".tmp_clean.png")
            download_file(results[0]["url"], tmp, retries=2, verbose=verbose)
            tmp.replace(image_path)
            return True
        except Exception as exc:
            if verbose:
                print(f"no-text pass attempt {attempt+1} failed: {exc}", flush=True)
            time.sleep(1.5 + attempt)
    return False


def poll_result(
    host: str,
    task_id: str,
    api_key: str,
    interval: float,
    timeout_s: float,
    stalled_timeout_s: float,
    verbose: bool,
) -> Dict[str, Any]:
    url = host.rstrip("/") + "/v1/draw/result"
    payload = {"id": task_id}
    start = time.time()
    last_signature: Optional[tuple] = None
    last_change = start
    while True:
        raw = request_raw(url, payload, api_key)
        result = parse_json(raw)
        data = result.get("data") or {}
        status = result.get("status") or data.get("status")
        progress = result.get("progress")
        if progress is None:
            progress = data.get("progress")
        signature = (status, progress, data.get("start_time"), data.get("end_time"))
        if signature != last_signature:
            last_signature = signature
            last_change = time.time()
        if verbose:
            print(f"poll status={status} id={task_id} response={json.dumps(result, ensure_ascii=False)}", flush=True)
        if status in {"succeeded", "failed"}:
            return result
        if time.time() - start > timeout_s:
            raise RuntimeError(f"Polling timeout after {timeout_s}s for id {task_id}")
        if time.time() - last_change > stalled_timeout_s:
            raise RuntimeError(f"Polling stalled for {stalled_timeout_s}s for id {task_id}")
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
    prompts = sorted(
        prompts,
        key=lambda item: (
            _as_int(item.get("order"), 10**9),
            _as_int(item.get("level"), 10**9),
            str(item.get("id", "")),
        ),
    )

    log_dir = output_dir / "logs"
    log_dir.mkdir(parents=True, exist_ok=True)

    upload_image_path, tmpdir = prepare_upload_image(image_path, args.max_side, args.verbose)
    try:
        img_data_url = image_to_data_url(upload_image_path)
        url = args.host.rstrip("/") + "/v1/draw/nano-banana"

        for idx, item in enumerate(prompts, start=1):
            label = sanitize(str(item.get("label", f"item_{idx}")))
            pid = sanitize(str(item.get("id", f"e{idx:02d}")))
            prompt = args.guard + " " + str(item.get("prompt", ""))

            out_image = output_dir / f"{idx:03d}_{pid}_{label}.png"
            out_prompt = output_dir / f"{idx:03d}_{pid}_{label}.prompt.txt"
            if args.resume and out_image.exists():
                if args.verbose:
                    print(f"[{idx}/{len(prompts)}] Skip existing {out_image.name}", flush=True)
                continue

            if args.verbose:
                print(f"[{idx}/{len(prompts)}] Requesting {out_image.name}", flush=True)

            aspect = pick_aspect(item, args.aspect)
            payload: Dict[str, Any] = {
                "model": args.model,
                "urls": [img_data_url],
                "prompt": prompt,
                "aspectRatio": aspect,
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
                    if args.verbose:
                        print(f"[{idx}] sending payload size={len(json.dumps(payload))} bytes", flush=True)
                        print(f"[{idx}] using aspectRatio={aspect}", flush=True)
                    raw = request_raw(url, payload, api_key)
                    result = parse_json(raw)
                except Exception as exc:
                    last_err = f"{type(exc).__name__}: {exc}"
                    if args.verbose:
                        print(f"[{idx}] attempt {attempt+1} error: {last_err}", flush=True)
                    time.sleep(2.0 + attempt * 1.5)
                    continue
                if args.verbose:
                    print(f"[{idx}] initial response: {json.dumps(result, ensure_ascii=False)}", flush=True)
                # Persist raw response for debugging
                (log_dir / f"resp_{idx:03d}.raw.txt").write_text(raw, encoding="utf-8")
                if not args.no_poll:
                    task_id = result.get("id") or (result.get("data") or {}).get("id")
                    if not task_id:
                        last_err = json.dumps(result, ensure_ascii=False)
                        if args.verbose:
                            print(f"[{idx}] attempt {attempt+1} missing id. Response: {last_err}", flush=True)
                        time.sleep(1.5 + attempt * 1.5)
                        continue
                    final = poll_result(
                        args.host,
                        task_id,
                        api_key,
                        args.poll_interval,
                        args.poll_timeout,
                        args.stalled_timeout,
                        args.verbose,
                    )
                    (log_dir / f"poll_{idx:03d}.json").write_text(json.dumps(final, ensure_ascii=False, indent=2), encoding="utf-8")
                    results = final.get("results") or (final.get("data") or {}).get("results") or []
                    if results and results[0].get("url"):
                        download_file(results[0]["url"], out_image, retries=3, verbose=args.verbose)
                        if args.enforce_no_text_pass:
                            if args.verbose:
                                print(f"[{idx}] running no-text cleanup pass...", flush=True)
                            ok = enforce_no_text_cleanup(
                                out_image,
                                args.model,
                                args.host,
                                api_key,
                                aspect,
                                args.image_size,
                                args.poll_interval,
                                args.poll_timeout,
                                args.stalled_timeout,
                                args.no_text_pass_retries,
                                args.verbose,
                            )
                            if not ok:
                                last_err = "no-text cleanup pass failed"
                                if out_image.exists():
                                    out_image.unlink(missing_ok=True)
                                time.sleep(1.5 + attempt * 1.5)
                                continue
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
                        download_file(results[0]["url"], out_image, retries=3, verbose=args.verbose)
                        if args.enforce_no_text_pass:
                            if args.verbose:
                                print(f"[{idx}] running no-text cleanup pass...", flush=True)
                            ok = enforce_no_text_cleanup(
                                out_image,
                                args.model,
                                args.host,
                                api_key,
                                aspect,
                                args.image_size,
                                args.poll_interval,
                                args.poll_timeout,
                                args.stalled_timeout,
                                args.no_text_pass_retries,
                                args.verbose,
                            )
                            if not ok:
                                last_err = "no-text cleanup pass failed"
                                if out_image.exists():
                                    out_image.unlink(missing_ok=True)
                                time.sleep(1.5 + attempt * 1.5)
                                continue
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
    finally:
        if tmpdir is not None:
            tmpdir.cleanup()


if __name__ == "__main__":
    main()
