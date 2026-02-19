// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subrefnumbering: "1a",
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => numbering(subrefnumbering, n-super, quartosubfloatcounter.get().first() + 1))
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => {
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          }

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      if(body != []){
        block(
          inset: 1pt, 
          width: 100%, 
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}



#let article(
  title: none,
  subtitle: none,
  authors: none,
  date: none,
  abstract: none,
  abstract-title: none,
  cols: 1,
  lang: "en",
  region: "US",
  font: "libertinus serif",
  fontsize: 11pt,
  title-size: 1.5em,
  subtitle-size: 1.25em,
  heading-family: "libertinus serif",
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  sectionnumbering: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  set par(justify: true)
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)
  set heading(numbering: sectionnumbering)
  if title != none {
    align(center)[#block(inset: 2em)[
      #set par(leading: heading-line-height)
      #if (heading-family != none or heading-weight != "bold" or heading-style != "normal"
           or heading-color != black) {
        set text(font: heading-family, weight: heading-weight, style: heading-style, fill: heading-color)
        text(size: title-size)[#title]
        if subtitle != none {
          parbreak()
          text(size: subtitle-size)[#subtitle]
        }
      } else {
        text(weight: "bold", size: title-size)[#title]
        if subtitle != none {
          parbreak()
          text(weight: "bold", size: subtitle-size)[#subtitle]
        }
      }
    ]]
  }

  if authors != none {
    let count = authors.len()
    let ncols = calc.min(count, 3)
    grid(
      columns: (1fr,) * ncols,
      row-gutter: 1.5em,
      ..authors.map(author =>
          align(center)[
            #author.name \
            #author.affiliation \
            #author.email
          ]
      )
    )
  }

  if date != none {
    align(center)[#block(inset: 1em)[
      #date
    ]]
  }

  if abstract != none {
    block(inset: 2em)[
    #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
    ]
  }

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}

#set table(
  inset: 6pt,
  stroke: none
)
// Allow figures (and tables wrapped in figure) to paginate across pages
#show figure: set block(breakable: true)

// Add breathing room between author block and table of contents
#show outline: it => {
  v(2em)
  it
}

#set page(
  paper: "us-letter",
  margin: (x: 1in,y: 1in,),
  numbering: "1",
)

#show: doc => article(
  title: [Supplementary Material: Floor and Ceiling Effects in Thrombectomy],
  subtitle: [A Bayesian Hierarchical Ordinal Meta-analysis of 30 Randomized Trials],
  authors: (
    ( name: [Bradley Kolb, MD],
      affiliation: [Department of Neurosurgery, Rush University Medical Center],
      email: [] ),
    ),
  toc: true,
  toc_title: [Table of contents],
  toc_depth: 3,
  cols: 1,
  doc,
)

#pagebreak(weak: true)
= Search Strategy
<search-strategy>
We searched PubMed (MEDLINE via NCBI) from inception to October 19, 2025, with no date limits. The full, reproducible PubMed strategy was:

```
(
"mechanical thrombectomy"[tiab] OR "endovascular thrombectomy"[tiab] OR
"aspiration thrombectomy"[tiab] OR "stent retriever*"[tiab] OR stentriever*[tiab] OR
Solitaire[tiab] OR Trevo[tiab] OR Penumbra[tiab]
)
AND
(
stroke[tiab] OR "ischemic stroke"[tiab] OR "large vessel occlusion"[tiab] OR LVO[tiab] OR
"basilar artery"[tiab] OR "basilar occlusion"[tiab]
)
AND
(
randomized controlled trial[Publication Type] OR random*[tiab] OR trial[tiab]
)
NOT (animals[mh] NOT humans[mh])
AND english[lang]
```

This search returned 327 records.

#pagebreak(weak: true)
= Eligibility Criteria
<eligibility-criteria>
- #strong[Design:] Randomized.
- #strong[Population:] Adults with acute ischemic stroke (anterior or posterior circulation).
- #strong[Intervention:] Mechanical thrombectomy (including stent retrievers and/or aspiration).
- #strong[Comparator:] Best medical management (with or without IV thrombolysis).
- #strong[Outcomes:] Functional outcomes (modified Rankin Scale).
- #strong[Exclusions:] Non-randomized studies.

#pagebreak(weak: true)
= Study Selection and Data Handling
<study-selection-and-data-handling>
We screened titles/abstracts and then full texts, with disagreements resolved by consensus, as documented in the PRISMA 2020 diagram below.

For each included trial we extracted trial design, population, time window, imaging selection, intervention details (device/approach), comparator, and outcomes (including full-ordinal mRS where available).

For mRS results that were presented as percentages, we obtained mRS counts by assuming the reported percentage of patients achieving the given mRS score was obtained by dividing the number of patients achieving that score in the intention-to-treat population by the total number of patients in the intention-to-treat population across all 6 mRS categories.

#pagebreak(weak: true)
= PRISMA Diagram
<prisma-diagram>
#figure([
#box(image("../Figures/prisma.svg", width: 100.0%))
], caption: figure.caption(
position: bottom, 
[
PRISMA 2020 diagram of search strategy and study selection.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)

#horizontalrule

#pagebreak(weak: true)
= Table S1. Trial Characteristics
<table-s1.-trial-characteristics>
#figure([
#{set text(font: ("system-ui", "Segoe UI", "Roboto", "Helvetica", "Arial", "sans-serif", "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji") , size: 6.75pt); table(
  columns: 10,
  align: (left,right,right,right,left,left,left,left,left,left,),
  table.header(table.cell(align: bottom + left, fill: rgb("#f0f0f0"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); Trial], table.cell(align: bottom + right, fill: rgb("#f0f0f0"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); Year], table.cell(align: bottom + right, fill: rgb("#f0f0f0"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); N (EVT)], table.cell(align: bottom + right, fill: rgb("#f0f0f0"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); N (Control)], table.cell(align: bottom + left, fill: rgb("#f0f0f0"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); Occlusion], table.cell(align: bottom + left, fill: rgb("#f0f0f0"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); Time Window], table.cell(align: bottom + left, fill: rgb("#f0f0f0"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); Population], table.cell(align: bottom + left, fill: rgb("#f0f0f0"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); Primary Endpoint], table.cell(align: bottom + left, fill: rgb("#f0f0f0"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); Key Feature], table.cell(align: bottom + left, fill: rgb("#f0f0f0"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); Notes],),
  table.hline(),
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[IMS III], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[2013], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[415], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[214], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ICA/M1], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[≤6 h], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Early-window standard LVO], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[mRS 0-2 90d], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[IVT eligible], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[SYNTHESIS], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[2013], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[181], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[181], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Mixed], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[≤4.5 h], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Early-window standard LVO], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[mRS 0-1 90d], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[No CTA requirement], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[MR RESCUE], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[2013], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[63], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[54], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ICA/M1], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[≤8 h], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Early-window standard LVO], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[mRS shift 90d], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Imaging strata], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[EXTEND-IA], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[2015], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[35], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[35], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ICA/M1], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[≤6 h], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Early-window standard LVO], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[mRS shift 90d], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Perfusion-selected], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[SWIFT PRIME], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[2015], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[98], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[93], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ICA/M1], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[≤6 h], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Early-window standard LVO], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[mRS shift 90d], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[IVT eligible], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ESCAPE], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[2015], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[163], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[146], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ICA/M1], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[≤12 h], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Early-window standard LVO], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[mRS shift 90d], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Good collaterals], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[REVASCAT], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[2015], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[103], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[103], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ICA/M1], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[≤8 h], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Early-window standard LVO], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[mRS shift 90d], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ASPECTS ≥7], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[MR CLEAN], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[2015], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[233], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[266], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ICA/M1], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[≤6 h], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Early-window standard LVO], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[mRS shift 90d], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Pragmatic], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[THERAPY], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[2016], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[50], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[46], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ICA/M1], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[≤6 h], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Early-window standard LVO], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[mRS shift 90d], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[IVT eligible], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[THRACE], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[2016], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[200], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[202], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ICA/M1], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[≤5 h], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Early-window standard LVO], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[mRS 0-2 90d], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[IVT eligible], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[THRILL], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[2016], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[2], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[2], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ICA/M1], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[≤6 h], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Early-window standard LVO], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Not reported], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[IVT ineligible], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Stopped early],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[PISTE], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[2017], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[33], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[30], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ICA/M1], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[≤6 h], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Early-window standard LVO], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[mRS shift 90d], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Pragmatic], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[EASI], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[2017], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[37], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[40], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Mixed], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[≤6 h], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Early-window standard LVO], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[mRS 0-2 90d], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Small RCT], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[DEFUSE-3], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[2018], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[92], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[90], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ICA/M1], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[6-16 h], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Late-window/mismatch], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[mRS shift 90d], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Core \<70 mL], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[DAWN], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[2018], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[108], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[100], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ICA/M1], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[6-24 h], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Late-window/mismatch], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[mRS shift 90d], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Clinical-core mismatch], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Stopped early],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[RESILIENT], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[2020], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[111], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[112], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ICA/M1], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[≤8 h], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Early-window standard LVO], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[mRS 0-2 90d], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Public health system], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[BEST], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[2020], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[66], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[65], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Basilar], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[≤8 h], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Basilar artery occlusion], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[mRS 0-3 90d], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[BAO only], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Stopped early],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[BASICS], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[2021], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[154], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[146], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Basilar], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[≤6 h], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Basilar artery occlusion], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[mRS shift 90d], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[BAO only], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[POSITIVE], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[2022], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[12], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[21], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Mixed], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[≤12 h], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Late-window/mismatch], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[mRS shift 90d], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Perfusion-selected], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[BAOCHE], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[2022], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[111], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[106], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Basilar], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[6-24 h], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Basilar artery occlusion], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[mRS shift 90d], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[NIHSS ≥10], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ATTENTION], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[2022], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[225], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[115], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Basilar], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[≤12 h], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Basilar artery occlusion], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[mRS shift 90d], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[BAO only], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[RESCUE-Japan LIMIT], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[2022], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[100], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[102], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ICA/M1], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[≤6 h], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Large-core], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[mRS shift 90d], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ASPECTS 3-5], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[SELECT2], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[2023], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[177], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[171], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ICA/M1], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[≤24 h], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Large-core], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[mRS shift 90d], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ASPECTS 3-5 or core ≥50 mL], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Stopped early],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[MR CLEAN-LATE], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[2023], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[253], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[247], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ICA/M1], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[6-24 h], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Late-window], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[mRS shift 90d], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Good collaterals], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ANGEL-ASPECT], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[2023], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[230], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[225], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ICA/M1], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[≤24 h], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Large-core], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[mRS shift 90d], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Core ≥70 mL], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[TENSION], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[2023], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[124], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[122], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ICA/M1], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[≤12 h], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Large-core], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[mRS shift 90d], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ASPECTS 3-5], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[TESLA], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[2024], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[151], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[146], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ICA/M1], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[≤6 h], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Large-core], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[mRS shift 90d], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ASPECTS ≤5], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[LASTE], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[2024], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[159], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[165], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ICA/M1], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[≤6.5 h], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Large-core], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[mRS shift 90d], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ASPECTS ≤5], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Stopped early],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[DISTAL], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[2025], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[271], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[269], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Distal/DMVO], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[≤6 h], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Medium/distal vessel], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[mRS shift 90d], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[DMVO only], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ESCAPE-MeVO], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[2025], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[255], table.cell(align: horizon + right, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[274], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[M2/MeVO], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[≤12 h], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Medium vessel], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[mRS shift 90d], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[MeVO only], table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
)}
], caption: figure.caption(
separator: "", 
position: top, 
[
]), 
kind: "quarto-float-tbl", 
supplement: "Table", 
)
<tbl-s1>

#horizontalrule

#pagebreak(weak: true)
= Table S2. Risk of Bias Assessment
<table-s2.-risk-of-bias-assessment>
#figure([
#{set text(font: ("system-ui", "Segoe UI", "Roboto", "Helvetica", "Arial", "sans-serif", "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji") , size: 6.75pt); table(
  columns: 8,
  align: (left,left,left,left,left,left,left,left,),
  table.header(table.cell(align: bottom + left, fill: rgb("#f0f0f0"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); Trial], table.cell(align: bottom + left, fill: rgb("#f0f0f0"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); Random Sequence], table.cell(align: bottom + left, fill: rgb("#f0f0f0"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); Allocation Concealment], table.cell(align: bottom + left, fill: rgb("#f0f0f0"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); Blinding (Performance)], table.cell(align: bottom + left, fill: rgb("#f0f0f0"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); Blinding (Detection)], table.cell(align: bottom + left, fill: rgb("#f0f0f0"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); Attrition], table.cell(align: bottom + left, fill: rgb("#f0f0f0"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); Selective Reporting], table.cell(align: bottom + left, fill: rgb("#f0f0f0"))[#set text(size: 1.0em , weight: "bold" , fill: rgb("#333333")); Other],),
  table.hline(),
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[TESLA], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#f8d7da"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[High risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#ffffff"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[DISTAL], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#f8d7da"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[High risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#ffffff"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ESCAPE-MeVO], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#f8d7da"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[High risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#ffffff"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[TENSION], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#f8d7da"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[High risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#ffffff"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[THERAPY], table.cell(align: horizon + left, fill: rgb("#fff3cd"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Unclear risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#f8d7da"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[High risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#fff3cd"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Unclear risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[MR CLEAN-LATE], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#f8d7da"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[High risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#ffffff"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[THRACE], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#f8d7da"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[High risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#fff3cd"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Unclear risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[PISTE], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#f8d7da"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[High risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[POSITIVE], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#f8d7da"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[High risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#ffffff"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[RESILIENT], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#f8d7da"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[High risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[DEFUSE-3], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#f8d7da"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[High risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#fff3cd"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Unclear risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[DAWN], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#f8d7da"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[High risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[BASICS], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#f8d7da"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[High risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#ffffff"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[BEST], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#f8d7da"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[High risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#fff3cd"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Unclear risk],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[BAOCHE], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#f8d7da"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[High risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#ffffff"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ATTENTION], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#f8d7da"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[High risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#ffffff"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[EXTEND-IA], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#f8d7da"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[High risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#fff3cd"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Unclear risk],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[SWIFT PRIME], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#f8d7da"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[High risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ESCAPE], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#f8d7da"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[High risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#fff3cd"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Unclear risk],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[REVASCAT], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#f8d7da"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[High risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[MR CLEAN], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#f8d7da"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[High risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[IMS III], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#f8d7da"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[High risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#fff3cd"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Unclear risk],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[SYNTHESIS], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#fff3cd"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Unclear risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#ffffff"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[MR RESCUE], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#f8d7da"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[High risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#f8d7da"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[High risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[RESCUE-Japan LIMIT], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#f8d7da"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[High risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#ffffff"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[ANGEL-ASPECT], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#f8d7da"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[High risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#ffffff"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[SELECT2], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#f8d7da"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[High risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#ffffff"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[THRILL], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#fff3cd"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Unclear risk], table.cell(align: horizon + left, fill: rgb("#f8d7da"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[High risk], table.cell(align: horizon + left, fill: rgb("#fff3cd"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Unclear risk], table.cell(align: horizon + left, fill: rgb("#f8d7da"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[High risk], table.cell(align: horizon + left, fill: rgb("#f8d7da"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[High risk], table.cell(align: horizon + left, fill: rgb("#ffffff"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[EASI], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#fff3cd"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Unclear risk], table.cell(align: horizon + left, fill: rgb("#f8d7da"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[High risk], table.cell(align: horizon + left, fill: rgb("#f8d7da"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[High risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#ffffff"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.cell(align: horizon + left, stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[LASTE], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#f8d7da"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[High risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#d4edda"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[Low risk], table.cell(align: horizon + left, fill: rgb("#ffffff"), stroke: (top: (paint: rgb("#d3d3d3"), thickness: 0.75pt)))[],
  table.hline(),
  table.footer(table.cell(colspan: 8)[Green = Low risk; Red = High risk; Yellow = Unclear risk.],),
)}
], caption: figure.caption(
separator: "", 
position: top, 
[
]), 
kind: "quarto-float-tbl", 
supplement: "Table", 
)
<tbl-s2>

#horizontalrule

#pagebreak(weak: true)
= Table S3. Detailed References
<table-s3.-detailed-references>
All 30 included trials, listed by trial acronym.

+ #strong[SYNTHESIS] --- Ciccone A, Valvassori L, Nichelatti M, Sgoifo A, Ponzio M, Sterzi R, et al.~Endovascular Treatment for Acute Ischemic Stroke. #emph[N Engl J Med] 2013; 368:904--13.

+ #strong[IMS III] --- Broderick JP, Palesch YY, Demchuk AM, Yeatts SD, Khatri P, Hill MD, et al.~Endovascular therapy after intravenous t-PA versus t-PA alone for stroke. #emph[N Engl J Med] 2013; 368:893--903.

+ #strong[MR RESCUE] --- Kidwell CS, Jahan R, Gornbein J, Alger JR, Nenov V, Ajani Z, et al.~A trial of imaging selection and endovascular treatment for ischemic stroke. #emph[N Engl J Med] 2013; 368:914--23.

+ #strong[THRILL] --- Bendszus M, Thomalla G, Hacke W, Knauth M, Gerloff C, Bonekamp S, et al.~Early termination of THRILL, a prospective study of mechanical thrombectomy in patients with acute ischemic stroke ineligible for i.v. thrombolysis. #emph[Clin Neuroradiol] 2016; 26:499--500.

+ #strong[EASI] --- Khoury NN, Darsaut TE, Ghostine J, Deschaintre Y, Daneault N, Durocher A, et al.~Endovascular thrombectomy and medical therapy versus medical therapy alone in acute stroke: A randomized care trial. #emph[J Neuroradiol] 2017; 44:198--202.

+ #strong[LASTE] --- Costalat V, Jovin TG, Albucher JF, Cognard C, Henon H, Nouri N, et al.~Trial of thrombectomy for stroke with a large infarct of unrestricted size. #emph[N Engl J Med] 2024; 390:1677--89.

+ #strong[TESLA] --- Writing Committee for the TESLA Investigators, Yoo AJ, Zaidat OO, Sheth SA, Rai AT, Ortega-Gutierrez S, et al.~Thrombectomy for stroke with large infarct on noncontrast CT: The TESLA randomized clinical trial. #emph[JAMA] 2024; 332:1355--66.

+ #strong[DISTAL] --- Psychogios M, Brehm A, Ribo M, Rizzo F, Strbian D, Räty S, et al.~Endovascular treatment for stroke due to occlusion of medium or distal vessels. #emph[N Engl J Med] 2025; published online Feb 5. DOI:10.1056/NEJMoa2408954.

+ #strong[ESCAPE-MeVO] --- Goyal M, Ospel JM, Ganesh A, Dowlatshahi D, Volders D, Möhlenbruch MA, et al.~Endovascular treatment of stroke due to medium-vessel occlusion. #emph[N Engl J Med] 2025; published online Feb 5. DOI:10.1056/NEJMoa2411668.

+ #strong[TENSION] --- Bendszus M, Fiehler J, Subtil F, Bonekamp S, Aamodt AH, Fuentes B, et al.~Endovascular thrombectomy for acute ischaemic stroke with established large infarct: multicentre, open-label, randomised trial. #emph[Lancet] 2023; 402:1753--63.

+ #strong[THERAPY] --- Mocco J, Zaidat OO, von Kummer R, Yoo AJ, Gupta R, Lopes D, et al.~Aspiration Thrombectomy After Intravenous Alteplase Versus Intravenous Alteplase Alone. #emph[Stroke] 2016; 47:2331--8.

+ #strong[MR CLEAN-LATE] --- Olthuis SGH, Pirson FAV, Pinckaers FME, Hinsenveld WH, Nieboer D, Ceulemans A, et al.~Endovascular treatment versus no endovascular treatment after 6--24 h in patients with ischaemic stroke and collateral flow on CT angiography (MR CLEAN-LATE). #emph[Lancet] 2023; 401:1371--80.

+ #strong[THRACE] --- Bracard S, Ducrocq X, Mas JL, Soudant M, Oppenheim C, Moulin T, et al.~Mechanical thrombectomy after intravenous alteplase versus alteplase alone after stroke (THRACE): a randomised controlled trial. #emph[Lancet Neurol] 2016; 15:1138--47.

+ #strong[PISTE] --- Muir KW, Ford GA, Messow CM, Ford I, Murray A, Clifton A, et al.~Endovascular therapy for acute ischaemic stroke: the Pragmatic Ischaemic Stroke Thrombectomy Evaluation (PISTE) randomised, controlled trial. #emph[J Neurol Neurosurg Psychiatry] 2017; 88:38--44.

+ #strong[POSITIVE] --- Mocco J, Siddiqui AH, Fiorella D, Alexander MJ, Arthur AS, Baxter BW, et al.~POSITIVE: Perfusion imaging selection of ischemic stroke patients for endovascular therapy. #emph[J Neurointerv Surg] 2022; 14:126--32.

+ #strong[RESILIENT] --- Martins SO, Mont'Alverne F, Rebello LC, Abud DG, Silva GS, Lima FO, et al.~Thrombectomy for Stroke in the Public Health Care System of Brazil. #emph[N Engl J Med] 2020; 382:2316--26.

+ #strong[DEFUSE-3] --- Albers GW, Marks MP, Kemp S, Christensen S, Tsai JP, Ortega-Gutierrez S, et al.~Thrombectomy for Stroke at 6 to 16 Hours with Selection by Perfusion Imaging. #emph[N Engl J Med] 2018; 378:708--18.

+ #strong[DAWN] --- Nogueira RG, Jadhav AP, Haussen DC, Bonafe A, Budzik RF, Bhuva P, et al.~Thrombectomy 6 to 24 Hours after Stroke with a Mismatch between Deficit and Infarct. #emph[N Engl J Med] 2018; 378:11--21.

+ #strong[BASICS] --- Langezaal LCM, van der Hoeven EJRJ, Mont'Alverne FJA, de Carvalho JJF, Lima FO, Dippel DWJ, et al.~Endovascular Therapy for Stroke Due to Basilar-Artery Occlusion. #emph[N Engl J Med] 2021; 384:1910--20.

+ #strong[BEST] --- Liu X, Dai Q, Ye R, Zi W, Liu Y, Wang H, et al.~Endovascular treatment versus standard medical treatment for vertebrobasilar artery occlusion (BEST): an open-label, randomised controlled trial. #emph[Lancet Neurol] 2020; 19:115--22.

+ #strong[ATTENTION] --- Tao C, Nogueira RG, Zhu Y, Sun J, Han H, Yuan G, et al.~Trial of Endovascular Treatment of Acute Basilar-Artery Occlusion. #emph[N Engl J Med] 2022; 387:1361--72.

+ #strong[BAOCHE] --- Jovin TG, Li C, Wu L, Wu C, Chen J, Jiang C, et al.~Trial of Thrombectomy 6 to 24 Hours after Stroke Due to Basilar-Artery Occlusion. #emph[N Engl J Med] 2022; 387:1373--84.

+ #strong[EXTEND-IA] --- Campbell BCV, Mitchell PJ, Kleinig TJ, Dewey HM, Churilov L, Yassi N, et al.~Endovascular therapy for ischemic stroke with perfusion-imaging selection. #emph[N Engl J Med] 2015; 372:1009--18.

+ #strong[SWIFT PRIME] --- Saver JL, Goyal M, Bonafe A, Diener H-C, Levy EI, Pereira VM, et al.~Stent-retriever thrombectomy after intravenous t-PA vs.~t-PA alone in stroke. #emph[N Engl J Med] 2015; 372:2285--95.

+ #strong[ESCAPE] --- Goyal M, Demchuk AM, Menon BK, Eesa M, Rempel JL, Thornton J, et al.~Randomized assessment of rapid endovascular treatment of ischemic stroke. #emph[N Engl J Med] 2015; 372:1019--30.

+ #strong[REVASCAT] --- Jovin TG, Chamorro A, Cobo E, de Miquel MA, Molina CA, Rovira A, et al.~Thrombectomy within 8 hours after symptom onset in ischemic stroke. #emph[N Engl J Med] 2015; 372:2296--306.

+ #strong[MR CLEAN] --- Berkhemer OA, Fransen PSS, Beumer D, van den Berg LA, Lingsma HF, Yoo AJ, et al.~A randomized trial of intraarterial treatment for acute ischemic stroke. #emph[N Engl J Med] 2015; 372:11--20.

+ #strong[RESCUE-Japan LIMIT] --- Yoshimura S, Sakai N, Yamagami H, Uchida K, Beppu M, Toyoda K, et al.~Endovascular Therapy for Acute Stroke with a Large Ischemic Region. #emph[N Engl J Med] 2022; 386:1303--13.

+ #strong[ANGEL-ASPECT] --- Huo X, Ma G, Tong X, Zhang X, Pan Y, Nguyen TN, et al.~Trial of Endovascular Therapy for Acute Ischemic Stroke with Large Infarct. #emph[N Engl J Med] 2023; 388:1272--83.

+ #strong[SELECT2] --- Sarraj A, Hassan AE, Abraham MG, Ortega-Gutierrez S, Kasner SE, Hussain MS, et al.~Trial of Endovascular Thrombectomy for Large Ischemic Strokes. #emph[N Engl J Med] 2023; 388:1259--71.

#horizontalrule

#pagebreak(weak: true)
= Main Model Specification
<main-model-specification>
The main model was a Bayesian hierarchical proportional-odds cumulative ordinal model fit with `brms` (Stan backend via `cmdstanr`). The model formula was:

```
mrs_better | weights(count) ~ treatment + (1 + treatment | trial)
Family: cumulative (logit link)
Priors: Normal(0, 1) for fixed effects, standard deviations, and thresholds
Chains: 4  |  Iterations: 2000 (1000 warmup)  |  Total post-warmup draws: 4000
```

#strong[Main model summary output:]

```
Family: cumulative
Links: mu = logit
Formula: ordinal_value ~ treatment + (1 + treatment | trial)
Data: data_long (Number of observations: 8100)
Draws: 4 chains, each with iter = 2000; warmup = 1000; thin = 1;
       total post-warmup draws = 4000

Multilevel Hyperparameters:
~trial (Number of levels: 30)

                                     Estimate Est.Error l-95% CI u-95% CI Rhat Bulk_ESS Tail_ESS
sd(Intercept)                           0.75      0.11     0.57     1.00 1.00     1003     1605
sd(treatmentthrombectomy)               0.35      0.08     0.22     0.51 1.00     1472     2142
cor(Intercept,treatmentthrombectomy)   -0.49      0.18    -0.79    -0.09 1.00     2250     2565

Regression Coefficients:
              Estimate Est.Error l-95% CI u-95% CI Rhat Bulk_ESS Tail_ESS
Intercept[1]    -1.08      0.15    -1.37    -0.80 1.01      490     1069
Intercept[2]    -0.52      0.14    -0.81    -0.24 1.01      485     1124
Intercept[3]     0.25      0.14    -0.03     0.53 1.01      488      949
Intercept[4]     0.96      0.14     0.67     1.23 1.01      488      953
Intercept[5]     1.69      0.14     1.41     1.98 1.01      496     1114
Intercept[6]     2.91      0.15     2.62     3.21 1.01      520     1028
treatmentthrombectomy  0.46  0.08  0.30  0.62 1.00  1467  2271
```

All Rhat values ≤ 1.01, indicating convergence. Bulk and tail effective sample sizes were adequate (all \>400 for key parameters).

#pagebreak(weak: true)
= Model Diagnostics
<model-diagnostics>
The following diagnostic figures are generated by running `run.R` and are saved to `artifacts/` (not tracked in git due to file size). After running the analysis, they can be found at the paths indicated.

#strong[Trace Plots] (`Figures/ordinal_trace_plots.svg`)

Markov chain trace plots for the six threshold parameters, the treatment effect, and the three variance-covariance hyperparameters.

#figure([
#box(image("../Figures/ordinal_trace_plots.svg"))
], caption: figure.caption(
position: bottom, 
[
Trace plots for main model parameters.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-trace>


#emph[If this figure is missing, run `master_supporting_docs/supporting_code/run.R` to generate the diagnostic SVGs.]

#horizontalrule

#strong[R-hat and Effective Sample Size] (`Figures/ordinal_convergence_values.svg`)

#figure([
#box(image("../Figures/ordinal_convergence_values.svg"))
], caption: figure.caption(
position: bottom, 
[
R-hat values and effective sample sizes for main model.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-rhat>


#emph[If this figure is missing, run `master_supporting_docs/supporting_code/run.R` to generate the diagnostic SVGs.]

#horizontalrule

#strong[Posterior Predictive Check] (`Figures/ordinal_posterior_predictive_check.svg`)

#figure([
#box(image("../Figures/ordinal_posterior_predictive_check.svg"))
], caption: figure.caption(
position: bottom, 
[
Posterior predictive check for the main model, grouped by treatment arm.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-ppc>


#emph[If this figure is missing, run `master_supporting_docs/supporting_code/run.R` to generate the diagnostic SVGs.]

#horizontalrule

#strong[Prior Sensitivity] (`Figures/ordinal_power_scaling_sensitivity.svg`)

Prior power-scaling sensitivity analysis for key model parameters. Sensitivity was low across all parameters.

#figure([
#box(image("../Figures/ordinal_power_scaling_sensitivity.svg"))
], caption: figure.caption(
position: bottom, 
[
Prior sensitivity (power-scaling) analysis for the main model.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-prior>


#emph[If this figure is missing, run `master_supporting_docs/supporting_code/run.R` to generate the diagnostic SVGs.]

#horizontalrule

#pagebreak(weak: true)
= Alternative Models
<alternative-models>
Three additional prespecified models were fit to assess robustness of the main findings.

#strong[Alternative Model 1: Ordinal (PO + Unequal Variances)]

```
Family: cumulative
Links: mu = logit; disc = log
Formula: mrs_better | weights(count) ~ treatment + (1 + treatment | trial)
         disc ~ 0 + treatment
Data: data_long (Number of observations: 420)
Draws: 4 chains, each with iter = 2000; warmup = 1000; thin = 1;
       total post-warmup draws = 4000

Multilevel Hyperparameters (~trial, 30 levels):
  sd(Intercept)                           0.80  (SE 0.11; 95% CI 0.61–1.04)
  sd(treatmentthrombectomy)               0.37  (SE 0.08; 95% CI 0.23–0.55)
  cor(Intercept,treatmentthrombectomy)   -0.46  (SE 0.19; 95% CI -0.76 to -0.06)

Key Regression Coefficients:
  treatmentthrombectomy       0.48  (SE 0.08; 95% CI 0.31–0.64)
  disc_treatmentthrombectomy -0.14  (SE 0.02; 95% CI -0.18 to -0.09)
```

#strong[Alternative Model 2: Ordinal (Adjacent-Category)]

```
Family: acat (adjacent-category logit)
Formula: mrs_better | weights(count) ~ treatment + (1 + treatment | trial)
Data: data_long (Number of observations: 403)
Draws: 4 chains, each with iter = 2000; warmup = 1000; thin = 1;
       total post-warmup draws = 4000

Multilevel Hyperparameters (~trial, 30 levels):
  sd(Intercept)                           0.25  (SE 0.04; 95% CI 0.19–0.33)
  sd(treatmentthrombectomy)               0.11  (SE 0.02; 95% CI 0.07–0.17)
  cor(Intercept,treatmentthrombectomy)   -0.62  (SE 0.16; 95% CI -0.87 to -0.28)

Key Regression Coefficients:
  treatmentthrombectomy   0.15  (SE 0.03; 95% CI 0.10–0.20)
```

#strong[Alternative Model 3: Binary (mRS 0--2 vs 3--6)]

```
Family: binomial (logit link)
Formula: good_n | trials(total_n) ~ treatment + (1 + treatment | trial)
Data: data_bin (Number of observations: 60)
Draws: 4 chains, each with iter = 2000; warmup = 1000; thin = 1;
       total post-warmup draws = 4000

Multilevel Hyperparameters (~trial, 30 levels):
  sd(Intercept)                           0.98  (SE 0.14; 95% CI 0.74–1.29)
  sd(treatmentthrombectomy)               0.54  (SE 0.10; 95% CI 0.37–0.78)
  cor(Intercept,treatmentthrombectomy)   -0.65  (SE 0.14; 95% CI -0.88 to -0.32)

Key Regression Coefficients:
  Intercept               -1.16  (SE 0.18; 95% CI -1.52 to -0.81)
  treatmentthrombectomy    0.67  (SE 0.12; 95% CI 0.44–0.90)
```

All three alternative models yield a consistently negative intercept--slope correlation, confirming robustness of the main finding.

#horizontalrule

#pagebreak(weak: true)
= Figure S1. Robustness of $rho$ to Model Specification
<figure-s1.-robustness-of-rho-to-model-specification>
Posterior medians and 95% credible intervals for $rho$ under the primary proportional-odds ordinal model and three alternative prespecified models: an unequal-variance proportional-odds model, an adjacent-category ordinal model, and a binary model (mRS 0--2 vs 3--6). Estimates remain negative across all specifications.

#figure([
#box(image("../Figures/figure_three.svg", width: 100.0%))
], caption: figure.caption(
position: bottom, 
[
Figure S1. Robustness of the intercept--slope correlation to model specification.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)

#horizontalrule

#pagebreak(weak: true)
= Figure S2. Absolute Benefit Across Model Specifications
<figure-s2.-absolute-benefit-across-model-specifications>
For each model, points show each trial's posterior median control-group probability of functional independence (x-axis) and posterior median absolute benefit in functional independence due to thrombectomy (y-axis). Functional independence is defined as mRS 0--2. The dashed line indicates no absolute benefit; the smooth curve is a descriptive fit with 95% uncertainty band.

#figure([
#box(image("../Figures/figure_four.svg", width: 100.0%))
], caption: figure.caption(
position: bottom, 
[
Figure S2. Baseline prognosis and absolute benefit in functional independence.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)






