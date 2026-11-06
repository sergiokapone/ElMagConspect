"""Record the applet scenes pinned to narration timestamps, then mux with the narration audio."""
import json, subprocess, shutil, sys
from pathlib import Path
import rec_lib, ac_lab_scenes as S

AUDIO = Path(r'C:\Videos\2026-11-06 17-17-29.mkv')
OUT = Path('out'); OUT.mkdir(exist_ok=True)
LEAD = 0.4   # start actions slightly before the words
SLOTS = [  # (scene, start of narration in s)
    ('s01_intro', 2.8), ('s02_layout', 26.2), ('s03_params', 53.0), ('s04_generator', 74.1),
    ('s05_scope', 93.5), ('s06_xy', 119.4), ('s07_phasor', 136.9), ('s08_connect', 162.5),
    ('s09_scan', 186.2), ('s10_theory', 217.9), ('s11_works', 232.4), ('s12_end', 251.4)]
END = 262.7

tmp = OUT / 'raw'; shutil.rmtree(tmp, ignore_errors=True); tmp.mkdir()
p, b, ctx, pg, r = rec_lib.session(S.URL, tmp)
off = r.video_offset
for i, (name, t) in enumerate(SLOTS):
    r.until(t - LEAD)
    t_in = r.t()
    getattr(S, name)(r)
    nxt = SLOTS[i + 1][1] if i + 1 < len(SLOTS) else END
    print(f'{name}: started {t_in:.1f} (target {t-LEAD:.1f}), took {r.t()-t_in:.1f}s, slot {nxt-t:.1f}s', flush=True)
r.until(END)
vpath = pg.video.path()
ctx.close(); b.close(); p.stop()
final = OUT / 'ac_lab_video.mp4'
subprocess.run(['ffmpeg', '-y', '-v', 'error', '-ss', f'{off:.3f}', '-i', vpath, '-i', str(AUDIO),
                '-map', '0:v', '-map', '1:a', '-t', str(END), '-c:v', 'libx264', '-crf', '20', '-pix_fmt', 'yuv420p',
                '-r', '30', '-c:a', 'aac', '-b:a', '160k', '-ac', '1', str(final)], check=True)
print('video offset', round(off, 2), '->', final)
