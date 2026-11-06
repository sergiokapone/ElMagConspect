"""Batch voice conversion with Seed-VC: loads the models once, converts every out/s??.mp3 to the voice of the reference, skips done files.
Run from the seed-vc folder: ../vc310/Scripts/python.exe ../video/batch_vc.py [steps]"""
import sys, glob, os, argparse
sys.path.insert(0, os.getcwd())
import inference
_orig = inference.load_models; _cache = {}
inference.load_models = lambda a: _cache.setdefault('m', _orig(a))
steps = int(sys.argv[1]) if len(sys.argv) > 1 else 10
OUT = os.path.abspath('../video/out'); REF = os.path.abspath('../voice_sample.wav')
for f in sorted(glob.glob(os.path.join(OUT, 's??.mp3'))):
    name = os.path.splitext(os.path.basename(f))[0]
    if glob.glob(os.path.join(OUT, 'vc', f'vc_{name}_*.wav')): continue
    a = argparse.Namespace(source=f, target=REF, output=os.path.join(OUT, 'vc'), diffusion_steps=steps, length_adjust=1.0,
        inference_cfg_rate=0.7, f0_condition=False, auto_f0_adjust=False, semi_tone_shift=0, checkpoint=None, config=None, fp16=False)
    print('converting', name, flush=True); inference.main(a)
print('ALL DONE')
