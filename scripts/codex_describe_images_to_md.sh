#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: codex_describe_images_to_md.sh --input-dir <path> --output-dir <path> [options]

Options:
  --input-dir <path>     Folder of images to describe
  --output-dir <path>    Output folder for markdown files
  --model <name>         Codex model (default: gpt-5.3-codex)
  --reasoning <level>    low|medium|high|xhigh (default: high)
  --skip-git-check       Pass --skip-git-repo-check to codex exec
  -h, --help             Show this help
USAGE
}

input_dir=""
output_dir=""
model="gpt-5.3-codex"
reasoning="high"
skip_git_check=0

while [ $# -gt 0 ]; do
  case "$1" in
    --input-dir)
      input_dir="${2:-}"
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

if [ -z "$input_dir" ] || [ -z "$output_dir" ]; then
  echo "--input-dir and --output-dir are required." >&2
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
You are a vision assistant that writes detailed, structured markdown descriptions of images.
You will be given one image at a time.

Global rules for ALL image tasks:
- Write markdown ONLY to the target file path given in the task.
- Do NOT put the markdown in chat.
- After writing the file, your final response must be exactly: WROTE <path>
- Be factual and grounded in the image. If uncertain, say so explicitly.
- Describe visible text verbatim when legible. If text is too small/blurred, say "unreadable".
EOF

run_codex_new_session_from_file "$init_prompt_file" "$init_json_file"
session_id="$(extract_session_id_from_jsonl "$init_json_file")"
if [ -z "$session_id" ]; then
  echo "Failed to capture session ID from initialization response." >&2
  exit 1
fi

echo "$session_id" > "$output_dir/.codex_session_id"

counter=0
for image in "${images[@]}"; do
  counter=$((counter + 1))
  base="$(basename "$image")"
  stem="${base%.*}"
  out_file="$output_dir/${stem}.md"
  tmp_file="$output_dir/${stem}.md.tmp"
  prompt_file="$output_dir/logs/prompt_${stem}.txt"
  json_file="$output_dir/logs/resp_${stem}.jsonl"

  cat > "$prompt_file" <<EOF
Goal: Produce a rich, redundant, and highly detailed markdown description of the attached image.
Current task: Describe every visible object, element, layout region, and readable text from this image.

Write the markdown directly to this file path:
$tmp_file

Constraints:
- Output must be markdown in English.
- The description must be detailed and explicit, even if it feels repetitive.
- Mention text content verbatim when legible.
- If a text region is not readable, say: "Text present but unreadable".
- Separate observations into clear sections.
- Do not infer beyond what is visible.

Required markdown structure inside the file:
# Image: $stem
## Overview
## Objects and elements (exhaustive list)
## Text (verbatim if readable)
## Spatial layout (top/middle/bottom/left/right)
## Notable visual attributes (colors, styles, icons)
## Uncertainty notes

Metadata:
- Image filename: $base
- Image path: $image

Execution requirements:
- Ensure parent directory exists.
- Write UTF-8 markdown directly to the target file.
- Final response must be exactly: WROTE $tmp_file
EOF

  echo "[$counter/${#images[@]}] Describing $base"
  run_codex_resume_from_file "$session_id" "$prompt_file" "$json_file" "$image"
  if [ ! -s "$tmp_file" ]; then
    echo "Codex did not produce output for $base" >&2
    exit 1
  fi
  mv -f "$tmp_file" "$out_file"

done

echo "Done. Wrote ${#images[@]} markdown files to $output_dir"
