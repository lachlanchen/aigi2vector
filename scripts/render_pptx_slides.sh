#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 /path/to/file.pptx /path/to/output_dir" >&2
  exit 1
fi

PPTX_PATH="$1"
OUT_DIR="$2"

if [[ ! -f "$PPTX_PATH" ]]; then
  echo "PPTX not found: $PPTX_PATH" >&2
  exit 1
fi

SOFFICE_BIN=""
if command -v soffice >/dev/null 2>&1; then
  SOFFICE_BIN="soffice"
elif command -v libreoffice >/dev/null 2>&1; then
  SOFFICE_BIN="libreoffice"
else
  echo "LibreOffice not found. Install it and ensure 'soffice' is in PATH." >&2
  exit 1
fi

mkdir -p "$OUT_DIR"
TMP_DIR="$(mktemp -d)"

"$SOFFICE_BIN" --headless --convert-to png --outdir "$TMP_DIR" "$PPTX_PATH" >/dev/null 2>&1

shopt -s nullglob
FILES=("$TMP_DIR"/*.png)
if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "No slide images produced. Check if LibreOffice can read the PPTX." >&2
  rm -rf "$TMP_DIR"
  exit 1
fi

# Rename to page1.png, page2.png, ... in slide order
IDX=1
for f in $(ls -v "$TMP_DIR"/*.png); do
  cp "$f" "$OUT_DIR/page${IDX}.png"
  IDX=$((IDX + 1))
done

rm -rf "$TMP_DIR"

echo "Rendered $((IDX - 1)) slides to $OUT_DIR"
