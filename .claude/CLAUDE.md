# ElMagConspect: notes for Claude

Ukrainian textbook «Електрика та магнетизм» (author С. М. Пономаренко). LaTeX (LuaLaTeX + biber + upmendex), 20 chapters in
7 parts; output: printed PDF and an HTML site (lwarp -> GitHub Pages). Windows, PowerShell, MiKTeX.

Reply in Russian (the user writes in Ukrainian or Russian). Book text, review remarks and TeX comments are Ukrainian;
comments in `book.js` / `conspect.css` are Ukrainian, in Python / PowerShell scripts English: keep that.
Commits go straight to `main`; commit and push only when asked.

## Read first
- @STATUS.md: where the review stopped, open items, decisions waiting for the author. Update it at the end of a work session.
- `.claude/HANDOFF.md`, if it exists: an interrupted task left by the previous session. At the first user message read it,
  say in one line what you are going to continue, then finish the task from where it stopped (check `git status` / `git diff`
  against what the file says before editing). When done: delete `HANDOFF.md` and update `STATUS.md`. If the file is stale or
  contradicts the files on disk, ask the author instead of guessing.
- `.claude/rules/conventions.md`: agreed terminology, notation, references, layout rules (loads when you touch `.tex` / `.cls`).
- `/review-chapter <Folder>`: the review protocol (remarks -> agree with the author -> edits -> layout check).
- `REVIEW.md` (in git): history of the review, chapter by chapter, with commit hashes. An archive: do not load it whole.
- `review-remarks.md` (local, not in git, ~47 KB): numbered remarks per chapter. Markers: [+] done, [~] done partly or
  differently, [-] author kept as is, [?] open. Never read it whole: `grep -n '^## ' review-remarks.md`, then open one section.

## Project map
- `main.tex`: front matter, `Preface.tex`, then 7 parts via `\multiinclude{...}`:
  I Charges, SteadyEfield, ChargeSystem, FieldInMetalls, FieldInDielectrics, ElEnergy;
  II SteadyCurrent, CurrentsInMedia; III MagFieldVacuum, MagFieldMedia; IV EBMotion;
  V ElMagInduction, MagEnergy, MaxwellEqns, Relativity; VI ElMagWaves, Radiation;
  VII ElMagOscillations, Telegraph, Waveguides.
  After the parts: answers (`\answers`, `<Folder>-Answers.tex`), appendices `Additions/` (SGStoSI, Notations, Vanaliz),
  bibliography, index. `Plasma/` and `Tensions/` exist but are not included in `main.tex` (maybe deliberately: ask before touching).
- A chapter = `<Folder>/<Folder>.tex` + `Pictures/` + `tikz/`. Units: Gaussian in parts I-VI, SI in part VII (deliberately).
- Classes: `ConspectBook.cls` (print), `ConspectBookHTML.cls` (lwarp). Whatever is added for print must exist in the HTML class too.
- Generated or local, not sources: `*-Answers.tex`, `*.bak*`, `*.cut`, `lwarp*`, `main*.{aux,bbl,bcf,log,...}`, `_html/`, `_chapters/`,
  `__pycache__`, `docs/` (published site). Do not read or edit them unless the task is about them. Old versions are in git, not in `.bak*`.
- The bibliography path in `main.tex` points to the author's machine (`d:/Projects/LaTeX/MyPackages/bib/MyBase.bib`): the book will not
  build elsewhere without it.

## Build and check
- Whole book: `python elmag.py pdf` (run.ps1: latexmk, stops at the first error). Do not edit chapter sources while it runs:
  latexmk then hits "too many passes".
- One chapter with the book class: `python chapter.py <Folder> --png` (test.tex + latexmk -usepretex) ->
  `_chapters/<Folder>.pdf` and page PNGs to check the layout (widows, split boxes). `--tikz <name>` builds one picture.
  Refs to other chapters stay `??`; the running head shows "Частина .": that is normal.
- After a review round: `python elmag.py pdf`, then `python elmag.py html`, commit `docs/`, push (only when asked).
- `elmag.py` is the entry point for everything (pdf, html, serve, clean, purge, size, status, push, chapter): an interactive
  shell or one command; it only calls the scripts. A new script of the project gets a command there.
  `run.ps1` skips its pause and Clear-Host when `ELMAG_CLI` is set.

## HTML build (details: README-html.md)
`build-html.ps1` -> lwarp (`ConspectBookHTML.cls`) -> `prepare_html.py` (chapter copies) -> `publish_html.py` (moves the site to `docs/`, GitHub Pages).

- `docs/` is wiped on every publish except `SITE_OWN` in `publish_html.py` (`index.html`, `google*.html`, `assets/`, `serve.py`).
  So a fix to the generated pages goes into `publish_html.py` / `prepare_html.py`, never into `docs/*.html` by hand
  (patching `docs/` directly is fine only as a preview of the same change).
- The source of `book.js` and `conspect.css` is `docs/assets/`; there is no copy in the project root
  (a root copy, if newer, would replace it on publish).
- Preview: `python docs/serve.py` (Pagefind search needs http, not file://). `docs/serve.py` is git-ignored.
- The PDF (`docs/ElMagConspect.pdf`) stays in the repo on purpose: the landing page links into it (`#Charges`) and
  ElMagLectures/index.html shows it in an iframe via jsDelivr. GitHub Release assets were rejected (served only as
  downloads). The repo is cleaned of old PDF / docs/ versions periodically with `clean_repo.py` (`--dry-run` first).

## MathJax
- lwarp 0.922 hard-codes MathJax 3 (`mathjax@3/es5/tex-svg.js`) with its own `startup.ready()` code that uses v3-internal
  modules; MathJax 4 would need that code ported. MathJax 3 has no line breaking: `book.js` splits long display
  formulas itself (top-level TeX break points -> `aligned`).
- For numbered equations MathJax 3 SVG sets `min-width` on the `mjx-container` itself: measure the column by the parent.
- Macros for MathJax: `mathjax-macros.tex` -> `mathjax2lwarp.py` -> `lwarp-mathjax.tex`.

## lwarp quirks
- Contents entries (`a.tocchapter`, `a.tocsection`) are CSS grids (number | title); `publish_html.py` wraps the title
  in `span.toctitle` so inline math stays in the title column.

## Testing JS that uses MathJax
Install `mathjax-full@3` in the scratchpad and run the functions in node with liteAdaptor. Define macros with
`\newcommand` through `doc.convert(...)`: macros given in the TeX config that expand to `\boxed`/`\fbox` crash in node.
