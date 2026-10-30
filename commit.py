#!/usr/bin/env python3
"""Interactive commit: shows changed files in two groups (sources, generated docs/), suggests a message
for each, asks for confirmation, then offers to push.

  python commit.py            sources first, docs/ as a separate commit
  python commit.py --no-push  do not ask about push

At the prompt: Enter = take the suggestion, text = your own message, '-' = skip the group, 'q' = quit."""
import os, re, subprocess, sys
from collections import Counter

ROOT = os.path.dirname(os.path.abspath(__file__))
sys.stdout.reconfigure(encoding='utf-8')


def git(*args, check=True):
    r = subprocess.run(['git', '-c', 'core.quotepath=off', *args], cwd=ROOT, capture_output=True,
                       text=True, encoding='utf-8', errors='replace')
    if check and r.returncode: sys.exit(r.stderr.strip() or 'git failed')
    return r.stdout


def changed():
    """[(status, path)] of all changed and untracked files."""
    toks = git('status', '--porcelain=v1', '-z', '-uall').split('\0')
    out, i = [], 0
    while i < len(toks) and toks[i]:
        st, path = toks[i][:2].strip(), toks[i][3:]
        if toks[i][0] in 'RC': i += 1  # the next token is the old name
        out.append((st or '?', path))
        i += 1
    return out


def numstat(paths):
    add = rem = 0
    for l in git('diff', 'HEAD', '--numstat', '--', *paths, check=False).splitlines():
        a, r, _ = l.split('\t', 2)
        if a.isdigit(): add += int(a); rem += int(r)
    return add, rem


def sections(paths):
    """Titles of the sections near the changed hunks of .tex files (from the hunk headers)."""
    found = []
    for l in git('diff', 'HEAD', '-U0', '--', *[p for p in paths if p.endswith('.tex')], check=False).splitlines():
        m = re.match(r'@@ .*? @@ \\(?:sub)*section\*?\{(.*)\}', l)
        if m and m.group(1) not in found: found.append(m.group(1))
    return found


def suggest_sources(files):
    folders = Counter(p.split('/')[0] if '/' in p else '' for _, p in files)
    names = [f for f in folders if f]
    head = ', '.join(names[:3]) + (' и др.' if len(names) > 3 else '') if names else 'корінь'
    add, rem = numstat([p for _, p in files])
    secs = sections([p for _, p in files])
    msg = '%s: правки (+%d/−%d)' % (head, add, rem)
    if secs: msg = '%s: %s' % (head, '; '.join(secs[:3]))
    return msg


def suggest_docs(files):
    exts = {os.path.splitext(p)[1] for _, p in files}
    what = [n for e, n in (('.pdf', 'PDF'), ('.html', 'HTML')) if e in exts]
    return 'docs: перебудова ' + ' та '.join(what or ['сайту'])


def show(title, files, limit=25):
    print('\n== %s: %d файлів ==' % (title, len(files)))
    for st, p in files[:limit]: print('  %-2s %s' % (st, p))
    if len(files) > limit:
        c = Counter(os.path.splitext(p)[1] or '(без розширення)' for _, p in files[limit:])
        print('  ... ще %d: %s' % (len(files) - limit, ', '.join('%s×%d' % kv for kv in c.most_common())))


def commit_group(title, files, suggestion):
    show(title, files)
    print('Пропозиція: %s' % suggestion)
    ans = input('Коментар [Enter=так, текст=свій, -=пропустити, q=вихід]: ').strip()
    if ans == 'q': sys.exit(0)
    if ans == '-': return False
    git('add', '-A', '--', *[p for _, p in files])
    git('commit', '-q', '-m', ans or suggestion)
    print('Закомічено.')
    return True


def main():
    files = changed()
    if not files: print('Нема змін.'); return
    docs = [f for f in files if f[1].startswith('docs/')]
    src = [f for f in files if not f[1].startswith('docs/')]
    done = False
    if src: done |= commit_group('Джерела', src, suggest_sources(src))
    if docs: done |= commit_group('docs/ (згенероване)', docs, suggest_docs(docs))
    ahead = git('rev-list', '--count', '@{u}..HEAD', check=False).strip()
    if '--no-push' not in sys.argv and ahead not in ('', '0'):
        if input('Не запушено комітів: %s. Push? [Y/n] ' % ahead).strip().lower() in ('', 'y', 'так'):
            r = subprocess.run(['git', 'push'], cwd=ROOT)
            print('Push OK.' if r.returncode == 0 else 'Push не вдався.')


if __name__ == '__main__':
    try: main()
    except (KeyboardInterrupt, EOFError): print('\nПерервано.')
