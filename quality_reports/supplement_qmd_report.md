# Proofreading Report: `supplement.qmd`

**File:** `/Users/bradleykolb/projects/thrombectomy-meta/manuscripts/supplement.qmd`
**Target journal:** JAMA Neurology
**Date:** 2026-02-26
**Total issues found:** 10

## Summary

| Severity | Count |
|----------|-------|
| Critical | 1 |
| Major | 3 |
| Minor | 6 |
| **Total** | **10** |

---

## Critical

### Issue 1 — CSL file mismatch (`vancouver.csl` → `jama.csl`)
- **Location:** Line 32 (YAML)
- **Current:** `csl: vancouver.csl`
- **Fix:** `csl: jama.csl`
- **Status:** ✅ ALREADY FIXED
- **Category:** Consistency / JAMA Style | **Severity:** Critical

---

## Major

### Issue 2 — "Supplementary Figure 2" heading → "eFigure 2"
- **Location:** Line 323 (section heading)
- **Current:** `## Supplementary Figure 2: Absolute Benefit Across Model Specifications`
- **Fix:** `## eFigure 2: Absolute Benefit Across Model Specifications`
- **Status:** ✅ ALREADY FIXED
- **Category:** Consistency / JAMA Style | **Severity:** Major

### Issue 3 — Ambiguous 71-word sentence on percentage-to-count conversion
- **Location:** Line 102
- **Current:** `"For mRS results that were presented as percentages, we obtained mRS counts by assuming the reported percentage of patients achieving the given mRS score was obtained by dividing the number of patients achieving that score in the intention-to-treat population by the total number of patients in the intention-to-treat population across all 6 mRS categories."`
- **Fix:** Restructure into two clear sentences (see applied fix)
- **Category:** Academic Quality | **Severity:** Major

### Issue 4 — Long ambiguous data handling sentence (consequence of Issue 3)
- **Location:** Lines 102–103
- **Status:** Resolved by Issue 3 fix

---

## Minor

### Issue 5 — Numeral "6" should be spelled out
- **Location:** Line 102
- **Current:** `"all 6 mRS categories"`
- **Fix:** `"all six mRS categories"`
- **Category:** JAMA Style | **Severity:** Minor

### Issue 6 — `titles/abstracts` — informal slash
- **Location:** Line 101 (Study Selection)
- **Current:** `"We screened titles/abstracts and then full texts..."`
- **Fix:** `"We screened titles and abstracts, then full texts..."`
- **Category:** Academic Quality | **Severity:** Minor

### Issue 7 — Missing comma after introductory phrase
- **Location:** Line 103
- **Current:** `"For each included trial we extracted trial design..."`
- **Fix:** `"For each included trial, we extracted trial design..."`
- **Category:** Grammar | **Severity:** Minor

### Issue 8 — Present tense "yield" in results statement
- **Location:** Line 311
- **Current:** `"All three alternative models yield a consistently negative intercept–slope correlation..."`
- **Fix:** `"All three alternative models yielded a consistently negative intercept–slope correlation..."`
- **Category:** Grammar | **Severity:** Minor

### Issue 9 — "IV" undefined at first use
- **Location:** Line 91
- **Current:** `"with or without IV thrombolysis"`
- **Fix:** `"with or without intravenous (IV) thrombolysis"`
- **Category:** JAMA Style | **Severity:** Minor

### Issue 10 — `eval: !expr file.exists(...)` logic (verified correct, non-obvious)
- **Location:** Lines 345, 362, 379, 398
- **Note:** Logic is correct — runs chunk when file exists. No change needed; flagged for awareness.
- **Category:** Academic Quality | **Severity:** Minor (no action)
