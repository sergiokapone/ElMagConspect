#!/usr/bin/env python3
"""Builds one chapter (or one TikZ picture) of the book with the book class, through test.tex.

  python chapter.py Charges                 _chapters/Charges.pdf
  python chapter.py Charges --png           also _chapters/Charges/page-NN.png (to look at the layout)
  python chapter.py Charges --tikz Columb   only the picture Charges/tikz/Columb.tikz -> _chapters/Charges-Columb.pdf

test.tex takes the chapter from \\TargetChapter (and the picture from \\TargetTikz); they are passed with
latexmk -usepretex. References to other chapters stay '??': the chapter is built alone.
After the build the overfull/underfull boxes of the log are listed with their source lines."""
import argparse, glob, os, queue, re, subprocess, sys, threading, time

ROOT = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(ROOT, '_chapters')

# Список папок-винятків, які не є розділами книги
EXCLUDED_DIRS = {
    '_chapters',
    '.git',
    '.github',
    '__pycache__',
    '.idea',
    '.vscode',
    'venv',
    'env',
    'build',
    ".archive",
    ".claude",
    "_html",
    "docs",
    "Documents",
    "Bibliography",
    "Tensions",
    "Plasma"
}


def get_available_chapters():
    """Знаходить усі папки розділів, перевіряючи наявність <folder>/<folder>.tex."""
    chapters = []
    if not os.path.exists(ROOT):
        return chapters
    for name in sorted(os.listdir(ROOT)):
        path = os.path.join(ROOT, name)
        if os.path.isdir(path) and name not in EXCLUDED_DIRS:
            tex_file = os.path.join(path, f"{name}.tex")
            if os.path.isfile(tex_file):
                chapters.append(name)
    return chapters


def boxes(log):
    """Overfull/underfull box warnings of a LaTeX log: [(kind, amount, 'file:lines')]."""
    with open(log, encoding='utf-8', errors='replace') as f: text = f.read()
    found = []
    for m in re.finditer(r'(Overfull|Underfull) \\([hv])box \(([^)]*)\)([^\n]*)', text):
        at = re.search(r'lines? (\d+(?:--\d+)?)', m.group(4))
        found.append((m.group(1) + ' \\' + m.group(2) + 'box', m.group(3), at.group(1) if at else ''))
    return found


def run_with_progress(cmd, cwd, env, label="Building", is_full=False):
    """Запускає команду із виводом спінера та поточного стану компіляції."""
    if is_full:
        return subprocess.run(cmd, cwd=cwd, env=env)

    proc = subprocess.Popen(
        cmd, cwd=cwd, env=env,
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
        text=True, encoding='utf-8', errors='replace', bufsize=1
    )

    q = queue.Queue()

    def enqueue_output(out, q):
        while True:
            char = out.read(1)
            if not char:
                break
            q.put(char)
        out.close()

    t = threading.Thread(target=enqueue_output, args=(proc.stdout, q))
    t.daemon = True
    t.start()

    # Спінер з автоперевіркою підтримки юнікоду в консолі
    try:
        sys.stdout.write('⠋')
        sys.stdout.flush()
        sys.stdout.write('\r \r')
        frames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏']
    except Exception:
        frames = ['|', '/', '-', '\\']

    idx = 0
    buffer = ""
    current_page = None

    while proc.poll() is None or not q.empty():
        while not q.empty():
            c = q.get_nowait()
            buffer += c
            # Шукаємо відкомпільовані сторінки у виводі LaTeX (наприклад [1], [2])
            pages = re.findall(r'\[(\d+)\]', buffer)
            if pages:
                current_page = pages[-1]
            if len(buffer) > 2000:
                buffer = buffer[-1000:]

        page_info = f" (page {current_page})" if current_page else ""
        spinner = frames[idx % len(frames)]
        msg = f"\r{spinner} {label}{page_info}..."
        sys.stdout.write(msg.ljust(60))
        sys.stdout.flush()

        idx += 1
        time.sleep(0.08)

    # Очищаємо рядок після завершення
    sys.stdout.write('\r' + ' ' * 60 + '\r')
    sys.stdout.flush()

    return proc


def main():
    available_chapters = get_available_chapters()
    chapters_str = ", ".join(available_chapters) if available_chapters else "none"

    ap = argparse.ArgumentParser(description='Build one chapter of the book with the book class (test.tex).')
    ap.add_argument('chapter', help=f'chapter folder (available: {chapters_str})')
    ap.add_argument('--tikz', help='build only this picture of <chapter>/tikz/ (name without .tikz)')
    ap.add_argument('--png', action='store_true', help='render the pages to PNG (pdftoppm, 110 dpi)')
    ap.add_argument('--full', action='store_true', help='whole latexmk output')
    a = ap.parse_args()

    src = os.path.join(ROOT, a.chapter, a.chapter + '.tex')
    if not os.path.isfile(src):
        print('No %s' % os.path.relpath(src, ROOT))
        if available_chapters:
            print('Available chapters: %s' % chapters_str)
        return 1

    pretex = r'\def\TargetChapter{%s}' % a.chapter
    job = a.chapter
    if not a.tikz:                              # the chapter cites something: print its literature after the text
        with open(src, encoding='utf-8', errors='replace') as f:
            if re.search(r'\\(?:no)?cite', re.sub(r'(?m)(?<!\\)%.*$', '', f.read())): pretex += r'\def\TargetBib{}'
    if a.tikz:
        pretex += r'\def\TargetTikz{%s}' % a.tikz
        job += '-' + a.tikz
    os.makedirs(os.path.join(OUT, a.chapter), exist_ok=True)   # the chapter writes its answers there
    if a.tikz:                                  # a picture has no index entries, and upmendex fails on an empty .idx
        index = '$makeindex = q(perl -e "open F, q(>), $ARGV[0]" %D)'
    else:                                       # latexmk runs the indexer inside -outdir: the style needs its full path
        index = '$makeindex = q(upmendex -s "%s" %%O -o %%D %%S)' % os.path.join(ROOT, 'index-uk.ist').replace('\\', '/')
    # gnuplot plots of TikZ (--shell-escape, as in run.ps1): lualatex writes their files into -outdir, but runs
    # gnuplot in the project root, so the call changes into -outdir first; the table is read back via TEXINPUTS
    pretex += r'\AtBeginDocument{\pgfkeys{/pgf/plot/gnuplot call={cd %s && gnuplot}}}' % os.path.basename(OUT)
    # %P = the pre-TeX code of -pretex followed by the source (-usepretex would reset the command to plain lualatex)
    lualatex = 'lualatex --shell-escape -interaction=nonstopmode -halt-on-error -file-line-error %O %P'
    cmd = ['latexmk', '-pdflua', '-pretex=' + pretex, '-lualatex=' + lualatex, '-e', index,
           '-jobname=' + job, '-outdir=' + OUT, 'test.tex']
    env = {**os.environ, 'TEXINPUTS': OUT + os.pathsep + os.environ.get('TEXINPUTS', '')}

    run = run_with_progress(cmd, cwd=ROOT, env=env, label=f"Building {job}", is_full=a.full)

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
        run_with_progress(['pdftoppm', '-r', '110', '-png', pdf, os.path.join(pngdir, 'page')],
                          cwd=ROOT, env=env, label="Rendering PNGs", is_full=a.full)
        print('PNG: %s (%d pages)' % (os.path.relpath(pngdir, ROOT), len(glob.glob(os.path.join(pngdir, '*.png')))))
    return 0


if __name__ == '__main__':
    sys.exit(main())
