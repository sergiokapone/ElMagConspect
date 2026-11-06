import json, sys, wave
import numpy as np
from faster_whisper import WhisperModel
m = WhisperModel('medium', device='cpu', compute_type='int8')
w=wave.open('audio/narration.wav'); a=np.frombuffer(w.readframes(w.getnframes()),dtype=np.int16).astype(np.float32)/32768
segs, info = m.transcribe(a, language='uk', word_timestamps=True, vad_filter=False, beam_size=5)
out = []
for s in segs:
    out.append({'start': round(s.start,2), 'end': round(s.end,2), 'text': s.text.strip(),
                'words': [{'w': w.word, 's': round(w.start,2), 'e': round(w.end,2)} for w in s.words]})
json.dump(out, open('audio/narration.json','w',encoding='utf-8'), ensure_ascii=False, indent=1)
for s in out: print(f"{s['start']:7.1f} {s['end']:7.1f}  {s['text'][:110]}")
