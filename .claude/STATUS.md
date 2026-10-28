# Стан вичитки (≤ 40 рядків; підтримувати стислим)

Зауваження по пунктах --- у `review/<Folder>.md`.
Історія з хешами комітів --- `REVIEW.md` (хеші після `purge` 28.10 застарілі).

## Де зупинилися (стисло; перевірити `git status` / `git log -5`: запис міг відстати)
- Усі 20 розділів вичитано до 24.10.2026. 27--28.10 зроблено наступні проходи: SteadyCurrent, CurrentsInMedia, MagFieldVacuum, MagFieldMedia,
  ElMagInduction (6 проходів), MagEnergy, MaxwellEqns (3), Relativity, ElMagWaves, Radiation, ElMagOscillations, Telegraph, Waveguides.
  Другого проходу для EBMotion та розділів Charges--ElEnergy в записах не видно (лише перша вичитка).
- Не закомічено за останніми записами: MagFieldVacuum, MagFieldMedia, Relativity, ElMagWaves, Radiation, ElMagOscillations, Waveguides, MagEnergy, ElMagInduction.
- 28.10 (вечір): повна збірка PDF (526 с.) і HTML опубліковано в `docs/`; `python elmag.py purge` + force-push (усі хеші змінились);
  резервні `.bundle` лежать поза репозиторієм (`D:\Projects\LaTeX\ElMag\ElMagConspect-backup-20261028-*.bundle`, можна видалити, коли переконаєтесь).
- Верстка: `lint` на повній збірці 16 знахідок (9 вдів, 3 сироти, 3 смуги всередині ~с. 78, 205, 237, 1 порожнеча знизу ~с. 315).
  Стан `lua-widow-control` у `ConspectBook.cls` у записах суперечливий (вимкнено → знову ввімкнено balanced): перевірити файл.
- **Автор: уточнити**, що саме робилося 25.10 (Charges, ChargeSystem, CurrentsInMedia, SteadyCurrent, Preface, `ConspectBook.cls`, `Additions/Vanaliz.tex`:
  у `REVIEW.md` не відображено) і що з цього не закомічено / не опубліковано: ______________________

## Відкриті пункти
- [ ] Charges, рис. 1.5 (Кавендіш): обмеження |ε| ≲ 10⁻¹⁶ за Williams, Faller, Hill (1971) --- за бажання додати посилання.
- [ ] Повна збірка: `Missing character: There is no ; (U+003B) in font nullfont!` на стор. 43, 44, 70.
- [ ] Повна збірка: overfull ≈ 7 pt на рядках 103--223 (було до вичитки решти розділів; перевірити, чи лишилося).
- [ ] Дрібні overfull: SteadyEfield (3,6 pt, біля рисунка до теореми Ерншоу), FieldInMetalls (5,4 pt, початок розділу).

## Рішення, що чекають автора
- «Провід» → «дріт» ще лишилось у Telegraph, ElMagOscillations, Relativity, Radiation. Епіграф Хевісайда (Telegraph, п. 17) не звірено. `\raggedbottom` проти порожнеч навколо «Підсумки»/«Задачі»?
- Відносність: енергія частинки ε → E, калібрувальна функція χ → f (28.10, за рішенням автора; E тепер означає і поле, і енергію частинки: у таблиці позначень зазначено; p --- імпульс частинки ↔ дипольний момент лишається).
- Зробити «нерозривні задачі» один раз у `ConspectBook.cls` замість групи `\begingroup\tcbset{...}` у кожному розділі?
- `Plasma` (і `Tensions`) не підключені в `main.tex`: так задумано чи ні?

## Розбіжності: не чіпати без розмови з автором
- FieldInMetalls, рис. 1.3 (провідник у полі): автор вважає рисунок правильним (зауваження Claude --- лінії поля заходять усередину
  провідника --- не прийнято; виправлено лише текст).
- Порядок частин: ElMagOscillations після MagEnergy/індукції --- Claude радив, автор залишив свій порядок (узгоджено з передмовою).
- ChargeSystem, лінійний квадруполь (+q, −2q, +q): у реальній CO₂ знаки протилежні; модель залишено, додано примітку.
- Charges: трибоелектричний ряд не є суворо відтворюваним --- свідомо не згадано.
- Частина VII (ElMagOscillations, Telegraph, Waveguides) --- у СІ свідомо.

## Наступні кроки
1. Закрити пункти «Де зупинилися» (що змінено 25.10, що закомічено).
2. `python elmag.py pdf` → перевірити попередження зі списку вище → `python elmag.py html` → коміт `docs/` → push (лише на прохання).
3. Рішення автора по `Plasma` і нерозривних задачах.
4. Нові розділи/правки --- через `/review-chapter <Папка>`.
