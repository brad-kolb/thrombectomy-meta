# Manuscript Review: Worse Prognosis, Larger Benefit

**Date:** 2026-02-25 (v2 — revised manuscript)
**Reviewer:** review-paper skill
**File:** `manuscripts/manuscript.qmd`
**Target journal:** Stroke (resubmission)
**Prior review:** v1 dated 2026-02-23 (overall 3.5/5)

---

## Summary Assessment

**Overall recommendation:** Revise & Resubmit *(improved from v1)*

The revision addresses all three major concerns from v1. The ecological fallacy tension (MC1) is now handled well: the Discussion frames findings at the population level throughout, the Clinical implications section ends with an explicit statement of what trial-level data can and cannot support, and the Limitations reinforce this without redundancy. The intercept is now operationalized in Methods with a concrete example (MC2). ESCAPE-MEVO and DISTAL are correctly named as trials within the analysis (MC3), and the ceiling effects paragraph is grammatically coherent.

The paper is stronger. What remains are five minor concerns from v1 that were not touched, two referee objections that are still materially unaddressed (the mathematical artifact question, RO1; and the mRS rounding sensitivity, RO4), and a small set of new issues introduced by the revision. The "no floor effect" qualifier ("within the range of enrolled populations") is present in the abstract and limitations but absent from the Conclusions, which remains a consistency gap. No new major concerns were introduced.

---

## What Was Resolved Since v1

| Issue | v1 Status | v2 Status |
|-------|-----------|-----------|
| MC1: Ecological fallacy in Discussion | Unresolved | **Resolved** |
| MC2: Intercept not operationalized in Methods | Unresolved | **Resolved** |
| MC3: DISTAL/ESCAPE-MEVO framed as external | Unresolved | **Resolved** |
| MC3: Grammar error "Trials...has" | Unresolved | **Resolved** |
| Typos (modiation, supposrts, such certain) | Unresolved | **Resolved** |
| Em-dash punctuation error | Unresolved | **Resolved** |
| RO3: Within-trial individual effect | No mention | **Partially resolved** (new tail sentence in Clinical implications) |

---

## Remaining Major Concerns

*(All carried from v1; none are new.)*

### MC4: "No Floor Effect" Qualifier Missing from Conclusions
- **Dimension:** Argument Structure / Writing
- **Issue:** The abstract (line 62) and limitations (line 143) both correctly qualify the floor-effect finding as "within the range of enrolled populations." The Conclusions paragraph (line 155) drops this qualifier: "we found no evidence that poor prognosis with best medical therapy alone limits the benefit of thrombectomy (no floor effect)." A referee reading the abstract and then the Conclusions will notice the inconsistency. Unqualified, this sentence makes a stronger claim than the data support.
- **Suggestion:** Add the qualifier: "...we found no evidence that poor prognosis with best medical therapy alone limits the benefit of thrombectomy (no floor effect) within the range of populations enrolled across these 30 trials."
- **Location:** Conclusions, line 155

### MC5: BEST Trial Not Discussed
- **Dimension:** Argument Structure / Literature
- **Issue:** BEST (Liu 2020, basilar artery occlusion, neutral result) remains unaddressed. It is one of the 30 included trials. The floor-effect narrative — that populations with the worst prognosis benefit most — could be challenged by BEST, which enrolled a very high-risk population yet showed no statistically significant benefit. Even if the Bayesian posterior for BEST's treatment effect is positive, a referee will expect the authors to acknowledge it.
- **Suggestion:** Add one sentence in the floor effects paragraph: "One partial exception is BEST, which enrolled patients with basilar artery occlusion and showed a smaller estimated treatment effect relative to other high-risk trials; this is visible as a lower slope estimate in Figure 2."
- **Location:** Discussion — "No evidence of floor effects" paragraph

---

## Remaining Minor Concerns

*(All carried from v1; none new.)*

### mc1: Supplement Figure Numbering Is Inconsistent
- **Issue:** Results refers to "Figure 2 in the supplementary material" (ρ sensitivity) and "Figure 3 in the supplementary material" (absolute benefit). Clinical implications refers to "Figure S2 in the Supplement." Three different naming conventions for supplement figures. The supplement itself uses no figure numbers — just prose headers. A copy editor will flag this immediately.
- **Suggestion:** Standardize to "Online Figure I," "Online Figure II," etc. (Stroke convention) or "Supplementary Figure 1," "Supplementary Figure 2," etc. Apply consistently in Results, Discussion, and Supplement.
- **Location:** Results line 123; Discussion line 137

### mc2: Data Sharing Below Current Standards
- **Issue:** "Available upon reviewer request" is the weakest possible data sharing posture. The paper already has an OSF pre-registration (https://osf.io/smcen/).
- **Suggestion:** Deposit dataset and R code on OSF alongside the pre-registration. Update the data sharing statement to include the repository URL. This is increasingly expected at Stroke.
- **Location:** Data Sharing section, line 175

### mc3: Search Date vs. Cited Guidelines
- **Issue:** Methods states the search ran "through October 2025." The Discussion cites the "2026 AHA/ASA guidelines." No clarification that non-systematic references were updated at manuscript preparation.
- **Suggestion:** Add one sentence to Data Sources: "Literature cited in the Discussion, including recently published practice guidelines, was updated at the time of manuscript preparation."
- **Location:** Methods — Data Sources, line 88

### mc4: "In Plain Terms" Repeated Twice
- **Issue:** The phrase appears verbatim in Methods (line 96) and Results (line 120). Reads as a stylistic tick.
- **Suggestion:** Change one instance. Methods could use "Concretely, this approach..." or similar.
- **Location:** Methods line 96; Results line 120

### mc5: σ/τ Ratio Comparison Needs Scale Clarification
- **Issue:** "Between-trial differences in who was enrolled (σ) exceeded between-trial differences in thrombectomy treatment effect (τ) by a factor of two" — both are log-odds standard deviations on the same scale, so the comparison is valid, but this should be stated.
- **Suggestion:** Add "both on the log-odds scale" parenthetically.
- **Location:** Results line 117

---

## New Issues Introduced in v2

### n1: Citation Placement Inside Em-Dash Clause (Minor)
- **Issue:** "ESCAPE-MEVO and DISTAL[@Goyal2025_mvo; @Psychogios2025_distal] —" places the citation before the closing em-dash, which is typographically awkward. The citation should follow the clause, not interrupt it.
- **Suggestion:** Move citations to end of sentence: "...ESCAPE-MEVO and DISTAL — which enrolled patients with medium vessel occlusions and low-severity presentations — had the most favorable baseline prognoses, corresponding to the highest intercepts in Figure 2, and showed the most modest treatment effects[@Goyal2025_mvo; @Psychogios2025_distal]."
- **Location:** Discussion line 135

### n2: "Both of These Outcomes" Referent Is Ambiguous (Minor)
- **Issue:** Clinical implications states: "the therapeutic goal often shifts from achieving complete functional recovery to preventing severe disability or death... Our analysis shows that thrombectomy is highly effective at driving both of these outcomes in such populations." But the sentence structure makes it unclear what "both outcomes" refers to — preventing disability, avoiding death, or both goals.
- **Suggestion:** Be explicit: "Our analysis shows that thrombectomy is highly effective at reducing both severe disability and death in such populations."
- **Location:** Discussion line 137

---

## Referee Objections

*(Updated from v1. RO3 is partially resolved; RO1, RO2, RO4, RO5 remain.)*

### RO1: Is ρ < 0 a Mathematical Artifact of a Bounded Ordinal Scale?
**Why it matters:** In any proportional-odds ordinal model, a trial with a very high floor of poor outcomes has a mechanically constrained treatment effect slope — there is less room to shift the distribution further downward. The negative correlation between intercept and slope might partly reflect geometry of the outcome space rather than biology. This is the most technically sophisticated objection and has not been addressed.
**How to address it:** Two routes. First, the absolute benefit analysis (Figure S2) shows the same pattern on the probability scale, which is not subject to the same floor/ceiling geometry argument — cite this explicitly in the text as evidence against the artifact interpretation. Second, the adjacent-category model (which does not impose proportional odds) yields the same ρ — note this explicitly as further evidence.

### RO2: What Does This Add to HERMES and AURORA?
**Why it matters:** HERMES (Goyal 2016) and AURORA (Jovin 2022) are IPD meta-analyses that examined subgroup effects. A referee will ask why an aggregate-data analysis of 30 trials adds something the IPD analyses of 5–10 trials did not.
**How to address it:** The differentiation is valid but currently implicit. The Introduction says "conventional subgroup meta-analyses stratify without jointly modeling how prognosis and treatment effect relate to each other" — this is the right argument but should be made sharper, with a sentence explaining that HERMES and AURORA test pre-specified categorical subgroups (old/young, high/low NIHSS), while this analysis estimates a continuous prognosis-benefit gradient as a single parameter (ρ) across all 30 trials, quantifying the *strength* of the relationship rather than just its sign.

### RO3: Within-Trial Individual Evidence *(Partially addressed in v2)*
**Why it matters:** The trial-level correlation cannot be assumed to hold within a trial at the patient level.
**Status:** The new tail sentence of Clinical implications ("whether an individual patient's prognosis predicts differential benefit from thrombectomy cannot be determined from trial-level data alone and would require individual patient data meta-analysis") adequately flags the issue. The Limitations echo this. This objection is now defensible.
**Remaining gap:** The Discussion still states "In trials enrolling populations with large ischemic cores... thrombectomy is highly effective at driving both of these outcomes in such populations" — this sentence correctly uses population-level framing, but a referee may still press on whether existing IPD meta-analyses (HERMES, AURORA) have tested the individual-level claim and what they found. Adding one sentence citing HERMES or AURORA on this point would close the gap.

### RO4: mRS Rounding Sensitivity
**Why it matters:** Several small trials (PISTE n=65, EASI n=60, THRILL n=79) reported mRS distributions as percentages. Converting to counts introduces rounding error that differentially affects control-arm distributions and could bias the intercept estimates (and therefore ρ) for these trials.
**How to address it:** A sensitivity analysis excluding the 5 smallest trials (n < 100) or trials where >50% of mRS data was reconstructed from published percentages would be informative. If ρ is stable, this objection is neutralized with a single sentence.

### RO5: "No Floor Effect" — Range Qualification Must Be Consistent
**Why it matters:** The qualifier "within the range of enrolled populations" appears in the abstract and limitations but not in the Conclusions. A referee may argue the unqualified statement overreaches.
**How to address it:** See MC4 above — add the qualifier to the Conclusions paragraph. Also consider one sentence in the Discussion floor effects section acknowledging that trials did not enroll patients at the absolute extreme of clinical severity (e.g., terminal patients, those with complete anterior circulation infarcts), and that extrapolation beyond the enrolled range is not supported.

---

## Specific Comments

- **Line 92 (Methods addition):** "trials enrolling populations expected to do poorly yield lower intercepts" — correct, but consider adding a parenthetical "(i.e., lower probability of favorable outcome without thrombectomy)" to make "lower" unambiguous for readers unfamiliar with the model parameterization.

- **Line 131 (Discussion opening):** "This inverse relationship has been observed in observational cohorts, but our results are, to our knowledge, the first to identify the pattern in randomized trial data[@Rudilosso2021_registry]" — a single citation for a "first in randomized data" claim. Consider whether any subgroup or stratified analysis in HERMES/AURORA approaches this (even indirectly) and either cite or explicitly distinguish.

- **Line 155 (Conclusion):** The phrase "challenge historical paradigms that restricted thrombectomy to 'ideal' candidates" is a strong normative statement. Given that the analysis is aggregate-data and ecological in nature, this framing may invite pushback. Consider softening to "are consistent with the expansion of thrombectomy indications now reflected in contemporary guidelines."

---

## Summary Statistics

| Dimension | v1 Rating | v2 Rating |
|-----------|-----------|-----------|
| Argument Structure | 4 | **4.5** |
| Identification (Causal/Statistical) | 3 | **3.5** |
| Statistical Specification | 4 | 4 |
| Literature Positioning | 3 | 3 |
| Writing Quality | 4 | 4 |
| Presentation | 3 | **3.5** |
| **Overall** | **3.5** | **3.8** |

**Gate:** Revise & Resubmit — the three major concerns are resolved; remaining work is MC4/MC5 (one sentence each), the five minor concerns (editorial), and the two substantive referee objections (RO1 mathematical artifact; RO4 rounding sensitivity). Both RO1 and RO4 are answerable without new analyses — the data and models already in hand are sufficient to address them in the text.
