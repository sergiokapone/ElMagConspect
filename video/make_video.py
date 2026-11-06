"""Narrated screencast of lab_bench_battery.html: edge-tts voice + Playwright video + ffmpeg mux.
Usage: python make_video.py [--fast]   (--fast: no audio generation, short pauses, for debugging actions)
"""
import asyncio, subprocess, sys, time, json, re
from pathlib import Path
import edge_tts
from playwright.sync_api import sync_playwright

HERE = Path(__file__).parent
OUT = HERE / "out"; OUT.mkdir(exist_ok=True)
URL = (HERE.parents[0] / ".." / "..").resolve()  # placeholder, replaced below
URL = "file:///D:/Projects/LaTeX/ElMag/ElMagConspect/docs/applets/lab_bench_battery.html"
VOICE = "uk-UA-OstapNeural"
FAST = "--fast" in sys.argv

# Pronunciation fixes for the TTS engine (it spells abbreviations letter by letter)
PRON = [("ВАХ", "вах"), ("ЕРС", "електрорушійна сила"), ("ККД", "ка-ка-де"), ("ε", "епсилон"),
        ("R_i", "ер і"), ("P_max", "пе максимум"), ("CSV", "сі-ес-ві"), ("χ²", "хі-квадрат"),
        ("мА", "міліампер"), ("Ом", "ом")]
def pron(t):
    for a, b in PRON: t = t.replace(a, b)
    t = re.sub(r"(о|О)(пі|по)", "\1́\2", t)   # "опір", "опору": stress on the first vowel
    return t

# ---------- page helpers ----------
def slide(p, to, ms=900):
    p.evaluate("""([to,ms])=>new Promise(r=>{const s=document.getElementById('pos');const a=+s.value;const n=Math.max(8,ms/30);
      let i=0;const t=setInterval(()=>{i++;s.value=a+(to-a)*i/n;s.dispatchEvent(new Event('input',{bubbles:true}));
      if(i>=n){clearInterval(t);r();}},30);})""", [to, ms])
def pick(p, sel, val):
    p.select_option(sel, str(val)); p.wait_for_timeout(300)
def click(p, sel):
    box = p.locator(sel).first.bounding_box()
    if box: p.mouse.move(box["x"] + box["width"] / 2, box["y"] + box["height"] / 2, steps=25)
    p.locator(sel).first.click(); p.wait_for_timeout(250)
def show(p, sel):
    p.locator(sel).first.scroll_into_view_if_needed(); p.wait_for_timeout(400)
def points(p, positions, pause=550):
    for x in positions:
        slide(p, x, 700); p.wait_for_timeout(250); click(p, "#take"); p.wait_for_timeout(pause)
def toggle(p, summary_text, want_open=True):
    d = p.locator("details", has=p.locator("summary", has_text=summary_text)).first
    if d.evaluate("e=>e.open") != want_open: d.locator("summary").first.click(); p.wait_for_timeout(500)
    d.scroll_into_view_if_needed()
def top(p): p.evaluate("window.scrollTo({top:0,behavior:'smooth'})"); p.wait_for_timeout(600)

P_ALL = [3, 12, 24, 38, 52, 68, 84, 97]
P_FEW = [3, 15, 35, 55, 75, 97]

S = [
 ("Вітаю! Це віртуальний практикум «ВАХ джерела ЕРС». Ми визначимо електрорушійну силу та внутрішній опір батарейки й акумулятора мотоцикла.", lambda p: top(p)),
 ("Ліворуч панель параметрів: джерело, режим роботи та схема включення приладів. Обираємо батарейку, п’ятнадцять десятих вольта, нова, внутрішній опір пів ома.", lambda p: (pick(p, "#src", "bat"), pick(p, "#emf", 1.5), pick(p, "#ri", 0.5), p.locator("#mode").hover())),
 ("Джерело замкнене на реостат. Амперметр показує струм, вольтметр напругу. Повзунок униз: опір навантаження малий, струм максимальний, а напруга майже нуль. Це близько до короткого замикання. Повзунок угору: струм майже нуль, а напруга майже дорівнює електрорушійній силі. Це холостий хід.", lambda p: (toggle(p, "Схема стенда"), show(p, "#pos"), slide(p, 3, 2500), p.wait_for_timeout(2500), slide(p, 97, 3500))),
 ("Тепер знімаємо характеристику. Ставимо повзунок, дивимося на прилади й натискаємо «Зняти точку». Потрібно шість–десять точок рівномірно, обов’язково біля короткого замикання та біля холостого ходу.", lambda p: (slide(p, 3, 800), points(p, P_ALL, 700))),
 ("Графік напруги від струму це пряма. Вона відтинає на осі напруги електрорушійну силу, а її нахил дорівнює внутрішньому опору. Підгонка зважена та враховує похибки обох приладів. Результат ліворуч.", lambda p: (show(p, "#cUI"), p.wait_for_timeout(2500), top(p), show(p, "#fr"))),
 ("Нормовані криві показують, що точки лягли на теоретичні лінії. На графіку потужності є максимум при опорі навантаження, що дорівнює внутрішньому опору. ККД у цей момент тільки п’ятдесят відсотків.", lambda p: (show(p, "#cNorm"), p.wait_for_timeout(2500), show(p, "#cPow"))),
 ("Зберігаємо серію й змінюємо стан: підсаджена батарейка, внутрішній опір чотири оми. Знімаємо точки заново. На графіках видно іншим кольором стару серію: електрорушійна сила та сама, а характеристика стала крутішою.", lambda p: (top(p), show(p, "#saveSer"), click(p, "#saveSer"), pick(p, "#ri", 4), show(p, "#pos"), slide(p, 3, 600), points(p, P_FEW, 450), show(p, "#cUI"))),
 ("Тепер акумулятор мотоцикла: дванадцять вольтів, новий, внутрішній опір дві соті ома. Для малого внутрішнього опору краще схема А, де вольтметр стоїть на затискачах джерела.", lambda p: (top(p), pick(p, "#src", "acc"), pick(p, "#emf", 12), pick(p, "#ri", 0.02), pick(p, "#scheme", "term"), show(p, "#pos"), slide(p, 3, 600), points(p, P_FEW, 450))),
 ("Для порівняння збережемо серію й повторимо в схемі Б. Внутрішній опір вийшов більшим приблизно на опір амперметра. Це систематична похибка схеми.", lambda p: (show(p, "#saveSer"), click(p, "#saveSer"), pick(p, "#scheme", "load"), show(p, "#pos"), slide(p, 3, 600), points(p, P_FEW, 350), show(p, "#cUI"))),
 ("Режим «чорний ящик»: параметри джерела невідомі. Знімаємо характеристику, знаходимо електрорушійну силу та внутрішній опір і перевіряємо відповідь.", lambda p: (top(p), pick(p, "#mode", "box"), show(p, "#pos"), slide(p, 3, 600), points(p, P_FEW, 350))),
 ("Підсумок. Характеристика реального джерела пряма: відтинок дає електрорушійну силу, нахил внутрішній опір. Максимум потужності при опорі, що дорівнює внутрішньому, а ККД тоді п’ятдесят відсотків. Дякую за увагу!", lambda p: top(p)),
]

CURSOR_JS = """
const d=document.createElement('div');d.style.cssText='position:fixed;z-index:99999;width:18px;height:18px;border-radius:50%;background:rgba(255,60,60,.65);border:2px solid #fff;pointer-events:none;left:-30px;top:-30px;transform:translate(-50%,-50%)';
document.addEventListener('DOMContentLoaded',()=>document.body.appendChild(d));
document.addEventListener('mousemove',e=>{d.style.left=e.clientX+'px';d.style.top=e.clientY+'px'},true);
"""

async def synth():
    for i, (t, _) in enumerate(S):
        f = OUT / f"s{i:02d}.mp3"
        if not f.exists():
            await edge_tts.Communicate(pron(t), VOICE, rate="-5%").save(str(f))
def audio(i):
    """Converted (user's voice) wav if the batch conversion has run, else the plain TTS mp3."""
    w = list((OUT / "vc").glob(f"vc_s{i:02d}_*.wav"))
    return w[0] if w else OUT / f"s{i:02d}.mp3"
def dur(f):
    return float(subprocess.check_output(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", str(f)]).decode())

def main():
    if "--synth" in sys.argv: asyncio.run(synth()); return
    if not FAST: asyncio.run(synth())
    durs = [0.5 if FAST else dur(audio(i)) for i in range(len(S))]
    starts = []
    for f in OUT.glob("*.webm"): f.unlink()
    with sync_playwright() as pw:
        b = pw.chromium.launch()
        ctx = b.new_context(viewport={"width": 1600, "height": 900}, record_video_dir=str(OUT), record_video_size={"width": 1600, "height": 900})
        ctx.add_init_script(CURSOR_JS)
        p = ctx.new_page(); p.goto(URL); p.wait_for_timeout(1500)
        t0 = time.time()
        for i, (t, act) in enumerate(S):
            ts = time.time(); starts.append(ts - t0)
            try:
                if act: act(p)
            except Exception as e:
                print(f"step {i} action failed: {str(e)[:200]}")
            left = durs[i] + 0.6 - (time.time() - ts)
            if left > 0: p.wait_for_timeout(int(left * 1000))
            print(f"step {i}: start {starts[-1]:.1f}s  audio {durs[i]:.1f}s")
        p.screenshot(path=str(OUT / "last.png"))
        ctx.close(); b.close()
    vid = max(OUT.glob("*.webm"), key=lambda f: f.stat().st_mtime)
    if FAST: print("video:", vid); return
    # place each phrase at its recorded start time and mix
    inputs, filt = [], []
    for i, s in enumerate(starts):
        inputs += ["-i", str(audio(i))]
        filt.append(f"[{i+1}:a]adelay={int((s+1.5)*1000)}|{int((s+1.5)*1000)}[a{i}]")  # +1.5 s: page load before t0
    mix = "".join(f"[a{i}]" for i in range(len(starts))) + f"amix=inputs={len(starts)}:normalize=0[aout]"
    final = OUT / "lab_bench_battery_demo.mp4"
    subprocess.run(["ffmpeg", "-y", "-i", str(vid), *inputs, "-filter_complex", ";".join(filt) + ";" + mix,
                    "-map", "0:v", "-map", "[aout]", "-c:v", "libx264", "-pix_fmt", "yuv420p", "-c:a", "aac", "-shortest", str(final)],
                   check=True, stderr=subprocess.DEVNULL)
    print("done:", final)

main()
