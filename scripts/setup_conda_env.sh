#!/usr/bin/env bash
set -euo pipefail

ENV_NAME="aigi2vector-pptx"
PY_VER="3.11"

if ! command -v conda >/dev/null 2>&1; then
  echo "conda not found. Install Miniconda or Anaconda first." >&2
  exit 1
fi

conda create -y -n "$ENV_NAME" python="$PY_VER"
conda run -n "$ENV_NAME" python -m pip install --upgrade pip
conda run -n "$ENV_NAME" python -m pip install python-pptx pymupdf

echo "Environment '$ENV_NAME' created."
echo "Activate with: conda activate $ENV_NAME"
