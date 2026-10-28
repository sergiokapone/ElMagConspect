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
- `review/<Folder>.md` (local, not in git): numbered remarks, one small file per chapter (`review/_README.md`: markers [+] done, [~] done partly or
  differently, [-] author kept as is, [?] open; `_main-tex.md`, `_general.md`: remarks outside chapters). Open only the file of the chapter in hand.

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
- Layout check of the whole PDF: `python elmag.py lint` (`layout_lint.py`, PyMuPDF): sparse pages (`gap-bottom`, `gap-inside`),
  widows, orphans, tcolorbox slivers (1-2 lines of a split box). `--chapter <part of the title>`, `--sheet` saves contact sheets
  of the flagged pages to `_lint/`. Reads `docs/ElMagConspect.pdf` (or `main.pdf`); the answers section is skipped.
  A `gap-inside` usually means: with `\flushbottom` the empty space left by an unbreakable box or a float that did not fit is spread
  over the glue around headings; cure: make that box breakable or move the figure before it.
- After a review round: `python elmag.py pdf`, then `python elmag.py html`, commit `docs/`, push (only when asked).
- `elmag.py` is the entry point for everything (pdf, html, serve, clean, purge, size, status, push, chapter): an interactive
  shell or one command; it only calls the scripts. A new script of the project gets a command there.
  `run.ps1` skips its pause and Clear-Host when `ELMAG_CLI` is set.

## HTML build, MathJax, lwarp
Details are in `.claude/rules/html-build.md` (loads when you touch the HTML scripts, `ConspectBookHTML.cls`, `docs/assets/`) and in `README-html.md`.
The one rule to remember: `docs/` is wiped on every publish, so a fix to generated pages goes into `publish_html.py` / `prepare_html.py`, never into `docs/*.html` by hand.

## Compact instructions
When compacting, keep: the task in progress, decisions agreed with the author, file paths and line anchors of the places being edited, the list of uncommitted changes.
Drop: contents of files read earlier, build logs, rejected options.
