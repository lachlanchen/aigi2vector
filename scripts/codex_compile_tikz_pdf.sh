#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: codex_compile_tikz_pdf.sh \
  --tex-file <path> \
  --output-dir <path> \
  [--model <name>] \
  [--reasoning <low|medium|high|xhigh>] \
  [--skip-git-check]

This prompt tool asks Codex to compile a TikZ .tex into PDF and write a compile report.
USAGE
}

tex_file=""
output_dir=""
model="gpt-5.3-codex"
reasoning="high"
skip_git_check=0

while [ $# -gt 0 ]; do
  case "$1" in
    --tex-file) tex_file="${2:-}"; shift ;;
    --output-dir) output_dir="${2:-}"; shift ;;
    --model) model="${2:-}"; shift ;;
    --reasoning) reasoning="${2:-}"; shift ;;
    --skip-git-check) skip_git_check=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
  shift
done

if [ -z "$tex_file" ] || [ -z "$output_dir" ]; then
  echo "--tex-file and --output-dir are required." >&2
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

if [ ! -f "$tex_file" ]; then
  echo "TeX file not found: $tex_file" >&2
  exit 1
fi

mkdir -p "$output_dir" "$output_dir/logs"

tex_abs="$(cd "$(dirname "$tex_file")" && pwd)/$(basename "$tex_file")"
tex_dir="$(dirname "$tex_abs")"
tex_base="$(basename "$tex_abs")"
stem="$(basename "$tex_file" .tex)"
pdf_out="$output_dir/${stem}.pdf"
report_out="$output_dir/compile_report.md"
prompt_file="$output_dir/logs/compile_prompt.txt"
resp_file="$output_dir/logs/compile_response.jsonl"
stderr_file="$output_dir/logs/codex_stderr.log"

cat > "$prompt_file" <<EOF
You are a build assistant. Compile the provided TikZ/XeLaTeX file into PDF.

Inputs:
- TeX file: $tex_abs
- Desired PDF output path: $pdf_out
- Report output path: $report_out

Requirements:
- Run compile commands from this working directory: $tex_dir
- Prefer this compile command first:
  cd "$tex_dir" && latexmk -xelatex -interaction=nonstopmode -halt-on-error -file-line-error -outdir="$output_dir" "$tex_base"
- If latexmk is unavailable, fallback to:
  cd "$tex_dir" && xelatex -interaction=nonstopmode -halt-on-error -file-line-error -output-directory "$output_dir" "$tex_base"
  (run xelatex twice)
- If compilation succeeds, ensure PDF exists exactly at $pdf_out
- Write a concise compile report markdown to $report_out including:
  - commands run
  - success/failure
  - key warnings/errors (if any)
- If compile fails, include precise error lines in report and keep exit status non-zero.

Final response requirement:
- On success, final response must be exactly:
  COMPILED $pdf_out
EOF

cmd=(codex exec --json --full-auto -m "$model" -c "model_reasoning_effort=\"$reasoning\"")
if [ "$skip_git_check" -eq 1 ]; then
  cmd+=(--skip-git-repo-check)
fi
cmd+=(-)

"${cmd[@]}" < "$prompt_file" > "$resp_file" 2>>"$stderr_file" &
pid=$!
elapsed=0
max_wait=180
ready_since=-1
while kill -0 "$pid" 2>/dev/null; do
  sleep 2
  elapsed=$((elapsed + 2))

  if [ -s "$pdf_out" ]; then
    if [ "$ready_since" -lt 0 ]; then
      ready_since=$elapsed
    fi
    if [ $((elapsed - ready_since)) -ge 15 ]; then
      echo "Codex compile produced PDF and stayed active; stopping lingering process..." >&2
      kill "$pid" 2>/dev/null || true
      break
    fi
  fi

  if [ "$elapsed" -ge "$max_wait" ]; then
    echo "Codex compile timed out after ${max_wait}s; stopping process..." >&2
    kill "$pid" 2>/dev/null || true
    break
  fi
done
wait "$pid" 2>/dev/null || true

if [ ! -s "$pdf_out" ]; then
  # Fallback local compile if prompt-tool run failed or stalled.
  if command -v latexmk >/dev/null 2>&1; then
    (cd "$tex_dir" && latexmk -xelatex -interaction=nonstopmode -halt-on-error -file-line-error -outdir="$output_dir" "$tex_base") || true
  else
    (cd "$tex_dir" && xelatex -interaction=nonstopmode -halt-on-error -file-line-error -output-directory "$output_dir" "$tex_base") || true
    (cd "$tex_dir" && xelatex -interaction=nonstopmode -halt-on-error -file-line-error -output-directory "$output_dir" "$tex_base") || true
  fi
fi

if [ ! -s "$pdf_out" ]; then
  # Second fallback: sanitize fragile font directives and retry.
  sanitized_tex="$tex_dir/${stem}.sanitized.tex"
  python3 - "$tex_abs" "$sanitized_tex" <<'PY'
import re
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_text(encoding="utf-8", errors="ignore")
src = re.sub(r"^\\s*\\\\setmainfont\\{[^}]*\\}\\s*$", "", src, flags=re.M)
src = re.sub(r"^\\s*\\\\setCJKmainfont\\{[^}]*\\}\\s*$", "", src, flags=re.M)
src = src.replace(r"\CJKfamily{kai}", "")
Path(sys.argv[2]).write_text(src, encoding="utf-8")
PY

  if command -v latexmk >/dev/null 2>&1; then
    (cd "$tex_dir" && latexmk -xelatex -interaction=nonstopmode -halt-on-error -file-line-error -outdir="$output_dir" "$(basename "$sanitized_tex")") || true
  else
    (cd "$tex_dir" && xelatex -interaction=nonstopmode -halt-on-error -file-line-error -output-directory "$output_dir" "$(basename "$sanitized_tex")") || true
    (cd "$tex_dir" && xelatex -interaction=nonstopmode -halt-on-error -file-line-error -output-directory "$output_dir" "$(basename "$sanitized_tex")") || true
  fi
  if [ -s "$output_dir/${stem}.sanitized.pdf" ]; then
    cp -f "$output_dir/${stem}.sanitized.pdf" "$pdf_out"
  fi
fi

if [ ! -s "$pdf_out" ]; then
  echo "PDF not found after compile: $pdf_out" >&2
  exit 1
fi

echo "Compiled PDF: $pdf_out"
echo "Compile report: $report_out"
echo "Response log: $resp_file"
