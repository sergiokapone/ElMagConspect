import sys, shutil
from pathlib import Path
import rec_lib, ac_lab_scenes as S
out = Path(sys.argv[1]); out.mkdir(parents=True, exist_ok=True)
p,b,ctx,pg,r = rec_lib.session(S.URL, out)
for name in sys.argv[2:]:
    getattr(S, name)(r)
    pg.screenshot(path=str(out/f'{name}.png'))
    print(name, 'ok', round(r.t(),1))
ctx.close(); b.close(); p.stop()
