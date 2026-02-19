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
# WHY POST-PROCESS THE .typ:
#   Typst does not allow #pagebreak() inside show rules (layout not yet resolved).
#   We insert #pagebreak(weak: true) directly before each top-level (= ) heading
#   in the generated .typ file, skipping the very first section.
#
# USAGE:
#   bash scripts/render_supplement.sh

set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

QMD="manuscripts/supplement.qmd"
TYP="manuscripts/supplement.typ"
PDF="manuscripts/supplement.pdf"

# Find Quarto's bundled typst binary
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
  TYPST="/Applications/quarto/bin/tools/aarch64/typst"
else
  TYPST="/Applications/quarto/bin/tools/x86_64/typst"
fi

if [ ! -f "$TYPST" ]; then
  echo "ERROR: typst binary not found at $TYPST"
  exit 1
fi

echo "Step 1: Quarto → .typ (knitr + pandoc)..."
quarto render "$QMD" --to typst 2>&1 | grep -v "^$" | grep -v "hint:" || true

if [ ! -f "$TYP" ]; then
  echo "ERROR: $TYP was not generated. Check R/knitr errors above."
  exit 1
fi

echo "Step 2: Post-process .typ — insert page breaks before top-level sections..."
python3 - "$TYP" <<'PYEOF'
import sys, re

path = sys.argv[1]
with open(path, 'r') as f:
    lines = f.readlines()

out = []
first_heading = True
for line in lines:
    # Top-level Typst heading: line starts with "= " (one equals, space)
    # but not "== " (level 2) or "=== " (level 3)
    if re.match(r'^= [^=]', line):
        if first_heading:
            first_heading = False   # no break before first section
        else:
            out.append('#pagebreak(weak: true)\n')
    out.append(line)

with open(path, 'w') as f:
    f.writelines(out)

print(f"  Inserted page breaks before {sum(1 for l in lines if re.match(r'^= [^=]', l)) - 1} sections.")
PYEOF

echo "Step 3: typst compile with --root . (allows ../Figures/ access)..."
"$TYPST" compile "$TYP" "$PDF" --root .

echo ""
echo "Done: $PDF ($(du -h "$PDF" | cut -f1))"
