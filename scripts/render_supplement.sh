#!/usr/bin/env bash
# render_supplement.sh
#
# Renders manuscripts/supplement.qmd to HTML and PDF (XeLaTeX via Quarto).
#
# USAGE:
#   bash scripts/render_supplement.sh

set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
QMD="$REPO_ROOT/manuscripts/supplement.qmd"

echo "Step 1: Quarto → HTML..."
quarto render "$QMD" --to html 2>&1 | grep -v "^$" || true

echo "Step 2: Quarto → PDF (LaTeX)..."
quarto render "$QMD" --to pdf 2>&1 | grep -v "^$" || true

PDF="$REPO_ROOT/manuscripts/supplement.pdf"
if [ -f "$PDF" ]; then
  echo ""
  echo "Done: manuscripts/supplement.pdf ($(du -h "$PDF" | cut -f1))"
else
  echo "ERROR: supplement.pdf was not produced. Check errors above."
  exit 1
fi
