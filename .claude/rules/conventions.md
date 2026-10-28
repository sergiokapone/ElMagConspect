---
paths:
  - "**/*.tex"
  - "*.cls"
---

# ElMagConspect: agreed conventions (from the review, agreed with the author)

These are decisions already made. Follow them; if you think one is wrong, say so to the author instead of silently changing it.

## Audience and depth
- 2nd-year applied physicists. Proofs are explained visually; stricter derivations go into `Extra` (small font, no box) under a starred `subsection*{...*}`, never into an `Example` box.
- Units: Gaussian in parts I-VI; SI in part VII (ElMagOscillations, Telegraph, Waveguides), deliberately. The Preface explains it.
  The Preface treats the ampere (since 2019: fixed `e`) and `ε₀, μ₀` as conversion coefficients: keep that wording.

## Didactic boxes
- Use `Attention` boxes sparingly; do not turn the exposition into a sequence of highlighted boxes.
- During chapter review, evaluate every `Attention` box. Retain it when it highlights a genuinely important physical caveat, common misconception, condition of applicability, or other information that benefits from visual emphasis.
- Move routine explanations, intermediate reasoning, and material that reads naturally in the main text out of boxes. Merge overlapping boxes where appropriate.
- Do not impose a fixed numerical limit. The goal is to remove unnecessary boxes while preserving essential physics, pedagogical clarity, and the logical flow of the exposition.
- During review, explicitly identify which boxes to retain, merge, or convert to ordinary text.

## Terminology and notation
- Words: «замкнена», «еквіпотенціальна», «загальність» (not «спільність»), «стала» (not «постійна»), «безслідовий»,
  «прискорювальна», «Ван де Граафа», «електрично ізольована» (not «замкнена система» for charge conservation).
- «СІ» in Cyrillic everywhere (never «SI» in the text). Dash: `~---`. TeX/TM/TEM in Latin letters.
- Polarization: α is *поляризовність* (of an atom or molecule only); χ is *діелектрична сприйнятливість* (χ_m magnetic, in
  MagFieldMedia); **P** is the *вектор поляризації* (поляризованість). Do not mix these.
- Vectors are bold; moduli are plain. Coulomb force: **F**₁₂ acts on q₂, **r**₁₂ points from q₁ to q₂.
- Unit vectors: `\vect e_k`, `\vect e_z`, `\vect e_b` (no hat `\hat{...}`: that is a foreign-textbook tradition, not Ukrainian). Basis vectors i, j, k stay `\vect i` etc.; `\hat{q}` for a complex amplitude is a different thing and stays.
- Symbols used for several quantities are listed in `Additions/Notations.tex`; add new ones there. ρ is overloaded
  (charge density / resistivity / ρ_m): resistivity is `\varrho` where it is touched.
- Greek stays in math mode (the Bookman font has no polytonic Greek).

## References
- To a paragraph: `\S~\ref{...}`. To a chapter: `розділ~\ref{...}` (not «гл.», not «розд.»).
- Epigraphs are real quotations with a source (author, work, year; translation checked against the original when possible).
  Never invent an epigraph. Unverified ones are listed in `STATUS.md`.

## Layout (print)
- Answers to problems written in the chapter text are commented out (`%Відповідь: ...`) so that they are not printed there.
  The answers section at the end of the book is built by the `answers` package from the `solution` blocks
  (`<Folder>-Answers.tex`, generated and git-ignored: never edit it by hand).
- Problems must not break across pages: around the «Задачі» section
  `\begingroup\tcbset{answersolutionstyle/.append style={unbreakable}} ... \endgroup`. The class itself is not changed (yet).
- Short boxes (`Attention`, `Example`, `Historical`) that would split into 1-3 lines get `[unbreakable]`. A box taller than a page
  (e.g. with a figure) stays breakable, otherwise: overfull \vbox.
- Environments in use: `problem`/`solution`, `Attention`, `Example`, `Historical`, `Extra`, `Questions`, `quizlist`,
  `SCfigure`, `wrapstuff`, key formulas in `\tcbhighmath{...}`, term definitions in `\emphx{...}`.
- Figures go outside the boxes (`Example`, `Attention`, `Historical`, `Extra`): right after `\end{...}`, as `figure` / `SCfigure`.
  A figure inside a box breaks the box across pages and the references to it. Check this in every chapter during review.
- Anything added to chapters for print (tcolorbox commands etc.) must also be defined in `ConspectBookHTML.cls`
  (there `\tcbset` is an empty stub). Check with `python elmag.py html` after a review round.
- Check the layout of an edited chapter with `python chapter.py <Folder> --png` and look at the PNGs.

## Physics checks that found real errors in this book
Use them when reading any chapter:
- Applicability limits stated, not implied. Example: «квазістаціонарно» does not mean «без індукції»: the self-inductance EMF
  `-L dI/dt` still enters Kirchhoff's second rule unless it is negligible.
- Consistency of ε and 4π between chapters (`div E = 4πρ` vs `4πρ/ε`: free charge in a medium). Same symbol, same meaning.
- Recompute every number and every answer; check orders of magnitude (a 1000× slip was found in a superconductor problem).
- Signs and directions in examples (currents in the Kirchhoff example, forces at I = const vs Φ = const); text vs figure
  (arcs/contours in a figure must match the equations in the text).
- A heuristic argument must not be passed off as a derivation (half-sphere earthing: use mirror symmetry, not «half the capacity»).
- Historical claims: dates, names, what an experiment really showed (Einstein-de Haas gave classical γ; Millikan 1909-1913).
