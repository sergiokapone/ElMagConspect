"""Screen-recording helpers for applet video guides (Playwright + visible cursor).

Scene timing: Rec.t() is the time since the recording started; Rec.until(t) sleeps until that moment,
so a scene can be pinned to the narrator's timestamps (see timing.json) and the rest is padded.
"""
import math, time
from pathlib import Path
from playwright.sync_api import sync_playwright

CURSOR_JS = r"""
(() => {
  const mk = () => {
    if (document.getElementById('__cur')) return;
    const st = document.createElement('style');
    st.textContent = `#__cur{position:fixed;z-index:2147483647;width:22px;height:22px;margin:-3px 0 0 -3px;pointer-events:none;
      left:0;top:0;transition:none}
      #__cur svg{filter:drop-shadow(1px 2px 2px rgba(0,0,0,.45))}
      .__rip{position:fixed;z-index:2147483646;pointer-events:none;width:14px;height:14px;margin:-7px 0 0 -7px;border-radius:50%;
      border:3px solid #e8a200;animation:__rip .5s ease-out forwards}
      @keyframes __rip{to{transform:scale(3.2);opacity:0}}`;
    document.head.appendChild(st);
    const c = document.createElement('div'); c.id = '__cur';
    c.innerHTML = '<svg width="22" height="22" viewBox="0 0 22 22"><path d="M2 1 L2 17 L6.2 13 L9 19.5 L11.6 18.3 L8.8 12 L14.5 12 Z" fill="#fff" stroke="#111" stroke-width="1.4" stroke-linejoin="round"/></svg>';
    document.body.appendChild(c);
    document.addEventListener('mousemove', e => { c.style.left = e.clientX + 'px'; c.style.top = e.clientY + 'px'; }, true);
    document.addEventListener('mousedown', e => {
      const r = document.createElement('div'); r.className = '__rip'; r.style.left = e.clientX + 'px'; r.style.top = e.clientY + 'px';
      document.body.appendChild(r); setTimeout(() => r.remove(), 600);
    }, true);
  };
  if (document.body) mk(); else document.addEventListener('DOMContentLoaded', mk);
})();
"""


def ease(u):
    return u * u * (3 - 2 * u)


class Rec:
    def __init__(self, page):
        self.pg = page
        self.x, self.y = 800, 450
        self.t0 = time.time()

    # ---- time -------------------------------------------------------
    def t(self):
        return time.time() - self.t0

    def until(self, t):
        d = t - self.t()
        if d > 0:
            self.pg.wait_for_timeout(d * 1000)

    def wait(self, s):
        self.pg.wait_for_timeout(s * 1000)

    # ---- mouse ------------------------------------------------------
    def _tween(self, fn, dur):
        """Call fn(u) with u in 0..1 eased, paced by the wall clock (frames are skipped if the page is slow)."""
        t0 = time.time()
        while True:
            u = (time.time() - t0) / dur
            if u >= 1:
                break
            fn(ease(u))
        fn(1.0)

    def move(self, x, y, dur=0.7):
        x0, y0 = self.x, self.y
        self._tween(lambda u: self.pg.mouse.move(x0 + (x - x0) * u, y0 + (y - y0) * u), dur)
        self.x, self.y = x, y

    def center(self, sel, nth=0, dx=0.5, dy=0.5):
        loc = self.pg.locator(sel).nth(nth)
        loc.scroll_into_view_if_needed()
        b = loc.bounding_box()
        return b['x'] + b['width'] * dx, b['y'] + b['height'] * dy, b

    def hover(self, sel, nth=0, dur=0.7, dx=0.5, dy=0.5):
        x, y, _ = self.center(sel, nth, dx, dy)
        self.move(x, y, dur)

    def click(self, sel, nth=0, dur=0.7, dx=0.5, dy=0.5):
        self.hover(sel, nth, dur, dx, dy)
        self.wait(0.12)
        self.pg.mouse.down(); self.wait(0.08); self.pg.mouse.up()
        self.wait(0.2)

    def outline(self, sel, nth=0, dur=1.6, pad=6):
        """Walk the cursor around the box of an element (to 'show' a zone)."""
        _, _, b = self.center(sel, nth)
        pts = [(b['x'] + pad, b['y'] + pad), (b['x'] + b['width'] - pad, b['y'] + pad),
               (b['x'] + b['width'] - pad, b['y'] + b['height'] - pad), (b['x'] + pad, b['y'] + b['height'] - pad)]
        for p in pts:
            self.move(*p, dur / 4)

    def slider(self, sel, nth, frac, dur=1.0):
        """Drag a range-input thumb to a fraction (0..1) of its track."""
        x, y, b = self.center(sel, nth)
        inp = self.pg.locator(sel).nth(nth)
        cur = float(inp.input_value()); mn = float(inp.get_attribute('min')); mx = float(inp.get_attribute('max'))
        cf = (cur - mn) / (mx - mn)
        # chrome range thumb ~16 px: track spans [x+8, x+w-8]
        tx = lambda f: b['x'] + 8 + f * (b['width'] - 16)
        self.move(tx(cf), y, 0.6)
        self.pg.mouse.down()
        self._tween(lambda u: self.pg.mouse.move(tx(cf + (frac - cf) * u), y), dur)
        self.pg.mouse.up(); self.x = tx(frac); self.y = y
        self.wait(0.2)

    def knob(self, sel, nth, turns_deg, dur=1.2):
        """Rotate a knob (svg.knob) by turns_deg degrees: pointer moves on a circle around its centre."""
        x, y, b = self.center(sel, nth)
        r = min(b['width'], b['height']) * 0.36
        a0 = 0.0  # start at 12 o'clock
        self.move(x + r * math.sin(a0), y - r * math.cos(a0), 0.6)
        self.pg.mouse.down()
        def f(u):
            a = a0 + math.radians(turns_deg) * u
            self.pg.mouse.move(x + r * math.sin(a), y - r * math.cos(a))
        self._tween(f, dur)
        self.pg.mouse.up(); self.x = x + r * math.sin(math.radians(turns_deg)); self.y = y - r * math.cos(math.radians(turns_deg))
        self.wait(0.2)

    def fill(self, sel, nth, text):
        self.click(sel, nth, 0.6)
        self.pg.keyboard.press('Control+A')
        self.pg.keyboard.type(str(text), delay=90)
        self.pg.keyboard.press('Enter')
        self.wait(0.3)


def session(url, out_dir, w=1600, h=900):
    """Context manager-ish: returns (playwright, browser, context, page, rec)."""
    p = sync_playwright().start()
    b = p.chromium.launch()
    ctx = b.new_context(viewport={'width': w, 'height': h}, record_video_dir=str(out_dir),
                        record_video_size={'width': w, 'height': h})
    ctx.add_init_script(CURSOR_JS)
    tp = time.time()
    pg = ctx.new_page()
    pg.goto(url)
    pg.wait_for_timeout(1200)
    pg.mouse.move(800, 450)
    r = Rec(pg)
    r.video_offset = r.t0 - tp   # video file time = Rec.t() + video_offset
    return p, b, ctx, pg, r
