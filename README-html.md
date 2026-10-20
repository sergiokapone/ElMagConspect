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
Newer pgf/lwarp (MiKTeX) fail on pictures with `name/.pic={...}` in the tikzpicture options (`\tikz@smuggle@pics@in`,
5 pictures). I could not reproduce it (my TeX Live 2023 is older), so prepare_html.py compiles such a picture ALONE
(lualatex + pdfcrop + pdftocairo) into _html/ext/pic-*.svg and puts \includegraphics there; if that fails it falls back
to lateximage. Keep _html/ext/ together with the HTML. In the print pass (lualatex main-html) these pictures are boxes: SVG is used only in HTML mode (\htmlpicture). Some SVG are very large (up to ~23 MB in my build: pdftocairo expands shadings), consider PNG for those later.
More version-specific errors are possible: send the line with `!` and the tikz file name printed before it.
After editing the class run `lwarpmk again -p main-html` before `lwarpmk html` (otherwise lwarpmk says 'up to date').
Chapters are never edited: prepare_html.py writes copies into _html/ (tikz fixes; chapter copies where a text-mode \ce inside a
\caption is wrapped in $..$, because lwarp 0.922 fails on it) and the class reads the copy first (\multiinclude, \localinput).
tblr tables: lwarp cannot read tabularray, so prepare_html.py converts the book's tables (colspec X/Q/l/c/r, row{..} bg/fg/font,
cell{..}{..} mode=dmath, hlines/vlines) into tabularx in the chapter copies -> real HTML tables, formulas through MathJax.
Tables it does not understand stay tblr and become images (the class falls back to lateximage); prepare_html.py lists them.
Column tints (Q[..,bg=..]) are off by default (KEEP_COLUMN_COLORS in prepare_html.py): lwarp writes them as invalid <div> inside <p>.
Additions/SGStoSI.tex is not a chapter folder file and is not processed.
Stray ^ in the HTML (<meta ... ^/>, -^->, ^</title>, https:^//): lwarp types HTML tags in the monospace font, and the programming
ligatures (calt) of JetBrains Mono (--> </ /> //) make pdftotext print a ^. The class switches calt/liga off for that font
(reproduced and verified). After rebuilding, a post-processing script like fix_html.py should not be needed.
The same ligatures also corrupted formulas (`\frac 1^{|..}`, `_^-|`, `]^{{`): fixed by the same class change.
check-mathjax-html.js (node + `npm i mathjax-full`) runs every formula of a page through MathJax and lists the failing ones.
Operators from babel (\tg, \ctg, \arctg, \sh, \ch, \cth, \cosec) are not in the class, so mathjax2lwarp.py adds them to the MathJax macros.
\emf is always defined for MathJax (mathjax2lwarp.py, ALWAYS): in LaTeX it is \mathemf{E} (BOONDOX-cal alphabet of the emf package), MathJax
has no such alphabet, so it uses \mathcal{E}: close, not identical to the print.
Known: `\tag{\theequation а}` (2 places in SteadyEfield) cannot work in MathJax: \theequation is a LaTeX counter.
Known: 1 undefined reference (Grin1) and 1 citation (Jefimenko1962; MyBase.bib was not in the zip) in the log.
Decisions: \vect -> \mathbf in MathJax (bold upright like print, Greek letters not bold); in HTML tblr tables are
images, wrapstuff is a figure, solution is an inline block, \tikzmarknode/\tikz overlays inside formulas are dropped.
