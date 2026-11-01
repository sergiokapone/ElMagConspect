"""Generates SteadyCurrent/tikz/SurfChargesA.tikz and SurfChargesB.tikz: a battery and a U-shaped wire
(A: the wire is isolated, B: the wire touches the terminals and carries a current).

Model: thin conductors in the plane of the figure, 3D Coulomb kernel, method of moments.
  A: terminals at potentials +-V0, the wire is neutral and floating.
  B: terminals at +-V0, the potential along the wire drops linearly from +V0 to -V0 (uniform ohmic wire).
Field lines are traced with equal flux per line; charges are drawn as markers at equal charge steps.
Usage: python surfcharges_fig.py
"""
import os
import numpy as np

ROOT = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(ROOT, 'SteadyCurrent', 'tikz')

DS = 0.06            # segment length, cm
A_SELF = 0.015       # wire radius for the self term
A_FIELD = 0.045      # softening in the field kernel
Y_T = 1.5            # terminals at y = +-Y_T
STUB = 0.6           # terminal stub length
WIRE_X0 = 1.15      # where the wire starts in A (in B it starts at STUB)
BEND_X = 3.7         # centre of the semicircle
R_BEND = Y_T
BOX = (-3.4, 6.4, -3.6, 3.6)   # xmin, xmax, ymin, ymax of the picture
BODY = (-2.8, 0.0, -2.1, 2.1)  # battery body (lines are cut inside)
LENS_SPACE = 4.0     # extra room to the right of the picture for the loupe
V0 = 1.0
HALF_W = 0.12        # half of the drawn wire width


def path_points(pts_a, ds):
    """Polyline -> points with step ~ds, returns (points, tangents)."""
    P, T = [], []
    for (x0, y0), (x1, y1) in zip(pts_a[:-1], pts_a[1:]):
        L = np.hypot(x1 - x0, y1 - y0)
        n = max(1, int(round(L / ds)))
        for k in range(n):
            u = (k + 0.5) / n
            P.append((x0 + u * (x1 - x0), y0 + u * (y1 - y0)))
            T.append(((x1 - x0) / L, (y1 - y0) / L))
    return np.array(P), np.array(T)


def wire_path(x_start):
    """Upper straight part, semicircle, lower straight part (from + side to - side)."""
    pts = [(x_start, Y_T), (BEND_X, Y_T)]
    for ang in np.linspace(90, -90, 61)[1:]:
        pts.append((BEND_X + R_BEND * np.cos(np.radians(ang)), R_BEND * np.sin(np.radians(ang))))
    pts.append((x_start, -Y_T))
    return pts


def build(contact):
    x_start = STUB if contact else WIRE_X0
    top, tt = path_points([(0, Y_T), (STUB, Y_T)], DS)
    bot, tb = path_points([(0, -Y_T), (STUB, -Y_T)], DS)
    w, tw = path_points(wire_path(x_start), DS)
    P = np.vstack([top, bot, w])
    T = np.vstack([tt, tb, tw])
    kind = np.array([0] * len(top) + [1] * len(bot) + [2] * len(w))   # 0: + stub, 1: - stub, 2: wire
    N = len(P)
    d2 = ((P[:, None, :] - P[None, :, :]) ** 2).sum(-1)
    M = 1.0 / np.sqrt(d2 + A_SELF ** 2)
    M[np.diag_indices(N)] = 2 * np.log(DS / A_SELF) / DS
    if contact:
        s = np.concatenate([[0], np.cumsum(np.hypot(*np.diff(w, axis=0).T))])
        phi = np.where(kind == 0, V0, np.where(kind == 1, -V0, 0.0))
        phi[kind == 2] = V0 * (1 - 2 * s / s[-1])
        q = np.linalg.solve(M, phi)
    else:
        # unknowns: charges and the floating potential of the wire; total wire charge = 0
        phi = np.where(kind == 0, V0, np.where(kind == 1, -V0, 0.0))
        w_idx = kind == 2
        A = np.zeros((N + 1, N + 1))
        A[:N, :N] = M
        A[:N, N] = np.where(w_idx, -1.0, 0.0)
        A[N, :N] = np.where(w_idx, 1.0, 0.0)
        rhs = np.concatenate([phi, [0.0]])
        q = np.linalg.solve(A, rhs)[:N]
    return P, T, kind, q


def field(P, q, pts):
    r = pts[:, None, :] - P[None, :, :]
    d = (r ** 2).sum(-1) + A_FIELD ** 2
    return (q[None, :, None] * r / d[..., None] ** 1.5).sum(1)


def in_body(p):
    return BODY[0] < p[0] < BODY[1] and BODY[2] < p[1] < BODY[3]


def trace(P, q, start, sign, stop_pos, stop_neg, h=0.06, nmax=3000):
    """Follows sign*E from start; stops at box edge, at the battery body or at a charged segment of the opposite kind."""
    pts = [np.array(start)]
    p = np.array(start)
    hit = None
    for k in range(nmax):
        def f(x):
            e = field(P, q, x[None, :])[0]
            return sign * e / (np.linalg.norm(e) + 1e-12)
        k1 = f(p)
        k2 = f(p + 0.5 * h * k1)
        p = p + h * k2
        if not (BOX[0] < p[0] < BOX[1] and BOX[2] < p[1] < BOX[3]) or in_body(p):
            break
        pts.append(p.copy())
        dist = np.hypot(*(P - p).T)
        near = dist < HALF_W + 0.02
        if k > 3 and near.any():
            if (stop_neg & near).any() and sign > 0 or (stop_pos & near).any() and sign < 0:
                hit = 'end'
                break
            if (stop_pos & near).any() and sign > 0 or (stop_neg & near).any() and sign < 0:
                hit = 'bad'
                break
    return np.array(pts), hit


def seeds(P, T, q, n_lines, positive):
    """Positions on the surface of charged segments, equal charge between neighbours."""
    qq = np.where(positive, np.maximum(q, 0), np.maximum(-q, 0))
    cum = np.cumsum(qq)
    tot = cum[-1]
    out = []
    side = 1
    for j in range(n_lines):
        target = (j + 0.5) / n_lines * tot
        i = int(np.searchsorted(cum, target))
        n = np.array([-T[i, 1], T[i, 0]])
        out.append(P[i] + side * (HALF_W + 0.01) * n)
        side = -side
    return out


def markers(P, T, q, kind, step, positive, which, offset=0.24):
    """Marker positions: one per `step` of accumulated charge, alternately on both sides of the wire."""
    out = []
    acc = 0.0
    side = 1
    for i in range(len(P)):
        if (q[i] > 0) != positive or kind[i] not in which:
            continue
        acc += abs(q[i])
        while acc >= step:
            acc -= step
            n = np.array([-T[i, 1], T[i, 0]])
            out.append(P[i] + side * offset * n)
            side = -side
    return out


def fmt(p):
    return '(%.2f,%.2f)' % (p[0], p[1])


def thin(pts, ds=0.12):
    out = [pts[0]]
    for p in pts[1:]:
        if np.hypot(*(p - out[-1])) >= ds:
            out.append(p)
    if np.hypot(*(pts[-1] - out[-1])) > ds / 2:
        out.append(pts[-1])
    elif len(out) > 1:
        out[-1] = pts[-1]
    return out


def draw_wire_tikz(contact):
    x_start = STUB if contact else WIRE_X0
    pts = ' -- '.join(fmt(p) for p in wire_path(x_start))
    return (
        '    \\draw[gray!70, line width=%.2fcm, line cap=round, line join=round] %s;\n'
        '    \\draw[gray!25, line width=%.2fcm, line cap=round, line join=round] %s;\n'
        '    \\draw[white, line width=%.2fcm, line cap=round, line join=round, opacity=0.8] %s;\n'
        % (2 * HALF_W, pts, 1.3 * HALF_W, pts, 0.4 * HALF_W, pts))


def make(contact):
    P, T, kind, q = build(contact)
    qmax = np.abs(q).max()
    stop_pos = q > 0.05 * np.abs(q[kind == 2]).max()
    stop_neg = q < -0.05 * np.abs(q[kind == 2]).max()
    lines = []
    # lines from positive charges forward
    n_pos = 22
    for s in seeds(P, T, q, n_pos, True):
        pts, hit = trace(P, q, s, +1, stop_pos, stop_neg)
        if len(pts) > 3 and hit != 'bad':
            lines.append(pts)
    # lines that come from infinity to negative charges: traced backwards, those that reach the positive ones are duplicates
    for s in seeds(P, T, q, n_pos, False):
        pts, hit = trace(P, q, s, -1, stop_pos, stop_neg)
        if len(pts) > 3 and hit is None:
            lines.append(pts[::-1])
    # markers
    wsum = np.abs(q[kind == 2]).sum()
    ssum = np.abs(q[kind == 0]).sum()
    mk_p = markers(P, T, q, kind, wsum / 22.0, True, (2,))
    mk_n = markers(P, T, q, kind, wsum / 22.0, False, (2,))

    s = []
    # the picture is turned by -90 degrees (battery on top): the clip is given in page coordinates (X, Y) = (y, -x);
    # the circuitikz symbol is drawn outside the rotated scope, it does not survive a rotation
    s.append('\\begin{tikzpicture}[>=Stealth, font=\\sffamily\\small,\n'
             '        spy using outlines={circle, magnification=4, size=3.6cm, connect spies}]\n')
    # panel B has extra room on the right for the loupe: its width in the figure must be larger in proportion
    s.append('    \\useasboundingbox (%.2f,%.2f) rectangle (%.2f,%.2f);\n' % (BOX[2], -BOX[1], BOX[3] + (LENS_SPACE if contact else 0), -BOX[0]))
    s.append('    \\begin{scope}\n')
    s.append('    \\clip (%.2f,%.2f) rectangle (%.2f,%.2f);\n' % (BOX[2], -BOX[1], BOX[3], -BOX[0]))
    s.append('    \\begin{scope}[rotate=-90]\n')
    # field lines
    for pts in lines:
        c = thin(pts)
        if len(c) < 3 or np.hypot(*(pts[-1] - pts[0])) < 0.8:
            continue
        s.append('    \\draw[line width=0.5pt, black!75, midarrow] %s;\n'
                 % ' -- '.join(fmt(p) for p in c))
    s.append('    \\end{scope}\n    \\end{scope}\n    \\begin{scope}[rotate=-90]\n')
    # battery body
    x0, x1, y0, y1 = BODY
    s.append('    \\shade[left color=blue!30!black!30, right color=blue!5!black!8, draw=gray!70, line width=0.5pt, rounded corners=3pt]'
             ' (%.2f,%.2f) rectangle (%.2f,%.2f);\n' % (x0, y0, x1, y1))
    s.append('    \\end{scope}\n')
    # cell symbol from circuitikz, page coordinates: terminals at (+-Y_T, 0), the cell in the middle of the body
    yc = -((x0 + x1) / 2 - 0.2)
    s.append('    \\draw[black!80, line width=0.6pt] (%.2f,0) -- (%.2f,%.2f) to[battery2] (%.2f,%.2f) -- (%.2f,0);\n'
             % (Y_T, Y_T, yc, -Y_T, yc, -Y_T))
    s.append('    \\begin{scope}[rotate=-90]\n')
    s.append('    \\node[red!70!black, font=\\bfseries\\large] at (-0.35, %.2f) {$+$};\n' % Y_T)
    s.append('    \\node[blue!70!black, font=\\bfseries\\large] at (-0.35, %.2f) {$-$};\n' % -Y_T)
    # terminals and wire
    for y in (Y_T, -Y_T):
        s.append('    \\draw[gray!70, line width=%.2fcm, line cap=round] (0,%.2f) -- (%.2f,%.2f);\n'
                 % (2 * HALF_W, y, STUB, y))
        s.append('    \\draw[white, line width=%.2fcm, opacity=0.8] (0,%.2f) -- (%.2f,%.2f);\n'
                 % (0.5 * HALF_W, y, STUB, y))
    s.append(draw_wire_tikz(contact))
    # charges
    spot = np.array([3.3, Y_T + HALF_W])       # where the loupe looks: keep it free of markers
    for p in mk_p:
        if not contact or np.hypot(*(p - spot)) > 0.6:
            s.append('    \\node[red!80!black, font=\\bfseries\\scriptsize, inner sep=0] at %s {$+$};\n' % fmt(p))
    for p in mk_n:
        if not contact or np.hypot(*(p - spot)) > 0.6:
            s.append('    \\node[blue!80!black, font=\\bfseries\\scriptsize, inner sep=0] at %s {$-$};\n' % fmt(p))
    # components of E at the surface of the upper wire (only for the wire with current)
    if contact:
        x = 3.3
        base = np.array([x, Y_T + HALF_W])
        e = field(P, q, (base + np.array([0, 0.12]))[None, :])[0]
        sc = 0.45 / np.hypot(*e)      # small arrows: the loupe magnifies them
        et, en = e[0] * sc, e[1] * sc
        s.append('    \\begin{scope}[red!80!black, thin, {>={Latex[scale=0.4]}}, ->]\n')
        s.append('        \\draw (%.2f,%.2f) -- ++(%.2f,0) coordinate (Et);\n' % (base[0], base[1], et))
        s.append('        \\draw (%.2f,%.2f) -- ++(0,%.2f) coordinate (En);\n' % (base[0], base[1], en))
        s.append('        \\draw (%.2f,%.2f) -- ++(%.2f,%.2f) coordinate (E);\n' % (base[0], base[1], et, en))
        s.append('    \\end{scope}\n')
        s.append('    \\draw[dashed, very thin, red!80!black] (Et) -- (E) -- (En);\n')
        s.append('    \\node[below, red!80!black, inner sep=0.5pt, font=\\fontsize{2.4pt}{2.8pt}\\selectfont] at (Et) {$\\Efield_\\tau$};\n')
        s.append('    \\node[above, red!80!black, inner sep=0.5pt, font=\\fontsize{2.4pt}{2.8pt}\\selectfont] at ($(%.2f,%.2f)!0.5!(En)$) {$\\Efield_n$};\n'
                 % (base[0], base[1]))
        s.append('    \\node[right, red!80!black, inner sep=0.5pt, font=\\fontsize{2.4pt}{2.8pt}\\selectfont] at (E) {$\\Efield$};\n')
    s.append('    \\end{scope}\n')
    if contact:
        # the loupe in page coordinates (X, Y) = (y, -x)
        s.append('    \\spy[gray, line width=0.6pt] on (%.2f,%.2f) in node[fill=white] at (%.2f,%.2f);\n'
                 % (base[1] + 0.5 * en, -base[0] - 0.5 * et, BOX[3] + LENS_SPACE / 2, -base[0]))
    s.append('\\end{tikzpicture}\n')
    return ''.join(s), len(lines), len(mk_p), len(mk_n)


def main():
    for name, contact in (('SurfChargesA', False), ('SurfChargesB', True)):
        text, nl, npm, nnm = make(contact)
        path = os.path.join(OUT, name + '.tikz')
        with open(path, 'w', encoding='utf-8', newline='\n') as fh:
            fh.write(text)
        print('%s: %d lines, %d plus, %d minus, %d bytes' % (name, nl, npm, nnm, len(text)))


if __name__ == '__main__':
    main()
