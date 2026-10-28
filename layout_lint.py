#!/usr/bin/env python3
"""Layout linter for the book PDF: shows sparse pages, widows, orphans and tiny box fragments.

  python layout_lint.py                      docs/ElMagConspect.pdf (or main.pdf if there is no docs/ one)
  python layout_lint.py _chapters/MagEnergy.pdf
  python layout_lint.py --chapter Хвилеводи  only the pages of one chapter (substring of its title in the contents)
  python layout_lint.py --sheet              also save contact sheets of the flagged pages to _lint/

What is reported (page numbers are PDF pages, 1-based):
  gap-bottom   the content ends far above the bottom of the text area (an unbreakable box or a float did not fit);
               not reported before a chapter/part start, where this is normal
  gap-inside   a big empty band between two pieces of content in the middle of a page
  heading-bottom
               a heading is the last thing on a page, its text/problems start on the next one
  widow        the last line of a paragraph alone at the top of a page
  orphan       the first line of a paragraph alone at the bottom of a page
  box-top / box-bottom
               a tcolorbox that is split with only a few lines on one page (a "sliver")
Lines inside boxes are not checked for widows (their margins differ); only the box slivers are.
Thresholds are in pt (1 pt = 0.353 mm); change them with the options below. Exit code 1 if anything is found."""
import argparse, collections, os, sys
import fitz  # PyMuPDF

ROOT = os.path.dirname(os.path.abspath(__file__))
TERMINAL = '.!?:;»”)…'


def lines_of(page, header_bottom, footer_top):
    """Text lines of the body (no running head, no page number): dicts with text, bbox and font size."""
    out = []
    for b in page.get_text('dict')['blocks']:
        if b['type'] != 0: continue
        for l in b['lines']:
            text = ''.join(s['text'] for s in l['spans']).strip()
            if not text: continue
            x0, y0, x1, y1 = l['bbox']
            if y1 < header_bottom or y0 > footer_top: continue
            size = max((s['size'] for s in l['spans']), default=0)
            bold = all(s['flags'] & 16 or 'Bold' in s['font'] for s in l['spans'] if s['text'].strip())
            out.append(dict(text=text, x0=x0, y0=y0, x1=x1, y1=y1, size=size, bold=bold))
    out.sort(key=lambda l: (round(l['y0']), l['x0']))
    return out


def content_boxes(page, lines, header_bottom, footer_top):
    """Bounding boxes of everything visible in the body: text lines, images, vector drawings."""
    boxes = [(l['y0'], l['y1']) for l in lines]
    for im in page.get_image_info():
        r = fitz.Rect(im['bbox'])
        if r.y1 > header_bottom and r.y0 < footer_top: boxes.append((r.y0, r.y1))
    W, H = page.rect.width, page.rect.height
    for d in page.get_drawings():
        r = d['rect']
        if r.y1 < header_bottom + 1 or r.y0 > footer_top - 1: continue          # running head rule, page number
        if r.width > 0.95 * W and r.height > 0.9 * H: continue                  # page background
        boxes.append((max(r.y0, header_bottom), min(r.y1, footer_top)))
    return boxes


def merge(boxes):
    boxes = sorted(boxes)
    merged = []
    for y0, y1 in boxes:
        if merged and y0 <= merged[-1][1] + 0.5: merged[-1][1] = max(merged[-1][1], y1)
        else: merged.append([y0, y1])
    return merged


def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    ap.add_argument('pdf', nargs='?')
    ap.add_argument('--chapter', help='only the chapter whose title contains this text')
    # "Noticeable" = about 1/8 of the text height (~720 pt) or more: a gap of this size is seen at a glance. Smaller gaps are the
    # normal price of unbreakable problems and floats and are not reported (see STATUS.md, 28.10.2026).
    ap.add_argument('--min-gap', type=float, default=90, help='bottom gap, pt (default 90 = 32 mm)')
    ap.add_argument('--max-inside', type=float, default=80, help='gap inside a page, pt (default 80 = 28 mm)')
    ap.add_argument('--sliver', type=int, default=1, help='a split box with at most this many lines is a sliver (default 1)')
    ap.add_argument('--sheet', action='store_true', help='save contact sheets of flagged pages to _lint/')
    ap.add_argument('--all', action='store_true', help='also list the bottom gaps before a chapter start')
    a = ap.parse_args()
    sys.stdout.reconfigure(encoding='utf-8')

    pdf = a.pdf or next((p for p in (os.path.join(ROOT, 'docs', 'ElMagConspect.pdf'), os.path.join(ROOT, 'main.pdf'))
                         if os.path.isfile(p)), None)
    if not pdf or not os.path.isfile(pdf): print('No PDF: build it first (python elmag.py pdf).'); return 2
    doc = fitz.open(pdf)
    H = doc[0].rect.height
    header_bottom, footer_top = 0.0594 * H, 0.944 * H

    # chapters and sections from the bookmarks: level 1 = part, 2 = chapter, 3 = section
    toc = doc.get_toc()
    starts = sorted({p for lvl, _, p in toc if lvl <= 2})                    # pages where a chapter/part starts
    chapters = [(p, t) for lvl, t, p in toc if lvl == 2]
    sections = [(p, t) for lvl, t, p in toc if lvl == 3]
    first_body = chapters[0][0] if chapters else 1
    # the answers section is generated by the answers package: the chapters end where it starts
    end_body = next((p for lvl, t, p in toc if lvl == 1 and any(w in t.lower() for w in ('відповіді', 'додатки', 'літератур', 'покажчик'))),
                    len(doc) + 1)

    def where(pn):
        c = next((t for p, t in reversed(chapters) if p <= pn), '')
        s = next((t for p, t in reversed(sections) if p <= pn), '')
        return c, s

    # global calibration: body font size and the bottom of the text area
    sizes = collections.Counter()
    bottoms = []
    page_lines = {}
    for pn in range(first_body, min(end_body, len(doc) + 1)):
        page = doc[pn - 1]
        ls = lines_of(page, header_bottom, footer_top)
        page_lines[pn] = ls
        for l in ls: sizes[round(l['size'], 1)] += 1
        if ls: bottoms.append(max(l['y1'] for l in ls))
    body_size = sizes.most_common(1)[0][0]
    bottoms.sort()
    body_bottom = bottoms[int(0.97 * (len(bottoms) - 1))]
    left = collections.Counter(round(l['x0']) for ls in page_lines.values() for l in ls if abs(l['size'] - body_size) < 0.3)
    margin = left.most_common(1)[0][0]
    print('%s: %d pages, body font %.1f pt, left margin %d pt, text area bottom %.0f pt' % (
        os.path.basename(pdf), len(doc), body_size, margin, body_bottom))

    def is_body(l): return abs(l['size'] - body_size) < 0.3

    found = collections.defaultdict(list)       # chapter -> [(page, kind, text)]
    flagged = []
    for pn in sorted(page_lines):
        ch, sec = where(pn)
        if a.chapter and a.chapter.lower() not in ch.lower(): continue
        page = doc[pn - 1]
        ls = page_lines[pn]
        if not ls: continue
        opening = any(l['size'] > 24 for l in ls)                                  # chapter / part title page: gaps by design
        boxes = content_boxes(page, ls, header_bottom, footer_top)
        merged = merge(boxes)
        items = []

        # sparse bottom
        gap = body_bottom - merged[-1][1]
        if gap > a.min_gap and not opening:
            before_start = (pn + 1) in starts or pn == len(doc) or pn + 1 >= end_body
            if a.all or not before_start:
                items.append(('gap-bottom', '%.0f pt (%.0f mm) empty at the bottom' % (gap, gap * 0.3528)))
        # sparse inside
        if not opening:
            inner = max(((b[0] - merged[i][1], merged[i][1]) for i, b in enumerate(merged[1:])), default=(0, 0))
            if inner[0] > a.max_inside:
                items.append(('gap-inside', '%.0f pt (%.0f mm) empty band at y=%.0f' % (inner[0], inner[0] * 0.3528, inner[1])))

        # a heading alone at the bottom of the page (a bold short line, nothing under it)
        tail = max(ls, key=lambda l: l['y1'])
        if tail['bold'] and 4 <= len(tail['text']) < 70 and sum(c.isalpha() for c in tail['text']) >= 4 \
                and tail['text'][-1] not in TERMINAL and tail['y1'] > body_bottom - 70 \
                and not opening and pn + 1 not in starts:
            items.append(('heading-bottom', '"%s"' % tail['text']))

        # widow: single last line of a paragraph at the top of the page
        first = ls[0]
        prev = page_lines.get(pn - 1)
        if prev and is_body(first) and abs(first['x0'] - margin) < 3 and first['y0'] < header_bottom + 45 and not opening:
            nxt = next((l for l in ls[1:] if l['y0'] > first['y1'] - 1), None)
            pl = next((l for l in reversed(prev) if is_body(l)), None)
            new_par_after = nxt is None or nxt['x0'] > margin + 6 or not is_body(nxt)
            if new_par_after and first['text'][-1] in TERMINAL and pl and pl['text'][-1] not in TERMINAL and pl['y1'] > body_bottom - 40:
                items.append(('widow', '"%s"' % first['text'][:70]))
        # orphan: first line of a paragraph alone at the bottom
        last = max(ls, key=lambda l: l['y1'])
        nxt_page = page_lines.get(pn + 1)
        if nxt_page and is_body(last) and margin + 8 < last['x0'] < margin + 40 and last['text'][-1] not in TERMINAL \
                and last['y1'] > body_bottom - 25 and pn + 1 not in starts:
            nf = nxt_page[0]
            if is_body(nf) and abs(nf['x0'] - margin) < 3:
                items.append(('orphan', '"%s"' % last['text'][:70]))

        # box slivers: a filled wide rectangle touching the top/bottom of the text area with a few lines inside
        for d in page.get_drawings():
            r = d['rect']
            if d.get('fill') is None or r.width < 250 or r.height < 6 or r.height > 0.5 * H: continue
            top = r.y0 < header_bottom + 14
            bottom = r.y1 > body_bottom - 14
            if not (top or bottom) or (top and bottom): continue
            n = sum(1 for l in ls if r.y0 - 1 <= l['y0'] and l['y1'] <= r.y1 + 1 and l['x0'] >= r.x0 - 1)
            if 0 < n <= a.sliver or (n == 0 and r.height < 20):
                items.append(('box-top' if top else 'box-bottom', 'a box piece of %d line(s), %.0f pt high' % (n, r.height)))
                break

        for kind, text in items: found[ch].append((pn, sec, kind, text))
        if items: flagged.append(pn)

    total = 0
    for ch, rows in found.items():
        print('\n%s' % (ch or '(outside the chapters)'))
        for pn, sec, kind, text in rows:
            print('  p.%-4d %-11s %s' % (pn, kind, text))
            total += 1
    kinds = collections.Counter(k for rows in found.values() for _, _, k, _ in rows)
    print('\nFound: %d (%s); pages: %d' % (total, ', '.join('%s %d' % kv for kv in sorted(kinds.items())) or 'none', len(set(flagged))))

    if a.sheet and flagged:
        from PIL import Image, ImageDraw
        out_dir = os.path.join(ROOT, '_lint'); os.makedirs(out_dir, exist_ok=True)
        pages = sorted(set(flagged))
        for k in range(0, len(pages), 8):
            ims = []
            for pn in pages[k:k + 8]:
                pm = doc[pn - 1].get_pixmap(dpi=40)
                im = Image.frombytes('RGB', (pm.width, pm.height), pm.samples)
                ImageDraw.Draw(im).text((4, 2), 'p.%d' % pn, fill=(200, 0, 0))
                ims.append(im)
            w, h = ims[0].size
            sheet = Image.new('RGB', (w * 4, h * 2), 'white')
            for n, im in enumerate(ims): sheet.paste(im, ((n % 4) * w, (n // 4) * h))
            path = os.path.join(out_dir, 'sheet-%02d.png' % (k // 8 + 1))
            sheet.save(path); print('sheet: %s (pages %s)' % (path, ', '.join(map(str, pages[k:k + 8]))))
    return 1 if total else 0


if __name__ == '__main__':
    sys.exit(main())
