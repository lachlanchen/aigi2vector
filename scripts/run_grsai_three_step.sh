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
Task: Analyze the attached image and write a JSON file listing self-contained standalone visual elements for downstream redraw extraction.

Write JSON directly to this file path (do NOT output JSON in chat):
__OUTPUT_PATH__

Rules:
- Segment into self-contained parts that are reusable independently.
- Do NOT make segments too large (avoid merging unrelated modules).
- Do NOT make segments too small (avoid tiny fragments that are not independently meaningful).
- Target 6-10 elements for this image unless the image structure clearly requires fewer/more.
- Each segment must represent one coherent component only.
- If two components can stand alone separately, split them.
- Omit pure text labels/captions; keep focus on visual components.
- Provide clear include/exclude cues to prevent boundary drift in redraw.
- Provide normalized bounding boxes to define the intended region precisely.
- Output JSON only.

Schema:
{
  "image": {"path": "..."},
  "segmentation_notes": "brief summary of segmentation strategy",
  "elements": [
    {
      "id": "e01",
      "type": "diagram|photo|panel|icon|chart|table|other",
      "label": "short name",
      "anchor": "approximate region (top-left/top-center/top-right/middle-left/middle/middle-right/bottom-left/bottom/bottom-right)",
      "bbox_norm": {"x": 0.12, "y": 0.25, "w": 0.24, "h": 0.33},
      "notes": "detailed visual description of what is included",
      "include": ["keyword1", "keyword2"],
      "exclude": ["nearby object that must not be included", "another nearby object"]
    }
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
- Be detailed and specific to exactly one element.
- Use `anchor`, `bbox_norm`, `include`, and `exclude` from the input JSON to define boundaries.
- Require faithful redraw from source image (not crop, not redesign).
- Require no text in output.
- Require zero margin and zero padding; element must fully occupy the canvas.
- Require the subject to fill >=90% of the output area unless shape inherently needs whitespace.
- Require that excluded nearby objects are not present.
- Require unchanged geometry, proportions, orientation, colors, and internal structure.
- Add explicit failure criteria when output includes extra regions.
- Add a recommended `aspect_ratio` for each element chosen from:
  auto, 1:1, 16:9, 9:16, 4:3, 3:4, 3:2, 2:3, 5:4, 4:5, 21:9.
- Prefer choosing aspect ratio from bbox width/height so the element occupies canvas tightly.

Output schema:
{
  "image": {"path": "..."},
  "prompts": [
    {
      "id": "e01",
      "label": "...",
      "aspect_ratio": "4:3",
      "prompt": "detailed redraw prompt"
    }
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
GUARD_PROMPT="You are redrawing one isolated element from the given image. Redraw only the requested element; do not crop the full image. Preserve exact geometry, proportions, orientation, colors, and internal structure from the source. Do NOT add or invent content. Remove all text. Output must have zero margin and zero padding, with the element fully occupying the canvas. Target >=90% canvas occupancy for the subject unless impossible due to shape. If any excluded neighboring object appears, the output is invalid."

echo "[Step 3/3] Extracting elements via GRS AI..."
python3 /Users/lachlanchen/Documents/iProjects/aigi2vector/scripts/extract_elements_from_prompt_json.py \
  --image "$IMAGE_PATH" \
  --prompts "$STEP2_JSON" \
  --output-dir "$OUT_DIR/extracted" \
  --guard "$GUARD_PROMPT" \
  --verbose

echo "Done. Outputs in $OUT_DIR/extracted"
