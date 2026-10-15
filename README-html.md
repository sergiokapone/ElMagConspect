# ConspectWeb: HTML version of ElMagConspect (lwarp)

Put the files from src/ into the project root (next to main.tex). Chapters are not modified.

    python mathjax2lwarp.py mathjax-macros.tex lwarp-mathjax.tex
    python prepare_html.py          # PDF pictures -> SVG, fixes for 10 tikz files (copies go to _html/)
    lualatex main-html
    biber main-html
    lwarpmk html                    # long: ~15 min on a Linux sandbox; whole book = 20 pages index*.html -> ch*.html
    lwarpmk limages                 # 266 images, ~2 min
Open main-html.html (title + contents) in a browser with internet (MathJax comes from a CDN).
After changing the class or chapters: `lwarpmk again`, then `lwarpmk html`.
Needs TeX Live (lwarp, biber, pdfcrop), Python 3. Output names are ch1.html ... (HTMLFilename={ch}), your index.html is untouched.
Add to .gitignore: _html/ lwarp-*.tex main-html_html.* *.lwarpmkconf lateximagetemp-* main-html-images/ ch*.html

Verified (Linux sandbox, TeX Live 2023, fonts: FreeSerif instead of Bookman): all 20 chapters and the whole book build
without LaTeX errors; 15 387 formula fragments; 266 images generated, all referenced files exist, 12 sampled figures look right.
Not verified: Windows/MiKTeX, your fonts, the pages in a browser (MathJax, CSS), the ch*.html naming on the whole book
(tested on one chapter), `lwarpmk html` calling biber by itself.
Known: 1 undefined reference (Grin1) and 1 citation (Jefimenko1962; MyBase.bib was not in the zip) in the log.
Decisions: \vect -> \mathbf in MathJax (bold upright like print, Greek letters not bold); in HTML tblr tables are
images, wrapstuff is a figure, solution is an inline block, \tikzmarknode/\tikz overlays inside formulas are dropped.
