# ElMagConspect: notes for Claude

Reply in Russian (the user writes in Ukrainian or Russian). Comments in `book.js` / `conspect.css` are Ukrainian,
in Python / PowerShell scripts English: keep that. Commits go straight to `main`; commit and push only when asked.

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
- `elmag.py` is the entry point for everything (pdf, html, serve, clean, purge, size, status, push): an interactive
  shell or one command; it only calls the scripts. A new script of the project gets a command there.
  `run.ps1` skips its pause and Clear-Host when `ELMAG_CLI` is set.
- One chapter with the book class: `python chapter.py <Folder> --png` (test.tex + latexmk -usepretex) ->
  `_chapters/<Folder>.pdf` and page PNGs to check the layout (widows, split boxes). Refs to other chapters stay `??`.
  Do not edit chapter sources while the full book build runs: latexmk then hits "too many passes".

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
