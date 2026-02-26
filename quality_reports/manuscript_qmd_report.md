# Proofreading Report: `manuscript.qmd`

**File:** `/Users/bradleykolb/projects/thrombectomy-meta/manuscripts/manuscript.qmd`
**Target journal:** JAMA Neurology
**Date:** 2026-02-26
**Total issues found:** 19

---

## Critical / Pre-submission Issues (fix before submitting)

### Issue 1 — Numeral "4" not spelled out (JAMA spells out one through nine)
- **Location:** Line 65 (Abstract, Results)
- **Current:** `"Findings were robust across 4 model specifications."`
- **Fix:** `"Findings were robust across four model specifications."`
- **Note:** Line 122 correctly uses "four" — this creates an inconsistency between abstract and body.
- **Category:** JAMA Style | **Severity:** Major

---

### Issue 2 — `\[CrI\]` renders as square brackets; should be `(CrI)`
- **Location:** Line 65 (Abstract, Results)
- **Current:** `"95% credible interval \[CrI\] 0.30 to 0.62"`
- **Fix:** `"95% credible interval (CrI) 0.30 to 0.62"`
- **Note:** Square brackets are LaTeX escape syntax here; parentheses are the correct form for abbreviation definitions. All other CrI uses in the manuscript already use `(CrI)` or `95% CrI` without redefining.
- **Category:** Typo / Consistency | **Severity:** Major

---

### Issue 3 — "mRS" undefined at first use in Introduction body text
- **Location:** Line 79 (Introduction, final paragraph)
- **Current:** `"full 90-day mRS distributions from all 30 published randomized thrombectomy trials"`
- **Fix:** `"full 90-day modified Rankin Scale (mRS) distributions from all 30 published randomized thrombectomy trials"`
- **Note:** JAMA requires abbreviations to be defined at first use in the abstract AND again at first use in the body text. Abstract defines mRS (line ~61); Methods also defines it (line ~93); but the Introduction uses it undefined on line 79, before the Methods definition.
- **Category:** JAMA Style | **Severity:** Major

---

### Issue 4 — "Table 2 in the supplementary material" should be "eTable 2"
- **Location:** Line 107 (Results, first paragraph)
- **Current:** `"(Table 2 in the supplementary material)"`
- **Fix:** `"(eTable 2)"`
- **Note:** JAMA Neurology uses the "e" prefix for all supplemental items (eTable 1, eTable 2, eFigure 1, etc.).
- **Category:** JAMA Style | **Severity:** Major

---

### Issue 5 — "Supplementary Figure 1" and "Supplementary Figure 2" should be "eFigure 1" / "eFigure 2"
- **Location:** Line 122 (Results, "Robustness and clinical translation")
- **Current:** `"Supplementary Figure 1"` and `"Supplementary Figure 2"`
- **Fix:** `"eFigure 1"` and `"eFigure 2"`
- **Note:** Same JAMA supplemental naming convention as Issue 4. Verify supplement.qmd uses matching labels.
- **Category:** JAMA Style | **Severity:** Major

---

### Issue 6 — Missing comma before non-restrictive "which" clause
- **Location:** Line 134 (Discussion, second paragraph — ceiling effect)
- **Current:** `"Two trials included in this analysis (ESCAPE-MEVO and DISTAL) which enrolled patients with medium vessel occlusions..."`
- **Fix:** `"Two trials included in this analysis (ESCAPE-MEVO and DISTAL), which enrolled patients with medium vessel occlusions..."`
- **Note:** "which enrolled..." is a non-restrictive relative clause and requires a preceding comma.
- **Category:** Grammar | **Severity:** Major

---

### Issue 7 — Awkward construction in floor effect sentence; "mechanical thrombectomy" repeated
- **Location:** Line 132 (Discussion, first paragraph)
- **Current:** `"We found no evidence from randomized trials of patient populations that are 'too sick to benefit' from mechanical thrombectomy."`
- **Note:** Current text reads fine but "mechanical thrombectomy" appears twice in quick succession (also in the prior sentence opening). Acceptable as-is, but consider: `"We found no evidence from randomized trials of patient populations that are 'too sick to benefit' from thrombectomy."` (drop "mechanical" on second use since the referent is clear).
- **Category:** Academic Quality | **Severity:** Minor

---

### Issue 8 — Space before citation in Conclusion paragraph
- **Location:** Line 154 (Conclusion)
- **Current:** `"...now endorsed by contemporary guidelines [@Prabhakaran2026_aha; @Mokin2025_svin]"`
- **Fix:** `"...now endorsed by contemporary guidelines[@Prabhakaran2026_aha; @Mokin2025_svin]"`
- **Note:** In JAMA's superscript citation style, no space precedes the citation number. All other citations in the manuscript follow no-space convention. This is the only outlier.
- **Category:** Typo / JAMA Style | **Severity:** Major

---

## Minor Issues

### Issue 9 — "pre-specified" should be "prespecified"
- **Location:** Line 77 (Introduction, second paragraph)
- **Current:** `"pre-specified categorical subgroups"`
- **Fix:** `"prespecified categorical subgroups"`
- **Note:** AMA Manual of Style does not hyphenate "pre" compounds unless the second element begins with a vowel. "Prespecified" is standard in JAMA Network publications.
- **Category:** JAMA Style | **Severity:** Minor

---

### Issue 10 — Results subsection headings skip a level (H1 → H3)
- **Location:** Lines ~109–121 (Results subsection headings)
- **Current:** Five Results subsections use `###` (H3) under `# Results` (H1)
- **Fix:** Change to `##` (H2) to match the heading hierarchy used in the Discussion (H1 Discussion → H2 Limitations, H2 Conclusion)
- **Category:** Consistency | **Severity:** Minor

---

### Issue 11 — "Fifth and finally" is mildly redundant
- **Location:** Line 150 (Limitations, fifth point)
- **Current:** `"Fifth and finally, device technology..."`
- **Fix:** `"Fifth, device technology..."` or `"Finally, device technology..."`
- **Category:** Academic Quality | **Severity:** Minor

---

### Issue 12 — Citation key naming inconsistency in Bibliography
- **Location:** manuscript.qmd ~line 95; Bibliography_base.bib
- **Current:** Three keys use hyphenated suffix format: `@Saver2009-ao`, `@Riley2011-zh`, `@Higgins2002-fc`
- **Fix:** Rename to follow project convention `AuthorYear_keyword` (e.g., `Saver2009_shift`, `Riley2011_prediction`, `Higgins2002_heterogeneity`) — update key in both .bib and .qmd simultaneously
- **Note:** Functional but inconsistent with all other bibliography keys.
- **Category:** Consistency | **Severity:** Minor

---

### Issue 13 — Repetitive "relative benefit" in Discussion paragraph 3
- **Location:** Line 136 (Discussion, clinical implications paragraph)
- **Current:** "relative benefit" and "benefit" used five times in ~200 words
- **Fix:** Replace one instance with "treatment effect" or "therapeutic gain" for stylistic variation
- **Category:** Academic Quality | **Severity:** Minor

---

### Issue 14 — "a low risk of bias" — slightly awkward article usage
- **Location:** Line 107 (Results)
- **Current:** `"there was a low risk of bias for the included studies"`
- **Fix:** `"risk of bias was low across most domains for the included studies"` (restructure) or simply `"there was low risk of bias"` (drop article)
- **Category:** Academic Quality | **Severity:** Minor

---

### Issue 15 — "large vessel occlusion" hyphenation as compound modifier (author decision)
- **Location:** Multiple lines (45, 55, 57, 75, 89, etc.)
- **Current:** Consistently written `"large vessel occlusion stroke"` without hyphen
- **Note:** Standard compound modifier rule would suggest `"large-vessel occlusion stroke."` However, "large vessel occlusion" has become a near-proper clinical term, and many stroke journals (including Stroke, NEJM) use it without hyphenation. Manuscript is internally consistent — no change required, but confirm against JAMA Neurology style.
- **Category:** Consistency | **Severity:** Low

---

### Issue 16 — CrI abbreviation not defined in Key Points (acceptable but flag)
- **Location:** Line 43 (Key Points, Findings)
- **Current:** `"95% credible interval −0.80 to −0.11"` — spelled out, no abbreviation introduced
- **Note:** Key Points is a standalone box; JAMA treats it separately from the abstract. Spelling out "credible interval" in Key Points while using `(CrI)` in the abstract is correct and consistent with JAMA convention. No change needed.
- **Category:** Consistency | **Severity:** Low

---

### Issue 17 — "large ischemic cores, posterior circulation involvement, or late presentations" — confirm terminology consistency with guidelines
- **Location:** Line 137 (Discussion, clinical implications)
- **Current:** `"large ischemic cores, posterior circulation involvement, or late presentations"`
- **Note:** The manuscript elsewhere uses "basilar artery occlusion" (more specific). "Posterior circulation involvement" is broader. Verify this is the intended framing or align with the more specific terms used earlier.
- **Category:** Consistency | **Severity:** Low

---

## Summary Table

| # | Location | Issue | Category | Severity |
|---|----------|-------|----------|----------|
| 1 | Line 65 | Numeral "4" not spelled out | JAMA Style | **Major** |
| 2 | Line 65 | `\[CrI\]` → `(CrI)` | Typo | **Major** |
| 3 | Line 79 | mRS undefined in Introduction | JAMA Style | **Major** |
| 4 | Line 107 | "Table 2 in supplementary" → "eTable 2" | JAMA Style | **Major** |
| 5 | Line 122 | "Supplementary Figure" → "eFigure" | JAMA Style | **Major** |
| 6 | Line 134 | Missing comma before "which" clause | Grammar | **Major** |
| 7 | Line 132 | "mechanical thrombectomy" repeated | Academic Quality | Minor |
| 8 | Line 154 | Space before citation in Conclusion | JAMA Style | **Major** |
| 9 | Line 77 | "pre-specified" → "prespecified" | JAMA Style | Minor |
| 10 | Lines 109–121 | Results headings H3 → H2 | Consistency | Minor |
| 11 | Line 150 | "Fifth and finally" → "Fifth" | Academic Quality | Minor |
| 12 | Bib file | Citation key naming inconsistency | Consistency | Minor |
| 13 | Line 136 | "relative benefit" repeated | Academic Quality | Minor |
| 14 | Line 107 | "a low risk of bias" awkward | Academic Quality | Minor |
| 15 | Multiple | "large vessel occlusion" hyphenation | Consistency | Low |
| 16 | Line 43 | CrI in Key Points (acceptable) | Consistency | Low |
| 17 | Line 137 | "posterior circulation" vs "basilar" | Consistency | Low |

**Major issues requiring fix before submission: 7 (Issues 1–6, 8)**
