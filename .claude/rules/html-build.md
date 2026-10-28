---
paths:
  - "publish_html.py"
  - "prepare_html.py"
  - "build-html.ps1"
  - "mathjax*"
  - "lwarp*"
  - "check-mathjax-html.js"
  - "ConspectBookHTML.cls"
  - "docs/assets/**"
  - "README-html.md"
---

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
- `mathjax-macros.tex` is generated (TSS Workflow, from `ConspectBook.cls`) and can silently lose entries when the class changes
  (`\tcbhighmath` was lost this way: no boxes in the HTML). Macros that must always reach MathJax go to `ALWAYS` in `mathjax2lwarp.py`.
  `npm i` in the project root installs `mathjax-full@3`; then `build-html.ps1` runs `check-mathjax-html.js` (every formula of the
  page through MathJax with the macros from `lwarp-mathjax.tex`) and reports undefined macros. Run it by hand:
  `node check-mathjax-html.js docs/ch*.html`.
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
