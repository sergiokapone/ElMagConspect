# Озвучення відео голосом автора (демо: lab_bench_battery)

Конвеєр: текст -> edge-tts (uk-UA-OstapNeural) -> Seed-VC (тембр автора) -> Playwright (запис екрана) -> ffmpeg.

- `make_video.py`: сценарій (список «текст + дія в апплеті»), `--synth` лише озвучка, `--fast` налагодження дій.
- `batch_vc.py`: пакетна конвертація `out/s??.mp3` -> `out/vc/*.wav` (кеш: готові пропускає). Запуск із папки seed-vc.
- `voice_sample.wav`: зразок голосу автора (Seed-VC бере перші 25 с).
- `lab_bench_battery_demo.mp4`: готовий ролик (чернетка).
- Не збережено (відтворюється): venv `vc310` (Python 3.10, torch 2.6 CPU, залежності Seed-VC) і клон https://github.com/Plachtaa/seed-vc.
- Локально, не в git (`.git/info/exclude`).
