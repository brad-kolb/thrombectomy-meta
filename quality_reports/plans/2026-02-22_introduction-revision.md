# Plan: Introduction Revision + Pre-Submission Structural Review
**Date:** 2026-02-22
**Status:** APPROVED — awaiting implementation
**Triggered by:** Extended framing discussion + devil's advocate agent review

---

## Background

After an extended collaborative discussion about introduction framing, we invoked a devil's advocate agent whose sole mandate was to identify risks to Stroke publication. The agent's critique was substantive and identified several structural problems that go beyond introduction prose. This plan addresses all of them in priority order.

---

## Devil's Advocate: Key Findings (Synthesized)

### Agreed with fully
1. **Ecological fallacy is the paper's biggest structural risk.** Burying it as limitation #1 of 5 is insufficient when the introduction makes what reads as an individual-patient clinical argument based on trial-level data. The fix must be structural — a caveat sentence built into the framing before the clinical implication is drawn, not just a limitation paragraph after.

2. **Three specific overclaims in the current introduction draft** need to be corrected:
   - "mechanism" → "empirical pattern" (we are estimating a correlation, not testing a mechanism)
   - "argues against a floor effect" → "is consistent with the absence of a floor effect" (evidence of absence vs. absence of evidence)
   - "provides a common empirical basis for the recent guideline expansions" → soften or restructure (the guideline expansions were based on individual RCTs; our analysis is retrospectively consistent with them, not their original basis)

3. **Title "Floor and Ceiling Effects in Thrombectomy" is misaligned** with the actual novel findings (σ >> τ and ρ < 0). The title promises a mechanistic claim; the paper delivers a correlation. A title revision should be considered before submission.

4. **Technology/era confound is a threat to σ >> τ.** The observation that treatment effects vary less than populations is potentially confounded by the fact that different trials used different device generations, time windows, and patient selection criteria simultaneously. This is already acknowledged in Limitation #5 but may need to be more explicitly flagged as a potential confounder of the σ >> τ finding specifically.

### Agreed with partially
5. **Angle 3 (heterogeneity paradox) vs. futility narrative for Stroke's readership.** The agent argues the futility narrative is more clinically actionable and appropriate for Stroke; the heterogeneity paradox requires too much statistical scaffolding. I partially agree: the optimal framing is a **hybrid** — lead with the trial-record finding (what we observed across 30 trials), then offer the clinical interpretation (what this means for futility reasoning) with explicit ecological hedging. This is essentially what our current 3-paragraph draft does, but the ecological framing is not yet built in.

6. **"Guideline connection is overclaimed."** I agree with the specific word-level concerns but not with the broader conclusion that the guideline hook should be abandoned. The 2026 guideline expansions are timely and genuinely relevant. The connection is legitimate — we just need to word it as "consistent with" rather than "provides the basis for."

### Disagreed with
7. **"30 trials treated as exchangeable" as a fatal flaw.** The hierarchical model explicitly allows each trial to have its own intercept and slope — this is precisely the mechanism for handling non-exchangeability. The model does not assume identical populations; it assumes the intercepts and slopes are drawn from a common distribution. This objection misunderstands the hierarchical framework and should not drive structural changes.

---

## Priority-Ordered Action Items

### Priority 1: Fix three specific language overclaims (15 min, low risk)
These are word-level fixes that reduce reviewer rejection risk without changing the argument structure. Do these first regardless of other decisions.

| Location | Current text | Fix |
|----------|-------------|-----|
| Introduction P2 | "a single mechanism — worse baseline prognosis..." | → "a common empirical pattern — worse baseline prognosis..." |
| Introduction P3 | "argues against a floor effect" | → "is consistent with the absence of a floor effect" |
| Introduction P3 | "provides a common empirical basis for the recent guideline expansions" | → "is consistent with the empirical rationale underlying the recent guideline expansions" |

These same overclaims likely appear in the Abstract and Conclusion — check and fix there too.

---

### Priority 2: Add ecological caveat sentence to the introduction framing (30 min)
The sentence must appear **before** the clinical implication is drawn, not after. The goal is to build the caveat into the argument structure so reviewers cannot claim we buried it.

**Proposed sentence (insert at end of P3, before the floor/ceiling claims):**
> "These are trial-level findings; the relationship between individual patient prognosis and individual patient benefit requires patient-level data and cannot be directly inferred from this analysis."

Then the floor/ceiling interpretation follows as a downstream interpretation of the trial-level pattern.

**Alternative (lighter touch):**
> "At the trial level, worse expected outcomes under medical therapy predicted larger relative benefit — a pattern consistent with, though not direct evidence of, a similar relationship at the individual patient level."

The lighter touch preserves the clinical message while flagging the inference level. The heavier touch is safer from a reviewer standpoint but may weaken the paper's impact.

**Decision needed from author:** Which version?

---

### Priority 3: Draft final introduction (45 min)
Incorporating all of the above: hybrid framing, three overclaim fixes, ecological caveat sentence.

**Target structure:**
- **P1 (Gap):** What has not been estimated — the prognosis–benefit relationship across the full trial record. [~60 words]
- **P2 (Stakes + guideline hook):** Why it matters. Clinical futility belief + guideline expansions share a common unanswered question. [~75 words]
- **P3 (What we did + findings):** What we did, what we found (σ >> τ, ρ < 0), ecological caveat sentence, softened floor/ceiling claim, guideline consistency. [~80 words]

**Total target:** ≤ 220 words.

---

### Priority 4: Title decision (discussion, not implementation)
The current title "Floor and Ceiling Effects in Thrombectomy: A Bayesian Hierarchical Ordinal Meta-analysis of 30 Randomized Trials" has two problems:
1. "Floor and Ceiling Effects" implies mechanistic demonstration; the paper demonstrates a correlation
2. The title does not signal the novel finding (σ >> τ and ρ < 0)

**Option A (current):** Floor and Ceiling Effects in Thrombectomy: A Bayesian Hierarchical Ordinal Meta-analysis of 30 Randomized Trials
- Pro: Clinically evocative; directly states the implications
- Con: Overclaims mechanistic content; misaligned with heterogeneity paradox framing

**Option B (agent recommendation):** Baseline Prognosis and Thrombectomy Benefit: A Bayesian Hierarchical Ordinal Meta-analysis of 30 Randomized Trials
- Pro: Accurate to the central finding (ρ); direct and clear
- Con: Less evocative; doesn't capture σ >> τ or the floor/ceiling implication

**Option C (heterogeneity paradox):** Thrombectomy Benefit Is More Stable Across Populations Than Prognosis: A Bayesian Hierarchical Ordinal Meta-analysis of 30 Randomized Trials
- Pro: Directly states σ >> τ finding in plain language; surprising and memorable
- Con: Long; may not pass Stroke character limits

**Option D (hybrid — recommended):** Prognosis–Benefit Correlation in Thrombectomy: A Bayesian Hierarchical Ordinal Meta-analysis of 30 Randomized Trials
- Pro: Accurate; clinical; implies the novel estimand; concise
- Con: Less immediately evocative than "floor and ceiling"

**Decision needed from author.** None of the options are obviously wrong; this is a values question about clinical evocativeness vs. methodological precision.

---

### Priority 5: Ecological fallacy — review Discussion treatment (30 min)
Read Limitation #1 in the current manuscript and assess whether it is:
1. Prominently positioned (it is first of five — good)
2. Sufficiently specific about what can and cannot be inferred
3. Connected back to the introduction framing with a sentence like "consistent with our pre-specified caveat..."

If the introduction now explicitly builds in the ecological caveat (Priority 2), the Limitation paragraph may be able to be shorter and more precise rather than longer.

---

### Priority 6: Check technology/era limitation (15 min)
Read current Limitation #5. Assess whether it is specific enough about σ >> τ as the potentially confounded finding (vs. just ρ). The agent flagged this as a threat specifically to the σ >> τ claim: different eras of technology may explain why treatment effects don't vary as much as populations, because later-era trials in sicker populations used better technology.

Current Limitation #5 text: "device technology, workflow, and adjunctive medical therapy evolved over the course of the included trials alongside changes in patient selection. The observed correlation likely reflects a mixture of case-mix and era/technology effects rather than differences in baseline prognosis alone."

This addresses ρ but not σ >> τ explicitly. May need one additional sentence.

---

### Priority 7: Abstract alignment check (20 min)
After the introduction is finalized, read the full abstract and check:
1. Does "Background" match the new introduction framing?
2. Does "Conclusions" use the same softened language (consistent with absence of floor effect vs. argues against)?
3. Does the abstract's "Purpose" accurately reflect the estimand (prognosis–benefit correlation)?
4. Is "Funding: None" still accurate?

---

### Priority 8: Word count verification (5 min)
Stroke Original Research word limit: 4,000 words excluding abstract, references, and figure legends. Verify the current manuscript is within this limit before spending more time on prose.

---

### Priority 9: Final render and verification (15 min)
- `quarto render manuscript.qmd --to html`
- Verify no compilation errors
- Spot-check that all cross-references (Figure 1, Figure 2, Table S1, Table S2) resolve correctly
- Spot-check that bibliography renders in correct order

---

## Execution Sequence

```
Priority 1 (overclaim fixes)     → can do immediately, no decisions needed
Priority 2 (ecological caveat)   → needs author decision: heavy or light touch?
Priority 3 (introduction draft)  → depends on Priority 2 decision
Priority 4 (title)               → needs author decision; independent of P1–P3
Priority 5 (Discussion/Ecol.)    → after Priority 3 is finalized
Priority 6 (technology limitation) → quick read + possible sentence addition
Priority 7 (abstract alignment)  → after Priority 3 is finalized
Priority 8 (word count)          → quick, anytime
Priority 9 (render)              → last step
```

---

## Key Decisions Needed from Author

1. **Ecological caveat sentence:** Heavy touch (explicit statement that individual-level inference is not supported) or light touch (softer hedge that preserves clinical message)?

2. **Title:** Keep "Floor and Ceiling Effects" (evocative, slightly overclaimed) or change to something more precisely aligned with the findings?

3. **Framing:** The current hybrid approach (trial-record finding → clinical interpretation with hedging) is the agent's recommended path and our own preference. Confirm this is the direction before drafting.

---

## What We Are NOT Changing

- The core analysis (4 Bayesian models, ρ, σ, τ estimates)
- The four figures
- The methods section (other than any clarifications about exchangeability assumptions)
- The results section (other than softening the floor/ceiling language to match the introduction)
- The supplement structure

---

## Open Questions Not Yet Resolved

1. Should the key message (150-character Stroke requirement) be updated to reflect the revised framing? Current: "In 30 thrombectomy RCTs, worse baseline prognosis predicted larger benefit: ceiling effect confirmed, no floor effect found." This may need updating depending on the title and introduction decisions.

2. Should the THRILL RoB "other" domain (listed as High risk in the supplement) be footnoted? (Flagged in earlier session log as a potential note — still unaddressed.)
