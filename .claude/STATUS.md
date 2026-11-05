# Стан вичитки (≤ 40 рядків; підтримувати стислим)

Зауваження --- `review/<Folder>.md`. Історія --- `REVIEW.md` (хеші після `purge` 28.10 застарілі).
Деталі посилань і джерел по розділах (29.10), журнал сесій --- `.claude/STATUS-archive.md` (не імпортується; лише `grep -n`).

## Де зупинилися (перевірити `git status` / `git log -5`: запис міг відстати)
- Усі 20 розділів вичитано до 24.10.2026; далі --- другі проходи (ElMagInduction, ElMagOscillations, MaxwellEqns тощо). Для EBMotion і Charges--ElEnergy другого проходу немає.
- 04.11.2026: петлі гістерезису (MagFieldMedia, рис. `pic:Soft`, `pic:Hard`) переписано в TikZ: `tikz/hysteresis-bh.tikz` (спільний код, B=Bs·tanh((H∓Hc)/w)) + `hysteresis-soft.tikz` (Hc=1 Е, Br=0,8·10⁴ Гс, шкала H ±10 Е) і `hysteresis-hard.tikz` (Hc=500 Е, Br=1,0·10⁴ Гс, шкала ±1500 Е). Рамка однакова, шкала B спільна, числа на осях через кому/тонкий пробіл. Старі `Pictures/Soft.jpg`, `Hard.jpg` не видалено. Перевірено лише `chapter.py`; HTML (lwarp, `\input{\currfiledir ...}`, `pgfmathprintnumber`) не збирали. Значення типові, не з конкретних марок.
- 04.11.2026: `Extra` --- tcolorbox (див. `conventions.md`); «Постійні магніти» і Extra «Фіктивні магнітні заряди*», рис. `pic:MagnetFields`, `electret-fields.tikz` переписано. Повну збірку, `lint`, HTML після цього НЕ перевіряли. Закон Кулона для полюсів у Extra без `\cite` (автор: потрібне посилання?). Poisson1826 у bib: с. 338 і рік звірити за сканом. Далі (04.11): прибрано повтори між «Постійними магнітами» і Extra; термін скрізь «фіктивні магнітні заряди» (і в MagFieldVacuum); полюси визначено в MagFieldVacuum (`sec:MagDipoleCharges`), у MagFieldMedia лише посилання; N/S на `dipole-equivalent-charges.tikz` винесено вбік. Зібрано лише окремі глави (Vacuum: Overfull 2, причину не перевіряли).
- 04.11.2026 (вечір): за зауваженнями 28--45 переписано «Постійні магніти» і Extra (робоча точка на спадній гілці, оцінка N ≲ 0,05 за H_c, фактор `\mathcal N`, відмінність від електрета: екранування заряду вільними зарядами; абзац додано і в FieldInDielectrics, «Електрети»); додано `Coulomb1785` (с. 612--638 зі вторинних джерел). Повна збірка `python elmag.py pdf`: 576 с., 613 с. часу; «??» і «[?]» у тексті PDF немає; `main.log`: undefined/multiply defined 0, лише 3 Font Warning (StixTwoMath bold); overfull ≈7 pt (рядки 189, 210, 212, ще 8). `lint`: 27 знахідок, у «Постійних магнітах»/Extra чисто; розділ 10: widow с. 259 і 261, порожнеча 123 pt перед «Задачі» (с. 267, пов'язана з рішенням про `\raggedbottom`). HTML не збирали.
- 05.11.2026: значок `\faMicroscope` замість «*» (`\ExtraMark`; заголовки перед `Extra` --- `\ExtraHeading[n]{…}`, n = \baselineskip запасу, за замовч. 9; обидва класи). Штрафи вдів/сиріт `\clubpenalties=3 10000 10000 0` (останнє значення повторюється!) у `problem`, `Extra`, `Simulation`: розрив абзацу від 3-го рядка (раніше `=2 10000 10000` забороняло будь-який розрив). Повна збірка + `lint`: 27 → 2 (с. 326 порожнеча 101 pt перед «Задачі» ElMagInduction: задача 12.10 з 5 рядків не розривається; с. 500 Telegraph 91 pt). Правки глав: `\Needspace`, перенесення `wrapstuff` (ElMagInduction), невеликі скорочення формулювань (без зміни змісту: Relativity, ElMagOscillations, ChargeSystem, CurrentsInMedia). HTML НЕ збирали: перевірити `\ExtraMark`/`\ExtraHeading` у lwarp. Не закомічено.
- 05.11.2026: додано аплети з `d:\Documents\`: `docs/applets/em-induction/` (збірка `npm run build` проєкту `em-induction-sim`; після змін там: build і копія `dist/`) та `docs/applets/ac_lab.html` (з `ac-labs`); `\simlink` у ElMagInduction (після «Струми Фуко») і ElMagOscillations (після «Резонанс струмів»). Верстка двох сторінок перевірена, повну збірку PDF/HTML НЕ робили. Закомічено і запушено (9825ab2).
- 05.11.2026: історія `origin/main` виявилась переписаною (ті самі коміти, інші хеші, дерево однакове). Локальний `main` вирівняно за GitHub, старий стан у гілці `backup-local-main-20261105` (видалити, коли все гаразд). **Автор: хто/навіщо переписав історію?**
- **Автор: уточнити**, що робилося 25.10 (Charges, ChargeSystem, CurrentsInMedia, SteadyCurrent, Preface, `ConspectBook.cls`, `Additions/Vanaliz.tex`) і що не закомічено/не опубліковано: ______

## Відкриті пункти: збірка і верстка
- Після зміни `Extra`: `python elmag.py pdf` + `lint`; дивитись ElEnergy, ElMagInduction, MagEnergy, ElMagOscillations (вдови, порожнечі); `python elmag.py html` (вигляд `.cb-extra`).
- Повна збірка: `Missing character ;` (U+003B) на с. 43, 44, 70; overfull ≈7 pt (рядки 103--223); дрібні: SteadyEfield 3,6 pt, FieldInMetalls 5,4 pt.
- `lint` 28.10: 16 знахідок (9 вдів, 3 сироти, 3 смуги всередині ~с. 78, 205, 237, 1 порожнеча ~с. 315). `lua-widow-control` у `ConspectBook.cls`: стан суперечливий, перевірити файл. Після правок повторити `lint` і HTML.
- Література (два списки, `ConspectBook.cls`): перевірено лише `chapter.py Charges`; не перевірено зміст повного PDF і HTML (при `tocdepth=1` підрозділи в змісті HTML не з'являться).
- `Additions/Simulations.tex`: повна збірка PDF/HTML (`description`+`simlink` в lwarp не перевірено); нову симуляцію додавати і в розділ, і в додаток.
- HTML (`html_patches.py`): на екрані не підтверджено рис. 4.5, 14.3, 14.7, 14.8; правка CSS зачіпає `SkinEstimate1/2` (ch14).
- Аплети: кнопка ☾ на мобільному близько до заголовка; `docs/ch*.html` посилаються на `/Scripts/` до `python elmag.py html`; рис. `pic:DielectricInCapacitor`: пластина тонша за зазор (в аплеті на весь).
- Посилання на аплети (перевірено 03.11): `waveguide_modes.html` (Waveguides:153) є в тексті, але файлу немає: **автор: створити чи прибрати**. `filters.html` створено 04.11 (3 вкладки: ФНЧ, ФВЧ, смуговий; перевірено лише node-стабом). `docs/ElMagConspect.pdf` (56 посилань) і `docs/*.html` (34 у 7 файлах) ще ведуть на `/Scripts/`: перед push потрібні `python elmag.py pdf` і `html`, інакше 404. 10 аплетів без `\simlink` у книзі: Cyclotron, Hall_effect, biot_savart, dc_motor, displacement_current, kirchhoff_branches, lab_bench_rc_rl, lab_bench_rc_rl_thm, mass_spectrometer, source_internal_resistance (у `\simlist` їх не буде).
- Домени (`tikz/domains.tikz`, FieldInDielectrics і MagFieldMedia): автор має оглянути рисунки; lwarp з `\foreach`/`resizebox` не перевірено.
- ElMagOscillations: `example_branched.tikz` підписує вузол «E» замість A; `filter_phase.tikz` не перевірено в HTML; `ElMagOscillations_full.tex` untracked.

## Відкриті пункти: джерела і зміст
- Правило автора (29.10): у Historical-блоках КОЖНЕ історичне твердження має `\cite`. Перевірити Historical-блоки в усіх розділах (зроблено: MagFieldVacuum, CurrentsInMedia, ElMagInduction, EBMotion).
- Звірити: `tab:dipoles` (FieldInDielectrics) HCl 1,08; NH₃ 1,46; H₂O 1,84 Д проти ~1,11; 1,47; 1,85 (CRC106); Tolman1916 (number, кінцева сторінка, DOI); Krider2006; «Флемінг (1904)» проти статті 1905.
- Без джерела, автору вирішити: Мандельштам--Папалексі, «пондеромоторні» (Герц), Нейман 1845, Коллінз, Ерншоу 1842, дуга (Петров/Таунсенд), Блох 1928, термін «індукція», «до 1890-х розрахунок...». Повний перелік --- в архіві.
- Charges, рис. 1.5: за бажання додати посилання на Williams, Faller, Hill (1971). Епіграфи: звірити номери параграфів і переклади (перелік у `REVIEW.md`, «TODO автора»).
- ElMagOscillations: ДСТУ щодо ±10 % і 220/380 → 230/400 В не цитовано; епіграф Фейнмана (§12-1 т. 2); Q_C, ρ не внесено в `Additions/Notations.tex`.

## Рішення, що чекають автора
- «Провід» → «дріт» ще лишилось у Telegraph, ElMagOscillations, Relativity, Radiation. Епіграф Хевісайда (Telegraph, п. 17) не звірено. `\raggedbottom` проти порожнеч навколо «Підсумки»/«Задачі»?
- «Нерозривні задачі» один раз у `ConspectBook.cls` замість `\begingroup\tcbset{...}` у кожному розділі?
- `Plasma` і `Tensions` не підключені в `main.tex`: так задумано?
- MagFieldMedia, «Постійні магніти» і Extra «Фіктивні магнітні заряди*»: зауваження 28--45 (`review/MagFieldMedia.md`) внесено, також п. 38, 43 (фактор \mathcal N) і джерело для Кулона (Coulomb1785, сторінки 612--638 з вторинних джерел: звірити з оригіналом); лишилось: полюси N/S у `magnet-fields.tikz` (прямі жирні). Зміст .tex закомічено автором (5604ce7, 977b657); не закомічено: `docs/ElMagConspect.pdf` (нова збірка) і `.claude/settings.json` (прибрано deny на `main.log`), обидва у staged; коміт/push перервано автором.

## Розбіжності: не чіпати без розмови з автором
- FieldInMetalls, рис. 1.3: автор вважає правильним (зауваження Claude про лінії поля всередині провідника не прийнято; виправлено лише текст).
- Порядок частин: ElMagOscillations залишено після Maxwell/індукції за рішенням автора (узгоджено з передмовою). Частина VII --- у СІ свідомо.
- ChargeSystem, лінійний квадруполь: знаки в реальній CO₂ протилежні, модель залишено з приміткою. Charges: трибоелектричний ряд свідомо не згадано.
- Relativity: ε → E, χ → f (28.10, рішення автора; E означає і поле, і енергію частинки, у таблиці позначень зазначено).
- ElMagOscillations: числа добротності без `\cite`; більше задач не додавати.

## Наступні кроки
1. Закрити «Де зупинилися» (що змінено 25.10, що закомічено).
2. `python elmag.py pdf` → перевірити попередження → `python elmag.py html` → коміт `docs/` → push (лише на прохання).
3. Рішення автора по `Plasma`, нерозривних задачах, джерелах.
4. Нові розділи/правки --- через `/review-chapter <Папка>`. Нові симуляції --- у `docs/applets/` (скрипти не входять у збірку книги).
