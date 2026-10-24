#!/usr/bin/env python3
"""Builds one chapter (or one TikZ picture) of the book with the book class, through test.tex.

  python chapter.py Charges                 _chapters/Charges.pdf
  python chapter.py Charges --png           also _chapters/Charges/page-NN.png (to look at the layout)
  python chapter.py Charges --tikz Columb   only the picture Charges/tikz/Columb.tikz -> _chapters/Charges-Columb.pdf

test.tex takes the chapter from \\TargetChapter (and the picture from \\TargetTikz); they are passed with
latexmk -usepretex. References to other chapters stay '??': the chapter is built alone.
After the build the overfull/underfull boxes of the log are listed with their source lines."""
import argparse, glob, os, re, subprocess, sys

ROOT = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(ROOT, '_chapters')


def boxes(log):
    """Overfull/underfull box warnings of a LaTeX log: [(kind, amount, 'file:lines')]."""
    with open(log, encoding='utf-8', errors='replace') as f: text = f.read()
    found = []
    for m in re.finditer(r'(Overfull|Underfull) \\([hv])box \(([^)]*)\)([^\n]*)', text):
        at = re.search(r'lines? (\d+(?:--\d+)?)', m.group(4))
        found.append((m.group(1) + ' \\' + m.group(2) + 'box', m.group(3), at.group(1) if at else ''))
    return found


def main():
    ap = argparse.ArgumentParser(description='Build one chapter of the book with the book class (test.tex).')
    ap.add_argument('chapter', help='chapter folder, e.g. Charges')
    ap.add_argument('--tikz', help='build only this picture of <chapter>/tikz/ (name without .tikz)')
    ap.add_argument('--png', action='store_true', help='render the pages to PNG (pdftoppm, 110 dpi)')
    ap.add_argument('--full', action='store_true', help='whole latexmk output')
    a = ap.parse_args()

    src = os.path.join(ROOT, a.chapter, a.chapter + '.tex')
    if not os.path.isfile(src): print('No %s' % os.path.relpath(src, ROOT)); return 1
    pretex = r'\def\TargetChapter{%s}' % a.chapter
    job = a.chapter
    if a.tikz:
        pretex += r'\def\TargetTikz{%s}' % a.tikz
        job += '-' + a.tikz
    os.makedirs(OUT, exist_ok=True)
    cmd = ['latexmk', '-lualatex', '-interaction=nonstopmode', '-halt-on-error', '-file-line-error',
           # latexmk runs the indexer inside -outdir: the style of latexmkrc needs its full path there
           '-e', '$makeindex = q(upmendex -s "%s" %%O -o %%D %%S)' % os.path.join(ROOT, 'index-uk.ist').replace('\\', '/'),
           '-jobname=' + job, '-outdir=' + OUT, '-usepretex=' + pretex, 'test.tex']
    run = subprocess.run(cmd, cwd=ROOT, **({} if a.full else dict(capture_output=True, text=True, encoding='utf-8',
                                                                   errors='replace')))
    log = os.path.join(OUT, job + '.log')
    pdf = os.path.join(OUT, job + '.pdf')
    if run.returncode:
        print('Build failed (code %d). Log: %s' % (run.returncode, os.path.relpath(log, ROOT)))
        if os.path.isfile(log):                               # the first error with a few lines of context
            with open(log, encoding='utf-8', errors='replace') as f: lines = f.read().splitlines()
            i = next((k for k, l in enumerate(lines) if re.match(r'^(!|.*:\d+: )', l)), None)
            if i is not None: print('\n'.join(lines[i:i + 12]))
        return run.returncode
    print('PDF: %s' % os.path.relpath(pdf, ROOT))

    found = boxes(log)
    bad = [b for b in found if b[0].startswith('Overfull')]
    print('Overfull boxes: %d, underfull: %d' % (len(bad), len(found) - len(bad)))
    for kind, amount, lines in found: print('  %-16s %-28s %s' % (kind, amount, lines and 'lines ' + lines))

    if a.png:
        pngdir = os.path.join(OUT, job)
        os.makedirs(pngdir, exist_ok=True)
        for old in glob.glob(os.path.join(pngdir, 'page-*.png')): os.remove(old)
        subprocess.run(['pdftoppm', '-r', '110', '-png', pdf, os.path.join(pngdir, 'page')], check=True)
        print('PNG: %s (%d pages)' % (os.path.relpath(pngdir, ROOT), len(glob.glob(os.path.join(pngdir, '*.png')))))
    return 0


if __name__ == '__main__':
    sys.exit(main())
