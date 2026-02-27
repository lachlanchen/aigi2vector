#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: run_tikz_prompt_pipeline.sh \
  --original-image <path> \
  --extracted-dir <path> \
  --output-root <path> \
  [--model <name>] \
  [--reasoning <low|medium|high|xhigh>] \
  [--skip-git-check]

Pipeline:
1) Prompt tool generates TikZ .tex from extracted parts.
2) Prompt tool compiles .tex to PDF.
USAGE
}

original_image=""
extracted_dir=""
output_root=""
model="gpt-5.3-codex"
reasoning="high"
skip_git_check=0

while [ $# -gt 0 ]; do
  case "$1" in
    --original-image) original_image="${2:-}"; shift ;;
    --extracted-dir) extracted_dir="${2:-}"; shift ;;
    --output-root) output_root="${2:-}"; shift ;;
    --model) model="${2:-}"; shift ;;
    --reasoning) reasoning="${2:-}"; shift ;;
    --skip-git-check) skip_git_check=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
  shift
done

if [ -z "$original_image" ] || [ -z "$extracted_dir" ] || [ -z "$output_root" ]; then
  echo "--original-image, --extracted-dir, and --output-root are required." >&2
  exit 1
fi

mkdir -p "$output_root"
tex_dir="$output_root/tex"
pdf_dir="$output_root/pdf"
layout_json=""
parent_dir="$(cd "$extracted_dir/.." && pwd)"
if [ -f "$parent_dir/01_main_elements.json" ]; then
  layout_json="$parent_dir/01_main_elements.json"
fi
layout_args=()
if [ -n "$layout_json" ]; then
  layout_args=(--layout-json "$layout_json")
fi

common_args=(--model "$model" --reasoning "$reasoning")
if [ "$skip_git_check" -eq 1 ]; then
  common_args+=(--skip-git-check)
fi

echo "[1/2] Generating TikZ source with Codex prompt tool..."
bash /Users/lachlanchen/Documents/iProjects/aigi2vector/scripts/codex_generate_tikz_from_parts.sh \
  --original-image "$original_image" \
  --extracted-dir "$extracted_dir" \
  --output-dir "$tex_dir" \
  "${layout_args[@]}" \
  "${common_args[@]}"

tex_file="$tex_dir/slide_rebuild.tex"
if [ ! -s "$tex_file" ]; then
  echo "Missing generated TeX file: $tex_file" >&2
  exit 1
fi

echo "[2/2] Compiling TikZ to PDF with Codex prompt tool..."
bash /Users/lachlanchen/Documents/iProjects/aigi2vector/scripts/codex_compile_tikz_pdf.sh \
  --tex-file "$tex_file" \
  --output-dir "$pdf_dir" \
  "${common_args[@]}"

echo "Done."
echo "TeX: $tex_file"
echo "PDF: $pdf_dir/slide_rebuild.pdf"
