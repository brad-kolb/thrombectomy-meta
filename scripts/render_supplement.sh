#!/usr/bin/env bash
# render_supplement.sh
#
# Renders manuscripts/supplement.pdf via Typst (two-step process).
#
# WHY TWO STEPS:
#   supplement.qmd references figures in ../Figures/ relative to manuscripts/.
#   Typst's sandbox (rooted at manuscripts/) blocks access to parent directories.
#   Quarto generates the intermediate .typ file correctly; only the typst
#   compilation step fails. We then invoke typst directly with --root set to
#   the repo root, allowing ../Figures/ paths to resolve.
#
# USAGE:
#   bash scripts/render_supplement.sh

set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

QMD="manuscripts/supplement.qmd"
TYP="manuscripts/supplement.typ"
PDF="manuscripts/supplement.pdf"

# Find Quarto's bundled typst binary (works for both Intel and ARM Macs)
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
  TYPST="/Applications/quarto/bin/tools/aarch64/typst"
else
  TYPST="/Applications/quarto/bin/tools/x86_64/typst"
fi

if [ ! -f "$TYPST" ]; then
  echo "ERROR: typst binary not found at $TYPST"
  echo "Ensure Quarto is installed at /Applications/quarto"
  exit 1
fi

echo "Step 1: Quarto → .typ (knitr + pandoc)..."
# quarto render generates the .typ but fails at typst compilation; that's expected.
quarto render "$QMD" --to typst 2>&1 | grep -v "^$" | grep -v "hint:" || true

if [ ! -f "$TYP" ]; then
  echo "ERROR: $TYP was not generated. Check R/knitr errors above."
  exit 1
fi

echo "Step 2: typst compile with --root . (allows ../Figures/ access)..."
"$TYPST" compile "$TYP" "$PDF" --root .

echo ""
echo "Done: $PDF ($(du -h "$PDF" | cut -f1))"
