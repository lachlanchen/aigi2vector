#!/usr/bin/env bash
set -euo pipefail

# Step-by-step pipeline using codex exec + GRS AI extraction.

IMAGE_PATH="$1"
OUT_DIR="$2"
MODEL="${3:-gpt-5.3-codex}"
REASONING="${4:-high}"

if [ -z "$IMAGE_PATH" ] || [ -z "$OUT_DIR" ]; then
  echo "Usage: $0 /path/to/image.png /path/to/output_dir [codex_model] [reasoning]" >&2
  exit 1
fi

if ! command -v codex >/dev/null 2>&1; then
  echo "codex CLI not found in PATH" >&2
  exit 1
fi

mkdir -p "$OUT_DIR/logs"

STEP1_JSON="$OUT_DIR/01_main_elements.json"
STEP2_JSON="$OUT_DIR/02_element_prompts.json"
STEP1_PROMPT="$OUT_DIR/logs/01_prompt.txt"
STEP1_JSONL="$OUT_DIR/logs/01_response.jsonl"
STEP2_PROMPT="$OUT_DIR/logs/02_prompt.txt"
STEP2_JSONL="$OUT_DIR/logs/02_response.jsonl"

# Step 1: detect main standalone elements and write JSON
cat > "$STEP1_PROMPT" <<'EOF'
Task: Analyze the attached image and write a JSON file listing the main standalone visual elements.

Write JSON directly to this file path (do NOT output JSON in chat):
__OUTPUT_PATH__

Rules:
- Focus on major standalone elements that can be extracted as reusable parts.
- Prefer larger coherent components (photos, panels, diagrams) rather than tiny subparts.
- Include key text labels only if they are standalone titles/captions; otherwise omit text-only elements.
- Provide detailed notes for each element so a follow-up prompt can target it precisely.
- Output JSON only.

Schema:
{
  "image": {"path": "..."},
  "elements": [
    {"id": "e01", "type": "diagram|photo|panel|icon|chart|table|other", "label": "short name", "notes": "detailed description"}
  ]
}

Execution requirements:
- Ensure parent directory exists.
- Write UTF-8 JSON directly to the target file.
- Final response must be exactly: WROTE __OUTPUT_PATH__
EOF

sed -i '' "s|__OUTPUT_PATH__|$STEP1_JSON|g" "$STEP1_PROMPT"

echo "[Step 1/3] Extracting main elements JSON..."
codex exec --json --full-auto -m "$MODEL" -c "model_reasoning_effort=\"$REASONING\"" --skip-git-repo-check --image "$IMAGE_PATH" - < "$STEP1_PROMPT" > "$STEP1_JSONL"

# Step 2: generate detailed prompts per element and write JSON
cat > "$STEP2_PROMPT" <<'EOF'
Task: Read the elements JSON and generate a dedicated redraw prompt for each element.

Input JSON file:
__INPUT_PATH__

Write JSON directly to this file path (do NOT output JSON in chat):
__OUTPUT_PATH__

Rules for each prompt:
- Be detailed and specific to the element described in notes.
- Ask to preserve layout, colors, and geometry from the original image.
- Require no text in the output.
- Require a tight framing with no margin and a plain/transparent background.
- Explicitly state the output must be a redraw (not a crop).
- Emphasize that anything outside the element is incorrect.
- Emphasize that the output must match the element as seen in the source image.

Output schema:
{
  "image": {"path": "..."},
  "prompts": [
    {"id": "e01", "label": "...", "prompt": "..."}
  ]
}

Execution requirements:
- Ensure parent directory exists.
- Write UTF-8 JSON directly to the target file.
- Final response must be exactly: WROTE __OUTPUT_PATH__
EOF

sed -i '' "s|__INPUT_PATH__|$STEP1_JSON|g" "$STEP2_PROMPT"
sed -i '' "s|__OUTPUT_PATH__|$STEP2_JSON|g" "$STEP2_PROMPT"

echo "[Step 2/3] Generating detailed prompts..."
codex exec --json --full-auto -m "$MODEL" -c "model_reasoning_effort=\"$REASONING\"" --skip-git-repo-check - < "$STEP2_PROMPT" > "$STEP2_JSONL"

# Step 3: run extraction for each element prompt
GUARD_PROMPT="You are redrawing a part from the given image. Output must be a faithful redraw, not a crop. Preserve geometry, layout, and visual style. Do NOT add or invent content. Remove ALL text. Output only the requested element with tight framing and no margin or background. If any other region appears, the output is wrong. Keep colors and shapes faithful to the original."

echo "[Step 3/3] Extracting elements via GRS AI..."
python3 /Users/lachlanchen/Documents/iProjects/aigi2vector/scripts/extract_elements_from_prompt_json.py \
  --image "$IMAGE_PATH" \
  --prompts "$STEP2_JSON" \
  --output-dir "$OUT_DIR/extracted" \
  --guard "$GUARD_PROMPT" \
  --verbose

echo "Done. Outputs in $OUT_DIR/extracted"
