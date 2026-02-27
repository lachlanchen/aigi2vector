#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: codex_generate_tikz_from_parts.sh \
  --original-image <path> \
  --extracted-dir <path> \
  --output-dir <path> \
  [--layout-json <path>] \
  [--model <name>] \
  [--reasoning <low|medium|high|xhigh>] \
  [--skip-git-check]

This prompt tool asks Codex to generate a TikZ .tex file that rebuilds the original layout
using extracted image parts.
USAGE
}

original_image=""
extracted_dir=""
output_dir=""
layout_json=""
model="gpt-5.3-codex"
reasoning="high"
skip_git_check=0

while [ $# -gt 0 ]; do
  case "$1" in
    --original-image) original_image="${2:-}"; shift ;;
    --extracted-dir) extracted_dir="${2:-}"; shift ;;
    --output-dir) output_dir="${2:-}"; shift ;;
    --layout-json) layout_json="${2:-}"; shift ;;
    --model) model="${2:-}"; shift ;;
    --reasoning) reasoning="${2:-}"; shift ;;
    --skip-git-check) skip_git_check=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
  shift
done

if [ -z "$original_image" ] || [ -z "$extracted_dir" ] || [ -z "$output_dir" ]; then
  echo "--original-image, --extracted-dir, and --output-dir are required." >&2
  exit 1
fi

case "$reasoning" in
  low|medium|high|xhigh) ;;
  *) echo "Invalid --reasoning '$reasoning'. Use low|medium|high|xhigh." >&2; exit 1 ;;
esac

if ! command -v codex >/dev/null 2>&1; then
  echo "codex CLI not found in PATH." >&2
  exit 1
fi

if [ ! -f "$original_image" ]; then
  echo "Original image not found: $original_image" >&2
  exit 1
fi

if [ ! -d "$extracted_dir" ]; then
  echo "Extracted dir not found: $extracted_dir" >&2
  exit 1
fi

if [ -n "$layout_json" ] && [ ! -f "$layout_json" ]; then
  echo "Layout JSON not found: $layout_json" >&2
  exit 1
fi

mkdir -p "$output_dir" "$output_dir/logs" "$output_dir/assets"

tex_file="$output_dir/slide_rebuild.tex"
manifest_file="$output_dir/assets_manifest.json"
prompt_file="$output_dir/logs/generate_tikz_prompt.txt"
resp_file="$output_dir/logs/generate_tikz_response.jsonl"
stderr_file="$output_dir/logs/codex_stderr.log"

copied_count=0
while IFS= read -r -d '' img; do
  cp -f "$img" "$output_dir/assets/$(basename "$img")"
  copied_count=$((copied_count + 1))
done < <(find "$extracted_dir" -maxdepth 1 -type f -name '*.png' -print0 | sort -z)

if [ "$copied_count" -eq 0 ]; then
  echo "No PNG files found in extracted dir: $extracted_dir" >&2
  exit 1
fi

orig_ext="$(python3 - "$original_image" <<'PY'
from pathlib import Path
import sys
print(Path(sys.argv[1]).suffix)
PY
)"
cp -f "$original_image" "$output_dir/assets/original_reference${orig_ext}"

python3 - "$output_dir/assets" "$manifest_file" "$layout_json" <<'PY'
import json
import sys
from pathlib import Path
import struct
import re

assets = Path(sys.argv[1])
out = Path(sys.argv[2])
layout_json = sys.argv[3]

layout_map = {}
if layout_json:
    try:
        raw = json.loads(Path(layout_json).read_text(encoding="utf-8"))
        for el in raw.get("elements", []):
            eid = str(el.get("id", "")).strip()
            if eid:
                layout_map[eid] = {
                    "label": el.get("label"),
                    "anchor": el.get("anchor"),
                    "bbox_norm": el.get("bbox_norm"),
                    "notes": el.get("notes"),
                    "include": el.get("include"),
                    "exclude": el.get("exclude"),
                }
    except Exception:
        layout_map = {}

items = []
for path in sorted(assets.glob("*.png")):
    data = path.read_bytes()
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        continue
    w, h = struct.unpack(">II", data[16:24])
    m = re.match(r"^\d+_(e\d+)_", path.name)
    eid = m.group(1) if m else ""
    layout = layout_map.get(eid, {})
    items.append({
        "filename": path.name,
        "width_px": w,
        "height_px": h,
        "suggested_id": path.stem,
        "element_id": eid,
        "label": layout.get("label"),
        "anchor": layout.get("anchor"),
        "bbox_norm": layout.get("bbox_norm"),
        "notes": layout.get("notes"),
        "include": layout.get("include"),
        "exclude": layout.get("exclude"),
    })
payload = {"assets_dir": str(assets), "parts": items}
if layout_json:
    payload["layout_json_path"] = layout_json
out.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
PY

cat > "$prompt_file" <<EOF
You are an expert at rebuilding scientific slide graphics as editable TikZ.

Goal:
- Reconstruct the original image structure using extracted part images.
- Keep the layout faithful to the source so the output is suitable for later vectorization/editing.

Current task:
- Read the attached original image for spatial reference.
- Read this parts manifest JSON: $manifest_file
- Use part images from this folder: $output_dir/assets
- Write a complete compilable XeLaTeX TikZ document to:
  $tex_file

Hard requirements:
- Output must be a full .tex document (not fragment).
- Use \\documentclass[tikz,border=0pt]{standalone}
- Use TikZ nodes with \\includegraphics for each extracted part image exactly once.
- Use element_id + bbox_norm from manifest as primary placement anchors.
- Recreate original composition order, spacing, and alignment.
- Add text labels to match the original structure (including Chinese labels when visible).
- Add connecting arrows/flow lines so the diagram logic matches original.
- Preserve the overall aspect ratio close to original.
- Use only local assets under ./assets/ (relative paths in includegraphics).
- Keep code clean: define reusable styles and dimensions near top.
- Add short comments for major sections.
- Ensure UTF-8 safe source.

Quality rules:
- Do not invent new objects.
- Do not drop major visible components.
- If exact text is uncertain, use the closest visible wording from the image.
- Do not spend time scanning unrelated files; all required metadata is in the manifest + attached image.

Execution requirements:
- Ensure parent directory exists.
- Write UTF-8 text directly to $tex_file.
- Final response must be exactly:
  WROTE $tex_file
EOF

cmd=(codex exec --json --full-auto -m "$model" -c "model_reasoning_effort=\"$reasoning\"")
if [ "$skip_git_check" -eq 1 ]; then
  cmd+=(--skip-git-repo-check)
fi
cmd+=(--image "$original_image" -)

tex_ready() {
  [ -s "$tex_file" ] && rg -q "\\\\end\\{document\\}" "$tex_file"
}

"${cmd[@]}" < "$prompt_file" > "$resp_file" 2>>"$stderr_file" &
pid=$!
elapsed=0
max_wait=180
ready_since=-1
while kill -0 "$pid" 2>/dev/null; do
  sleep 2
  elapsed=$((elapsed + 2))

  if tex_ready; then
    if [ "$ready_since" -lt 0 ]; then
      ready_since=$elapsed
    fi
    if [ $((elapsed - ready_since)) -ge 20 ]; then
      echo "Codex generation produced TeX and stayed active; stopping lingering process..." >&2
      kill "$pid" 2>/dev/null || true
      break
    fi
  fi

  if [ "$elapsed" -ge "$max_wait" ]; then
    echo "Codex generation timed out after ${max_wait}s; stopping process..." >&2
    kill "$pid" 2>/dev/null || true
    break
  fi
done
wait "$pid" 2>/dev/null || true

if [ ! -s "$tex_file" ]; then
  echo "Codex did not produce TeX in time. Writing fallback TeX from manifest..." >&2
  python3 - "$manifest_file" "$tex_file" <<'PY'
import json
import sys
from pathlib import Path

manifest = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
tex_path = Path(sys.argv[2])
parts = [p for p in manifest.get("parts", []) if p.get("filename") != "original_reference.png"]
parts = [p for p in parts if p.get("bbox_norm")]

def f(v):
    return f"{float(v):.4f}"

lines = []
lines.append(r"\documentclass[tikz,border=0pt]{standalone}")
lines.append(r"\usepackage{graphicx}")
lines.append(r"\usetikzlibrary{arrows.meta}")
lines.append(r"\newlength{\slideW}")
lines.append(r"\newlength{\slideH}")
lines.append(r"\setlength{\slideW}{26.67cm}")
lines.append(r"\setlength{\slideH}{15cm}")
lines.append(r"\tikzset{lbl/.style={font=\bfseries\small, align=center}, flow/.style={-Latex,draw=gray!70,line width=0.8pt}}")
lines.append(r"\begin{document}")
lines.append(r"\begin{tikzpicture}[x=\slideW,y=-\slideH]")
lines.append(r"\path[use as bounding box] (0,0) rectangle (1,1);")

for p in parts:
    b = p["bbox_norm"]
    x, y, w, h = f(b["x"]), f(b["y"]), f(b["w"]), f(b["h"])
    fn = p["filename"]
    lbl = (p.get("label") or p.get("element_id") or "").replace("&", r"\&")
    lines.append(rf"\node[anchor=north west,inner sep=0pt] ({p.get('element_id','part')}) at ({x},{y}) "
                 rf"{{\includegraphics[width={w}\slideW,height={h}\slideH]{{assets/{fn}}}}};")
    if lbl:
        lx = f(float(b["x"]) + float(b["w"]) / 2.0)
        ly = f(max(0.02, float(b["y"]) - 0.015))
        lines.append(rf"\node[lbl] at ({lx},{ly}) {{{lbl}}};")

if len(parts) > 1:
    ordered = sorted(parts, key=lambda p: float(p["bbox_norm"]["x"]))
    for a, b in zip(ordered[:-1], ordered[1:]):
        ax = float(a["bbox_norm"]["x"]) + float(a["bbox_norm"]["w"])
        ay = float(a["bbox_norm"]["y"]) + float(a["bbox_norm"]["h"]) * 0.5
        bx = float(b["bbox_norm"]["x"])
        by = float(b["bbox_norm"]["y"]) + float(b["bbox_norm"]["h"]) * 0.5
        lines.append(rf"\draw[flow] ({f(ax)},{f(ay)}) -- ({f(bx)},{f(by)});")

lines.append(r"\end{tikzpicture}")
lines.append(r"\end{document}")
tex_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
PY
fi

if [ ! -s "$tex_file" ]; then
  echo "Failed to produce $tex_file" >&2
  exit 1
fi

if ! rg -q "\\\\end\\{document\\}" "$tex_file"; then
  echo "Generated TeX is incomplete: missing \\end{document}" >&2
  exit 1
fi

echo "Wrote TikZ source: $tex_file"
echo "Manifest: $manifest_file"
echo "Response log: $resp_file"
