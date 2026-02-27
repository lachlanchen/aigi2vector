#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: codex_extract_layout_elements_v2.sh --input-dir <images> --md-dir <markdown> --output-dir <path> [options]

Options:
  --input-dir <path>     Folder of images (png/jpg/webp)
  --md-dir <path>        Folder of markdown descriptions (same basenames)
  --output-dir <path>    Output folder for JSON layout files
  --model <name>         Codex model (default: gpt-5.3-codex)
  --reasoning <level>    low|medium|high|xhigh (default: high)
  --session-per-image    Start a fresh Codex session per image (more robust)
  --skip-git-check       Pass --skip-git-repo-check to codex exec
  -h, --help             Show this help
USAGE
}

input_dir=""
md_dir=""
output_dir=""
model="gpt-5.3-codex"
reasoning="high"
skip_git_check=0
session_per_image=0

while [ $# -gt 0 ]; do
  case "$1" in
    --input-dir)
      input_dir="${2:-}"
      shift
      ;;
    --md-dir)
      md_dir="${2:-}"
      shift
      ;;
    --output-dir)
      output_dir="${2:-}"
      shift
      ;;
    --model)
      model="${2:-}"
      shift
      ;;
    --reasoning)
      reasoning="${2:-}"
      shift
      ;;
    --session-per-image)
      session_per_image=1
      ;;
    --skip-git-check)
      skip_git_check=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
 done

if [ -z "$input_dir" ] || [ -z "$md_dir" ] || [ -z "$output_dir" ]; then
  echo "--input-dir, --md-dir, and --output-dir are required." >&2
  exit 1
fi

case "$reasoning" in
  low|medium|high|xhigh) ;;
  *)
    echo "Invalid --reasoning '$reasoning'. Use: low|medium|high|xhigh." >&2
    exit 1
    ;;
 esac

if ! command -v codex >/dev/null 2>&1; then
  echo "codex CLI not found in PATH." >&2
  exit 1
fi

if [ ! -d "$input_dir" ]; then
  echo "Input directory not found: $input_dir" >&2
  exit 1
fi

if [ ! -d "$md_dir" ]; then
  echo "Markdown directory not found: $md_dir" >&2
  exit 1
fi

mkdir -p "$output_dir" "$output_dir/logs"

codex_stderr_log="$output_dir/logs/codex_stderr.log"

extract_session_id_from_jsonl() {
  local json_file="$1"
  python3 - "$json_file" <<'PY'
import json
import sys

thread_id = ""
with open(sys.argv[1], "r", encoding="utf-8") as handle:
    for line in handle:
        try:
            obj = json.loads(line)
        except Exception:
            continue
        if isinstance(obj, dict):
            thread_id = obj.get("thread_id") or obj.get("session_id") or thread_id
            if not thread_id:
                thread = obj.get("thread")
                if isinstance(thread, dict):
                    thread_id = thread.get("id") or thread_id
        if thread_id:
            break
print(thread_id)
PY
}

run_codex_new_session_from_file() {
  local prompt_file="$1"
  local json_file="$2"
  local cmd=(codex exec --json --full-auto -m "$model" -c "model_reasoning_effort=\"$reasoning\"")
  if [ "$skip_git_check" -eq 1 ]; then
    cmd+=(--skip-git-repo-check)
  fi
  cmd+=(-)
  "${cmd[@]}" < "$prompt_file" > "$json_file" 2>>"$codex_stderr_log"
}

run_codex_new_session_with_image() {
  local prompt_file="$1"
  local json_file="$2"
  local image_file="$3"
  local cmd=(codex exec --json --full-auto -m "$model" -c "model_reasoning_effort=\"$reasoning\"")
  if [ "$skip_git_check" -eq 1 ]; then
    cmd+=(--skip-git-repo-check)
  fi
  cmd+=(--image "$image_file" -)
  "${cmd[@]}" < "$prompt_file" > "$json_file" 2>>"$codex_stderr_log"
}

run_codex_resume_from_file() {
  local current_session_id="$1"
  local prompt_file="$2"
  local json_file="$3"
  local image_file="$4"
  local cmd=(codex exec resume "$current_session_id" --json --full-auto -m "$model" -c "model_reasoning_effort=\"$reasoning\"")
  if [ "$skip_git_check" -eq 1 ]; then
    cmd+=(--skip-git-repo-check)
  fi
  cmd+=(--image "$image_file" -)
  "${cmd[@]}" < "$prompt_file" > "$json_file" 2>>"$codex_stderr_log"
}

images=()
while IFS= read -r -d '' img; do
  images+=("$img")
 done < <(find "$input_dir" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) -print0 | sort -z)

if [ "${#images[@]}" -eq 0 ]; then
  echo "No images found in $input_dir" >&2
  exit 1
fi

init_prompt_file="$output_dir/logs/00_init_prompt.txt"
init_json_file="$output_dir/logs/00_init_response.jsonl"
cat > "$init_prompt_file" <<'EOF'
You are a vision assistant that extracts layout elements with bounding boxes from images.
You will be given one image at a time, plus a markdown description for context.

Global rules:
- Output must be a single JSON object written to the target file path given in the task.
- Do NOT put the JSON in chat.
- After writing the file, your final response must be exactly: WROTE <path>
- Coordinates must be integers in pixel units.
- Bounding boxes are in image coordinate space with origin (0,0) at the top-left.
- Each element must include: type, text (if any), x, y, width, height, confidence, notes.
- Be factual and grounded in the image. If uncertain, say so in notes.
EOF

session_id=""
if [ "$session_per_image" -eq 0 ]; then
  run_codex_new_session_from_file "$init_prompt_file" "$init_json_file"
  session_id="$(extract_session_id_from_jsonl "$init_json_file")"
  if [ -z "$session_id" ]; then
    echo "Failed to capture session ID from initialization response." >&2
    exit 1
  fi
  echo "$session_id" > "$output_dir/.codex_session_id"
fi

counter=0
for image in "${images[@]}"; do
  counter=$((counter + 1))
  base="$(basename "$image")"
  stem="${base%.*}"
  md_path="$md_dir/${stem}.md"
  if [ ! -f "$md_path" ]; then
    echo "Missing markdown for $base: $md_path" >&2
    exit 1
  fi

  out_file="$output_dir/${stem}.json"
  tmp_file="$output_dir/${stem}.json.tmp"
  prompt_file="$output_dir/logs/prompt_${stem}.txt"
  json_file="$output_dir/logs/resp_${stem}.jsonl"

  if [ -s "$out_file" ]; then
    echo "[$counter/${#images[@]}] Skipping $base (already exists)"
    continue
  fi

  cat > "$prompt_file" <<EOF
Goal: Extract major, reusable visual elements with accurate bounding boxes.
Current task: Read the FULL image at a glance, then identify the major standalone elements. Avoid over-splitting large images. If an element is a cohesive diagram, illustration, or photo, keep it intact as one box. Only split into sub-elements when they are clearly distinct and reusable.

Write the JSON directly to this file path:
$tmp_file

Input context (markdown description of this image):
---
$(cat "$md_path")
---

Output JSON schema (single object):
{
  "image": {
    "filename": "${base}",
    "path": "${image}"
  },
  "elements": [
    {
      "type": "text|image|icon|arrow|shape|chart|table|diagram|logo|photo|other",
      "text": "verbatim text or empty string",
      "x": 0,
      "y": 0,
      "width": 0,
      "height": 0,
      "confidence": 0.0,
      "notes": "brief note if uncertain"
    }
  ],
  "notes": "overall uncertainties or caveats"
}

Constraints:
- Use integer pixels for x, y, width, height.
- Bounding boxes should tightly wrap each element.
- Prefer larger, coherent groupings over fragmented parts for diagrams/photos/illustrations.
- Include text elements as separate entries ONLY when the text is a standalone label, title, or caption.
- If text is part of an image/diagram and not a standalone label, keep it inside the parent element.
- Use "text" type for standalone text labels/titles; put the exact text in the "text" field.
- If text is unreadable, include the element with text="" and note "unreadable".
- Do not infer beyond what is visible.

Execution requirements:
- Ensure parent directory exists.
- Write UTF-8 JSON directly to the target file.
- Final response must be exactly: WROTE $tmp_file
EOF

  echo "[$counter/${#images[@]}] Extracting layout for $base"
  if [ "$session_per_image" -eq 1 ]; then
    run_codex_new_session_with_image "$prompt_file" "$json_file" "$image"
  else
    run_codex_resume_from_file "$session_id" "$prompt_file" "$json_file" "$image"
  fi

  if [ ! -s "$tmp_file" ]; then
    echo "Codex did not produce output for $base" >&2
    exit 1
  fi
  mv -f "$tmp_file" "$out_file"

done

echo "Done. Wrote ${#images[@]} JSON files to $output_dir"
