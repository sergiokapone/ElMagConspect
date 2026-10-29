"""Lossless-looking compression of the SVG pictures of the HTML site (pdftocairo/dvisvgm output).

What it does (the picture stays the same to within 0.01 pt):
  * numbers in path data are rounded to PREC decimals; paths made only of M/L/Z/H/V (absolute) are
    written with relative coordinates, which are computed from the ROUNDED absolute points, so errors do not add up;
  * numbers in the other commands (C, S, Q, A ...) are only rounded;
  * gradient stops: offset to 4 decimals, rgb percents to 1 decimal.
Usage: python svg_optimize.py FILE_OR_DIR [...]    (files are overwritten, only when the result is smaller)
       python svg_optimize.py --out DIR FILE ...   (write the results to DIR, originals untouched)
"""
import os
import re
import sys

PREC = 2
NUM = re.compile(r'[-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?')
TOK = re.compile(r'[A-Za-z]|' + NUM.pattern)


def fmt(x, prec=PREC):
    s = ('%.*f' % (prec, x)).rstrip('0').rstrip('.')
    if s in ('-0', ''): return '0'
    if s.startswith('0.'): s = s[1:]
    elif s.startswith('-0.'): s = '-' + s[2:]
    return s


def join(nums):
    """numbers separated by a space only where it is needed"""
    out = ''
    for n in nums:
        if out and not (n.startswith('-') or (n.startswith('.') and '.' in out.rsplit(' ', 1)[-1].lstrip('-'))):
            out += ' '
        out += n
    return out


def simple_path(toks):
    return all(t in 'MLZHVz' or not t.isalpha() for t in toks)


def path_data(d):
    toks = TOK.findall(d)
    if not toks: return d
    if not simple_path(toks):
        return ' '.join(re.sub(NUM, lambda m: fmt(float(m.group(0))), d).split())
    # M/L/Z/H/V with absolute coordinates -> relative, computed from rounded points
    out, i, cx, cy, sx, sy, cmd = [], 0, 0.0, 0.0, 0.0, 0.0, None
    r = lambda v: round(v, PREC)
    while i < len(toks):
        t = toks[i]
        if t.isalpha(): cmd = t; i += 1
        if cmd in 'Zz':
            out.append('z'); cx, cy = sx, sy; continue
        if cmd in 'MLHV':
            if cmd in 'HV':
                v = r(float(toks[i])); i += 1
                x, y = (v, cy) if cmd == 'H' else (cx, v)
            else:
                x, y = r(float(toks[i])), r(float(toks[i + 1])); i += 2
            first = cmd == 'M'
            if first:
                out.append('M' + join([fmt(x), fmt(y)])); sx, sy = x, y; cmd = 'L'
            else:
                out.append('l' + join([fmt(x - cx), fmt(y - cy)]))
            cx, cy = x, y
        else:
            return d    # relative or unknown commands: leave as it is
    s = ''.join(out)
    return re.sub(r'(?<=[a-zA-Z])\s+', '', s)


def stop_attrs(m):
    s = m.group(0)
    s = re.sub(r'offset="([^"]+)"', lambda k: 'offset="%s"' % fmt(float(k.group(1)), 4), s)
    s = re.sub(r'(\d+\.\d+)%', lambda k: fmt(float(k.group(1)), 1) + '%', s)
    return s


def optimize(text):
    text = re.sub(r'\bd="([^"]*)"', lambda m: 'd="%s"' % path_data(m.group(1)), text)
    text = re.sub(r'<stop [^>]*/>', stop_attrs, text)
    return text


def process(src, dst):
    with open(src, encoding='utf-8') as f: text = f.read()
    new = optimize(text)
    if len(new) < len(text) or dst != src:
        with open(dst, 'w', encoding='utf-8', newline='\n') as f: f.write(new if len(new) < len(text) else text)
    return len(text.encode('utf-8')), len(new.encode('utf-8'))


def files(paths):
    for p in paths:
        if os.path.isdir(p):
            for dp, _, fs in os.walk(p):
                for n in fs:
                    if n.lower().endswith('.svg'): yield os.path.join(dp, n)
        elif os.path.isfile(p): yield p


def main(argv):
    out = None
    if argv[:1] == ['--out']: out, argv = argv[1], argv[2:]
    if out: os.makedirs(out, exist_ok=True)
    before = after = 0
    for f in files(argv):
        dst = os.path.join(out, os.path.basename(f)) if out else f
        a, b = process(f, dst)
        before += a; after += min(a, b)
        if a - b > 100 * 1024: print('  %s: %.1f -> %.1f MB' % (f, a / 1048576, b / 1048576))
    print('SVG: %.1f MB -> %.1f MB' % (before / 1048576, after / 1048576))


if __name__ == '__main__':
    main(sys.argv[1:])
