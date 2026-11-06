"""Scenes for ac_lab.html. Each scene(rec) performs the actions; durations are natural (timing.json will pin them)."""
URL = 'file:///D:/Projects/LaTeX/ElMag/ElMagConspect/docs/applets/ac_lab.html'

def s01_intro(r):
    r.move(120, 300, 1.0); r.move(800, 300, 1.4); r.move(1200, 300, 1.2)

def s02_layout(r):
    r.outline('#p1', dur=1.8); r.outline('#s1', dur=1.5); r.outline('#i1', dur=1.8)
    r.click('#tabs button[data-t="1"]', dur=0.8)
    r.click('details.settings summary, header details summary', dur=0.9)
    r.wait(1.2)
    r.click('details.settings summary, header details summary', dur=0.4)

def s03_params(r):
    S = '#p1 input[type=range]'
    r.slider(S, 0, 0.75, 1.5); r.slider(S, 0, 0.5, 1.2)
    r.slider(S, 2, 0.3, 1.2); r.slider(S, 2, 0.6, 1.0)
    r.slider(S, 3, 0.8, 1.2); r.slider(S, 3, 0.4, 1.0)

def s04_generator(r):
    K = '#i1 svg.knob'
    r.knob(K, 0, 70, 1.5); r.knob(K, 0, -70, 1.5)
    r.click('#i1 button.btn-sov[title="множник 1000"]', dur=0.8)
    r.click('#i1 button.btn-sov[title="множник 100"]', dur=0.8)

def s05_scope(r):
    K = '#i1 svg.knob'
    r.outline('#i1 canvas', dur=1.5)
    r.hover('#i1 canvas', dur=0.5)
    r.knob(K, 3, 50, 1.2); r.knob(K, 3, -50, 1.2)      # В/под, канал I (порядок ручок уточнити по DOM)
    r.click('#i1 button.btn-sov[title^="автоматичне"]', dur=0.9)

def s06_xy(r):
    r.click('#i1 button.btn-sov[title="X–Y"]', dur=0.9)
    r.wait(3.0)
    r.slider('#p1 input[type=range]', 0, 0.8, 1.5); r.slider('#p1 input[type=range]', 0, 0.5, 1.5)
    r.click('#i1 button.btn-sov[title="I і II"]', dur=0.9)

def s07_phasor(r):
    r.outline('#ph1', dur=1.5)
    r.click('#ph1 button, #ph1 .btn', dur=0.8)
    r.wait(2.0)
    r.click('#ph1 button, #ph1 .btn', dur=0.4)

def s08_connect(r):
    for t in ['послідовне', 'паралельне', 'одиночний C₁']:
        r.click(f'#p1 label:has-text("{t}")', dur=0.8); r.wait(1.0)
    r.click('#p1 button:has-text("Рис. 1.7б")', dur=0.8); r.wait(1.0)
    r.click('#p1 button:has-text("Рис. 1.8")', dur=0.6); r.wait(1.0)
    r.click('#p1 button:has-text("Скинути")', dur=0.6)

def s09_scan(r):
    r.click('#p1 button:has-text("Автозйомка")', dur=0.9)
    r.wait(4.0)
    r.pg.locator('#t1 summary:has-text("Графіки")').click(); r.wait(0.5)
    r.hover('#t1 summary:has-text("Графіки")', dur=0.6)
    r.pg.mouse.wheel(0, 500); r.wait(3.0)
    r.pg.mouse.wheel(0, -500); r.wait(0.5)
    r.click('#p1 button:has-text("Очистити точки")', dur=0.9)

def s10_theory(r):
    r.click('#t1 details.th summary', dur=1.0); r.wait(1.0)
    for _ in range(3):
        r.pg.mouse.wheel(0, 450); r.wait(1.3)
    r.pg.mouse.wheel(0, -4000); r.wait(0.8)
    r.click('#t1 details.th summary', dur=0.8)

def s11_works(r):
    r.click('#tabs button[data-t="2"]', dur=0.9); r.wait(0.8)
    r.slider('#p2 input[type=range]', 0, 0.7, 1.2)
    r.click('#tabs button[data-t="3"]', dur=0.9); r.wait(0.8)
    r.slider('#p3 input[type=range]', 0, 0.9, 3.0)

def s12_end(r):
    r.click('#tabs button[data-t="1"]', dur=0.9); r.wait(2.0)
