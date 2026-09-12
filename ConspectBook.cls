% ==============================================================================
%  ConspectBook.cls
%  Клас для верстки конспекту/підручника (напр. "Класична електродинаміка").
%  Базується на стандартному класі book, розрахований на LuaLaTeX
%  (є fallback-гілки для pdfLaTeX через \ifluatex).
% ==============================================================================
\NeedsTeXFormat{LaTeX2e}[1994/06/01]
\ProvidesClass{ConspectBook}[2024/12/21]
\LoadClass[onecolumn, twoside]{book}   % базовий клас — книга, двостороння, одна колонка
%\LoadClass[]{tufte-book}              % (не використовується) альтернатива — стиль Тафті

%===============================================================================
%
%									Логічні змінні
%
%===============================================================================
% Усі \newif класу зібрано в одному місці. Частина використовується у \DeclareOption
% нижче (electronic/biblatex/marginversioninfo), решта — під час верстки документа
% (перемикаються командами \appendix, \answers тощо, оголошеними далі у файлі).
\newif\ifelectronic          % true = електронна версія (кольорові посилання), false = друк
\newif\ifbiblatex            % true = використовувати biblatex замість стандартної bibliography
\newif\ifmarginversioninfo   % true = виводити на полях службову інформацію про версію
\newif\ifappendix            % true = документ зараз перебуває у розділі "Додатки"
\newif\ifanswers             % true = документ зараз перебуває у розділі "Відповіді"
\newif\iftoc                 % (прапорець для змісту; використовується користувачем документа)
\newif\ifbibliography        % (прапорець наявності бібліографії)
\newif\ifintro                % (прапорець наявності вступу)

%===============================================================================
%
%									Налаштування опцій класу
%
%===============================================================================
% Опції передаються у \documentclass[...]{ConspectBook}.
% За замовчуванням діє "electronic" (див. \ExecuteOptions нижче).

% Опція "print" — паперова версія: чорно-білі (невидимі) гіперпосилання
\DeclareOption{print}{
	\PassOptionsToPackage{colorlinks=false}{hyperref}
	\PassOptionsToPackage{pdfsubject={Version for Printing}}{hyperref}
	\electronicfalse
}

% Опція "electronic" — електронна версія: кольорові посилання малинового кольору.
% \defcolor визначається тут же і застосовується нижче (\defcolor{}), бо колір "malina"
% з пакета xcolor (usenames,dvipsnames,svgnames,table) має бути підвантажений вже
% після того, як \ProcessOptions обере потрібну гілку.
\DeclareOption{electronic}{\def\defcolor{\RequirePackage[usenames,dvipsnames,svgnames,table]{xcolor}\definecolor{malina}{rgb}{0.6,0.0,0.0}}
	\PassOptionsToPackage{linkcolor=malina}{hyperref}
	\PassOptionsToPackage{colorlinks=true}{hyperref}
	\PassOptionsToPackage{urlcolor=blue}{hyperref}
	\PassOptionsToPackage{citecolor=green!60!black}{hyperref}
	\PassOptionsToPackage{pdfsubject={Electronic Version}}{hyperref}
	\electronictrue
}

% Опція "marginversioninfo" — вмикає друк службової інформації про версію на полях
\DeclareOption{marginversioninfo}{%
	\marginversioninfotrue
}

% Опція "biblatex" — перемикає бібліографію на biblatex (див. розділ "Бібліографія")
\DeclareOption{biblatex}{
	\biblatextrue
}

\ExecuteOptions{electronic}  % опція за замовчуванням, якщо користувач не вказав свою
\ProcessOptions\relax        % обробити опції, передані користувачем у \documentclass[...]
\defcolor{}                  % виконати відкладене визначення кольору "malina" з обраної опції

%===============================================================================
%
%							Геометрія сторінки
%
%===============================================================================
% Поля сторінки формату A4. \topspace винесено в окрему довжину, бо використовується
% також в інших місцях документа (напр. для розрахунків на титульних сторінках).
\newlength{\topspace}
\setlength{\topspace}{2cm}
\RequirePackage[%
	a4paper,%
	footskip=1cm,%
	headsep=0.5cm,%
	top=\topspace, %поле сверху
	bottom=2cm, %поле снизу
	left=2cm, %поле ліворуч
	right=2cm, %поле праворуч
]{geometry}
%\usepackage[lmargin=8cm,rmargin=1cm,marginparwidth=6cm,marginparsep=2em]{geometry}  % (не використовується) варіант із широким полем під нотатки


%===============================================================================
%
%							Налаштування мови та компіляторів
%
%===============================================================================
% Клас підтримує і LuaLaTeX (основний варіант, з fontspec/unicode-math),
% і pdfLaTeX (запасний варіант, з класичним fontenc/inputenc).
\RequirePackage[fontsize=14pt]{fontsize}  % базовий кегль тексту книги
\RequirePackage{iftex}                    % дає \ifluatex/\ifxetex для розгалуження нижче


\ifluatex
	% ---- Гілка LuaLaTeX: сучасні OpenType-шрифти через fontspec ----
	\RequirePackage{fontspec}
	%    \RequirePackage[sfdefault,regular]{roboto}
	\setmainfont{BookmanOldStyle}%{alegreya}%{CMU Serif}      % основний (серифний) шрифт
	\setsansfont{Roboto}%{Arial}                              % рублений шрифт (заголовки тощо)
	\setmonofont{JetBrains Mono}%{Consolas}                   % моноширинний шрифт (код)
	\defaultfontfeatures{Ligatures={TeX}}
	%	\newfontfamily\Annabelle{Annabelle}
	\newfontfamily\Alexander{Alexander}    % додаткова декоративна гарнітура \Alexander{...}
	\RequirePackage{luacolor}              % коректна робота кольору тексту під LuaLaTeX
\else
	% ---- Гілка pdfLaTeX: класична кирилична підтримка через T2A ----
	\RequirePackage[T2A,T1]{fontenc}
	\RequirePackage[utf8]{inputenc}
	\input{glyphtounicode}
	\pdfgentounicode=1               % коректний copy-paste кирилиці з готового PDF
	%\RequirePackage{pscyr}
	\RequirePackage{cmap}            % пошук/копіювання тексту в PDF
	\renewcommand{\sfdefault}{fos}
	\renewcommand{\bfdefault}{b}
\fi
\RequirePackage[english,russian,ukrainian]{babel}  % українська — основна мова документа (остання в списку)

%===============================================================================
%
%							Налаштування типографських вимог
%
%===============================================================================

\RequirePackage{microtype}   % мікротипографія (protrusion, expansion) — акуратніші рядки
%\RequirePackage[nosingleletter, hyphenation, lastparline]{impnattypo}
%\usepackage[defaultlines=4,all]{nowidow}
%\clubpenalty =1000
%\widowpenalty=1000
%\setlength{\parskip}{0.5ex}%
\setlength{\parindent}{2em}%   % відступ першого рядка абзацу
%\renewcommand{\baselinestretch}{1.1}
\def\@textbottom{\vskip \z@ \@plus 1pt}   % дозволити сторінці "не дотягувати" знизу без розтягування
\let\@texttop\relax                       % те саме зверху сторінки
%\setlength{\emergencystretch}{1em}


%===============================================================================
%
%										Кольори
%
%===============================================================================
% Загальна палітра книги: акцентні кольори тексту/боксів (themecolor*),
% кольори секцій титульних сторінок (titlebg*) та кольори для фізичних рисунків
% (efield/dfield/jfield — використовуються у tikz-ілюстраціях полів).
\definecolor{malina}{RGB}{153,0.0,0.0}
%\definecolor{lighbluecolor}{RGB}{0,163,243}
%\definecolor{iptgreen}{RGB}{34,102,101}
%\definecolor{themecolordark}{RGB}{0,163,243}
%\definecolor{themecolorlight}{RGB}{191,233,251}
\definecolor{themecolormain}{RGB}{51,51,178}
\definecolor{themecolordark}{RGB}{0,46,100}
\definecolor{themecolorlight}{RGB}{0,100,170}
\definecolor{paper}{RGB}{239,227,157}
% ------------- Кольори секцій ------------------------------
\definecolor{titlebgdark}{RGB}{0,103,102}
\definecolor{titlebglight}{RGB}{191,233,251}
% ------------- Кольори рисунків ----------------------------
\definecolor{efield}{rgb}{1, 0, 0}   % колір вектора E на рисунках
\definecolor{dfield}{rgb}{0, 0, 1}   % колір вектора D на рисунках
\definecolor{jfield}{named}{teal}    % колір густини струму j на рисунках

%===============================================================================
%
%									Пакети загального призначення
%
%===============================================================================

\RequirePackage[overload]{textcase}
\let\MakeUppercase\MakeTextUppercase   % коректна робота \MakeUppercase з кирилицею/захищеним текстом

\RequirePackage{indentfirst}   % відступ також у першому абзаці розділу (типова книжкова верстка)
% ------------------------------------ Плаваючі об'єкти ------------------------
%\RequirePackage{subfig}
%\renewcommand\thesubfigure{\alph{subfigure}}
\RequirePackage{wrapstuff}   % обтікання тексту навколо рисунків/таблиць
% ---------------------------- Фалові операції ---------------------------------
\RequirePackage{currfile}    % дає \currfilebase — ім'я поточного inputt-файлу без розширення
% \localinput{ім'я} — підключити tikz-рисунок з підпапки tikz/ поточного файлу,
% напр. у файлі "chapter1/chapter1.tex" виклик \localinput{fig.tikz}
% підвантажить "chapter1/tikz/fig.tikz". Використовується у розділах-главах книги.
\newcommand{\localinput}[1]{\input{\currfilebase/tikz/#1}}
% ---------------------------- Пакети LaTeX3 -----------------------------------
% --------------------------------------------------------------------------------
\RequirePackage{lastpage}          % \pageref{LastPage} — номер останньої сторінки
\RequirePackage[disable]{todonotes}% нотатки-нагадування у чернетці (вимкнено — не друкуються)
\RequirePackage{pdftexcmds}        % низькорівневі pdfTeX-примітиви (потрібно деяким пакетам)

%===============================================================================
%
%										Математика
%
%===============================================================================
\ifluatex
	% Під LuaLaTeX математичні символи беруться з OpenType math-шрифту
	%	\RequirePackage{lualatex-math}
	\RequirePackage[math-style=TeX,bold-style=TeX]{unicode-math}
	\setmathfont[]{Stix Two Math}
\else
	% Під pdfLaTeX — класичні amsfonts/amssymb
	\RequirePackage{amsfonts}
	\RequirePackage{amssymb}
\fi
% amsmath явно завантажується тут, ДО esint: пакет esint перевизначає \iint/\iiint/...
% і конфліктує ("Command \iint already defined"), якщо amsmath завантажується ПІСЛЯ esint.
% Нижче в розділі "Хімія" підключається mhchem, який сам автоматично тягне за собою
% amsmath — без явного \RequirePackage{amsmath} тут порядок залежав би від цього
% побічного ефекту mhchem і був би крихким.
\RequirePackage{amsmath}
\RequirePackage{esint}     % розширені інтегральні знаки (контурні, поверхневі тощо)
\RequirePackage{nicefrac}  % красиві "діагональні" дроби на кшталт 1/2 в тексті
\let\nfrac\nicefrac
\allowdisplaybreaks        % дозволити перенос довгих формул (\begin{align} тощо) між сторінками

% ------------------------- Визначення математичних команд ---------------------
% Скорочені позначення, специфічні для курсу електродинаміки: ЕРС, вектори полів,
% диференціальні оператори (rot, div, grad) та частинні похідні.
\def\EMF{\mathcal{E}}          % --- ЕРС ---
\newcommand{\vect}[1]{\symbf{#1}} % --- жирний прямий шрифт для векторів ---
\def\Efield{\vect{E}}          % --- Визначення вектора електричного поля            ---
\def\Dfield{\vect{D}}          % --- Визначення електричної індукції                 ---
\def\Bfield{\vect{B}}          % --- Визначення вектора магнітногї індукції          ---
\def\Hfield{\vect{H}}          % --- Визначення вектора напруженості магнітного поля ---
\def\rot{\symbf{\nabla}\times} % --- Визначення ротора                               ---
\def\divg{\symbf{\nabla}\cdot} % --- Визначення дівергенції                          ---
\def\grad{\vect{\nabla}}
\def\diff#1#2{\frac{\partial #1}{\partial #2}}          % \diff{f}{x}  ->  ∂f/∂x
\def\ddiff#1#2{\frac{\partial^2 #1}{\partial #2^2}}     % \ddiff{f}{x} ->  ∂²f/∂x²
\def\parttime#1{\frac{\partial{#1}}{\partial t}}
\def\pparttime#1{\frac{\partial^2{#1}}{\partial t^2}}
\AtBeginDocument{%
	% Ці перевизначення відкладено до \begin{document}, бо \phi/\epsilon
	% ще не завантажені пакетами unicode-math/babel на етапі преамбули класу.
	\let\phi\varphi        % \phi по всьому документу виглядає як "гачкова" φ (varphi)
	\let\epsilon\varepsilon % аналогічно для epsilon
	\DeclareMathOperator{\const}{const}
	\DeclareMathOperator{\Div}{div}
	\DeclareMathOperator{\Rot}{rot}
	\DeclareMathOperator{\Grad}{grad}
	\DeclareMathOperator{\inv}{inv}
	\newcommand{\Laplasian}{\Delta}
}

% \emphx{текст} — виділення терміна малиновим курсивом (означення, важливий термін)
\NewDocumentCommand{\emphx}{m}{\emph{\textcolor{malina}{#1}}}

%===============================================================================
%
%										Хімія
%
%===============================================================================
% Використовується епізодично (напр. для формул речовин у прикладах) — не є
% профільним предметом книги, тому підключено одним рядком без додаткових налаштувань.
\RequirePackage{mhchem, chemfig}

%===============================================================================
%
%							Підписи, таблиці та списки
%
%===============================================================================
% ------------------------------------ Таблиці ---------------------------------
\RequirePackage{tabularray}       % сучасні таблиці (\begin{tblr})
\UseTblrLibrary{booktabs}
\setlength\arrayrulewidth{1pt}
\RequirePackage{booktabs}         % \toprule/\midrule/\bottomrule для класичних tabular
\setlength{\aboverulesep}{0pt}
\setlength{\belowrulesep}{0pt}
\setlength{\extrarowheight}{0.75ex}
\RequirePackage[justification=centering,labelsep=period]{caption}  % "Рис. 1." — крапка, центрування підпису
\usepackage[outercaption, wide]{sidecap}  % підписи збоку від рисунка (в маргіналії)
\sidecaptionvpos{figure}{c}               % вертикальне вирівнювання бічного підпису — по центру
\RequirePackage{subcaption}       % підрисунки (a), (b)... в межах одного figure
\RequirePackage{multirow}         % об'єднання клітинок таблиці по вертикалі

% \tabcaption/\figcaption — вставити підпис типу "Таблиця"/"Рисунок" незалежно від
% поточного плаваючого середовища (корисно всередині figure з таблицею і навпаки)
\def\tabcaption{\def\@captype{table}\caption}
\def\figcaption{\def\@captype{figure}\caption}
\RequirePackage[inline]{enumitem}
\setlist{nosep}   % компактні списки без зайвих вертикальних відступів між пунктами
%\setlist{nolistsep}

% ------------------------------- Відступи в формулах --------------------------
% Стандартні \abovedisplayskip тощо надто великі для щільної верстки конспекту —
% зменшено до 1ex з обох боків формули.
\setlength\abovedisplayskip{1ex}
\setlength\belowdisplayskip{1ex}
\setlength\abovedisplayshortskip{1ex}
\setlength\belowdisplayshortskip{1ex}

% --------------------- Відступ між написом та рисунком ------------------------

\setlength{\textfloatsep}{5pt}   % менший відступ між плаваючим об'єктом і текстом

% --------------------- Підписи до рисунку (розмір тексту) ---------------------

\captionsetup[figure]{font=small,labelfont=small}
\captionsetup[table]{font=small,labelfont=small}

%===============================================================================
%
%									Епіграфи та дрібні пакети
%
%===============================================================================

\RequirePackage{epigraph}                      % епіграф на початку глави
\setlength\epigraphwidth{.8\textwidth}
\setlength\epigraphrule{0pt}                   % без горизонтальної лінії під епіграфом
\renewcommand{\textflush}{flushepinormal}      % текст епіграфа притиснутий ліворуч (не по правому краю)

%===============================================================================
%
%							tcolorbox — базові налаштування
%
%===============================================================================
% Пакет tcolorbox — основа всіх кольорових "врізок" книги (Theory/Attention/задачі/
% відповіді нижче). Тут визначається лише спільний стиль для виділення формул
% (\tcbhighmath з amsmath, автоматично застосовується пакетом до підсвічених формул).
\RequirePackage[most, many]{tcolorbox}

\tcbset{
	highlight math style={
			enhanced jigsaw,
			colframe=themecolormain,
			opacityback=0.1,
			colback=themecolormain!1!white,
			arc=0pt,
			boxrule=1pt,
			boxsep=1pt,
			attach boxed title to top center = {yshift=-\tcboxedtitleheight/2},
			colbacktitle=white,
			coltitle=black,
			fonttitle = \scriptsize,
			boxed title style={
					boxrule=0pt,
					colframe=white,
					colback=white,
					size=fbox,
				},
		},
}

%===============================================================================
%
%							Рисування: TikZ, PGFPlots, CircuiTikz
%
%===============================================================================
% Увесь графічний інструментарій книги зібрано в одному розділі: базові пакети,
% усі \usetikzlibrary одним викликом, шари малювання, а далі — власні tikz/pic-стилі,
% від найпростіших (contact, magarrow) до складних параметричних (parallelepiped).
\RequirePackage{tikz, pgfplots, tikz-3dplot}
\RequirePackage{circuitikz}    % електричні кола (резистори, батареї тощо) для схем
%---------------------------------------------------
%\usetikzlibrary{external}
%\usepgfplotslibrary{external}
%\tikzexternalize[optimize=false, prefix=figures/]
%---------------------------------------------------
% Примітка: свідомо НЕ підключається \usetikzlibrary{circuits.ee.IEC} — ця бібліотека
% конфліктує з елементами circuitikz (перевизначає ключі кола, напр. "R"), тому
% розділ "Електричні кола" нижче лишається закоментованим.
\usetikzlibrary{%
	decorations.text, decorations.markings, decorations.pathmorphing, % текст/розмітка/фрактальні лінії на шляхах
	intersections, backgrounds,                                       % точки перетину ліній; фонові шари
	arrows, arrows.meta,                                              % стрілки (класичні та сучасні)
	shapes, shapes.geometric, shadows, shadows.blur, shadings,        % фігури-вузли, тіні, градієнти
	quotes, angles, tikzmark,                                         % підписи кутів, позначки для \tikzmark
	calc, fit, positioning,                                           % обчислення координат, обгортання, взаємне розміщення вузлів
	patterns,                                                         % штрихування (використовується у стилі "ground")
	spy,                                                               % лупа/збільшений фрагмент рисунка
}
% Обидва фонові шари класу (bg тут і background — для декору tornpage нижче)
% оголошуються і активуються ОДНИМ спільним \pgfsetlayers. Раніше вони
% реєструвались двома окремими викликами \pgfsetlayers у різних місцях файлу;
% другий виклик мовчки перезаписував список шарів і робив 'bg' невідомим —
% будь-яке \begin{pgfonlayer}{bg} в документі падало з помилкою
% "the requested layer 'bg' is not part of the layer list".
\pgfdeclarelayer{bg}          % фоновий шар для звичайних tikz-рисунків
\pgfdeclarelayer{background}  % фоновий шар під "пергаментну" текстуру tornpage (див. розділ "Оформлення блоків")
\pgfsetlayers{bg, background, main}  % порядок малювання: bg -> background -> main (стандартний)
\usepgfplotslibrary{fillbetween}   % заливка області між двома кривими pgfplots/tikz
\pgfplotsset{
	%every tick label/.append style={scale=0.5},
	every axis label/.append style={font=\small},
	compat=newest,
}
\tikzset{every picture/.style={font=\small}}   % єдиний розмір шрифту в усіх tikzpicture

% ------------------------------- Загальні стилі --------------------------------
% partial ellipse={кут1:кут2:радіус} — дуга/сектор еліпса чи кола від кута1 до кута2
\tikzset{
	partial ellipse/.style args={#1:#2:#3}{
			insert path={+ (#1:#3) arc (#1:#2:#3)}
		}
}

% contact — маленька закрашена точка-контакт (кінець провідника, вузол схеми тощо)
\tikzset{contact/.style={circle, fill, inner sep=1.2pt}}

% magarrow — pic-стиль "магнітної стрілки": синій північний і червоний південний
% полюси-трикутники з іменованими координатами (top/north/south/bottom) для прив'язки
\tikzset{
	magarrow/.pic = {
			\fill [blue] (0:1) -- (90:0.2)  -- (270:0.2) -- cycle;
			\fill [red] (-180:1) -- (-270:0.2) -- (-90:0.2) -- cycle;
			\coordinate (-top)     at (90:0.2);
			\coordinate (-north)   at (0:1);
			\coordinate (-south)   at (-180:1);
			\coordinate (-bottom)  at (-270:0.2);
		}
}

% ---------------------------- Паттерни ----------------------------------------
% ground — умовне позначення "землі" на схемах (штрихована ділянка)
\tikzstyle{ground}=[fill,pattern=north east lines,draw=none,minimum width=0.3,minimum height=0.6]

% ------------------------------- Стрілки на лініях -----------------------------
% midarrow/midarrowR — стрілка-маркер посередині лінії (вправо/вліво відповідно) —
% зручно показувати напрямок струму чи руху вздовж контуру
\tikzstyle{midarrow} = [
postaction={ decorate,
		decoration={ markings, mark=at position .5 with {\arrow{>}}}}
]

\tikzstyle{midarrowR} = [
postaction={ decorate,
		decoration={ markings, mark=at position .5 with {\arrow{<}}}}
]

% arrowpos={позиція}{зсув}{довжина} — стрілка в довільній точці шляху з керованим
% зсувом та довжиною наконечника (гнучкіший за midarrow)
\tikzset{
	arrowpos/.style n args={3}{
			decoration={markings,mark=at position #1 with {\arrow[xshift=#2]{Latex[length=#3]}}},
			postaction={decorate}
		}
}

% ------------------------------- Допоміжні pic-стилі ---------------------------
% vertical ticks — ряд коротких вертикальних рисочок уздовж шляху (напр. шкала на осі)
% area/.pic — приклад заштрихованої довільної області між двома парами кривих
% (побудованої через fillbetween за іменованими шляхами name path=A/B/C/D)
\tikzset{
	vertical ticks/.style={
			decoration={markings,
					mark=between positions 0 and 1 step 0.05 with {
							\pgftransformresetnontranslations
							\draw[] (0 ,0) -- ++(0, -0.3);
						}
				},
			postaction={decorate}
		},
	area/.pic={
			\node [] (0) at (-3.75, -1.25) {};
			\node [] (1) at (-1.25, 1.5) {};
			\node [] (2) at (1.5, -2) {};
			\node [] (3) at (4, 0.25) {};
			\draw [bend left=15, name path=A] (0.center) to (1.center);
			\draw [bend left=15, looseness=0.75, name path=C] (1.center) to (3.center);
			\draw [bend right, name path=D] (3.center) to (2.center);
			\draw [bend right=15, name path=B] (2.center) to (0.center);
			\tikzfillbetween[of=A and B]{gray!20};
			\tikzfillbetween[of=C and D]{gray!20};
		}
}

% tangent/use tangent — позначити на позиції #1 уздовж шляху локальну систему
% координат (дотична + нормаль), щоб потім малювати щось "прив'язане" до кривої
% командою [use tangent=<номер точки>]
\tikzset{
	tangent/.style={
			decoration={
					markings,% switch on markings
					mark=
					at position #1
					with
						{
							\coordinate (tangent point-\pgfkeysvalueof{/pgf/decoration/mark info/sequence number}) at (0pt,0pt);
							\coordinate (tangent unit vector-\pgfkeysvalueof{/pgf/decoration/mark info/sequence number}) at (1,0pt);
							\coordinate (tangent orthogonal unit vector-\pgfkeysvalueof{/pgf/decoration/mark info/sequence number}) at (0pt,1);
						}
				},
			postaction=decorate
		},
	use tangent/.style={
			shift=(tangent point-#1),
			x=(tangent unit vector-#1),
			y=(tangent orthogonal unit vector-#1)
		},
	use tangent/.default=1,
	>=latex
}

% pics/parallelepiped — параметричний pic для 3D-паралелепіпеда (розміри a,b,c,
% кути theta/phi проєкції, стиль граней pstyle, окремі кольори граней xy/xz/yz
% через ключі "xy face=...", "xz face=...", "yz face=..." та спільний "all faces=...")
\tikzset{pics/parallelepiped/.style={code={
				\tikzset{parallelepiped/.cd,#1}
				\begin{scope}[x={(\pgfkeysvalueof{/tikz/parallelepiped/a}*1cm,0cm)},
						y={({cos(\pgfkeysvalueof{/tikz/parallelepiped/theta})*\pgfkeysvalueof{/tikz/parallelepiped/b}*1cm},
								{sin(\pgfkeysvalueof{/tikz/parallelepiped/theta})*\pgfkeysvalueof{/tikz/parallelepiped/b}*1cm})},
						z={({cos(\pgfkeysvalueof{/tikz/parallelepiped/phi})*\pgfkeysvalueof{/tikz/parallelepiped/c}*1cm},
								{sin(\pgfkeysvalueof{/tikz/parallelepiped/phi})*\pgfkeysvalueof{/tikz/parallelepiped/c}*1cm})}
						,/tikz/parallelepiped/pstyle,pic actions,
						declare function={mysign(\x)=ifthenelse(\x<0,-1,1);}]
					\path[parallelepiped/fall,parallelepiped/fxz] (0,1,0) -- (1,1,0) -- (1,1,1) -- (0,1,1) -- cycle;
					\path[parallelepiped/fall,parallelepiped/fyz,shift={({0.5-0.5*mysign(cos(\pgfkeysvalueof{/tikz/parallelepiped/phi}))},0,0)}]

					(0,0,0) -- (0,0,1) -- (0,1,1) -- (0,1,0) -- cycle;
					\path[parallelepiped/fall,parallelepiped/fxy,shift={(0,0,{0.5-0.5*mysign(sin(\pgfkeysvalueof{/tikz/parallelepiped/theta}))},0,0)}]

					(0,0,0) -- (1,0,0) -- (1,1,0) -- (0,1,0) -- cycle;
					\path[parallelepiped/fall,parallelepiped/fyz,shift={({0.5+0.5*mysign(cos(\pgfkeysvalueof{/tikz/parallelepiped/phi}))},0,0)}]

					(0,0,0) -- (0,0,1) -- (0,1,1) -- (0,1,0) -- cycle;
					\path[parallelepiped/fall,parallelepiped/fxy,shift={(0,0,{0.5+0.5*mysign(sin(\pgfkeysvalueof{/tikz/parallelepiped/theta}))},0,0)}]

					(0,0,0) -- (1,0,0) -- (1,1,0) -- (0,1,0) -- cycle;
					\path[parallelepiped/fall,parallelepiped/fxz] (0,0,0) -- (1,0,0) -- (1,0,1) -- (0,0,1) -- cycle;
				\end{scope}}},parallelepiped/.cd,a/.initial=4,b/.initial=1.5,c/.initial=2,
theta/.initial=30,phi/.initial=70,pstyle/.style={draw,thick,fill opacity=0.6,
		line join=round},fall/.style={draw},all
faces/.code={\tikzset{parallelepiped/fall/.style={#1}}},
fxy/.style={fill=red},xy face/.code={\tikzset{parallelepiped/fxy/.style={#1}}},
fxz/.style={fill=orange},xz face/.code={\tikzset{parallelepiped/fxz/.style={#1}}},
fyz/.style={fill=cyan},yz face/.code={\tikzset{parallelepiped/fyz/.style={#1}}}
}


% --------------------------- Електричні кола (не використовується) ------------
% Закоментований чорновий стиль на основі рідної tikz-бібліотеки circuits.ee.IEC:
% вимикач/мультиметр/амперметр/вольтметр/гальванометр/джерело змінного струму.
% Свідомо НЕ підключати одночасно з circuitikz (див. коментар вище над
% \usetikzlibrary) — конфлікт ключів кола дає помилку "I do not know the key '/tikz/...'".
%\tikzset{circuit ee IEC,
%	every info/.style=red,
%	semithick,
%	every info/.style={font=\footnotesize},
%	small circuit symbols,
%	circuit declare symbol = ocontact,
%	circuit declare symbol = multimeter,
%	circuit declare symbol = ampermeter,
%	circuit declare symbol = voltmeter,
%	circuit declare symbol = galvanometer,
%	circuit declare symbol = ac source,
%	set ocontact graphic = {draw, fill = white, generic circle IEC, shape=circle, minimum size=1mm},
%	set multimeter graphic = {draw,generic circle IEC, minimum size=5mm},
%	set ampermeter graphic = {draw,generic circle IEC, minimum size=5mm,info=center:A},%
%	set voltmeter graphic = {draw,generic circle IEC, minimum size=5mm,info=center:V},
%	set galvanometer graphic = {draw,generic circle IEC, minimum size=5mm,info=center:G},
%	set ac source graphic = ac source IEC graphic,
%	ac source IEC graphic/.style=
%		{
%			transform shape,
%			circuit symbol lines,
%			circuit symbol size = width 3 height 3,
%			shape=generic circle IEC,
%			/pgf/generic circle IEC/before background=
%				{
%					\pgfpathmoveto{\pgfpoint{-0.575pt}{0pt}}
%					\pgfpathsine{\pgfpoint{0.3pt}{0.3pt}}
%					\pgfpathcosine{\pgfpoint{0.3pt}{-0.3pt}}
%					\pgfpathsine{\pgfpoint{0.3pt}{-0.3pt}}
%					\pgfpathcosine{\pgfpoint{0.3pt}{0.3pt}}
%					\pgfusepathqstroke
%				}
%		}
%}

%===============================================================================
%
%							Інтервали
%
%===============================================================================
\newlength{\@spase}
\setlength{\@spase}{0.5ex} % space between \@sectiontitlemark and \thesection
\newlength{\length@titlemark} % length of \@sectiontitlemark

%===============================================================================
%
%						Налаштування для титульних сторінок
%
%===============================================================================

% alwayssingle — середовище, що гарантує: вміст всередині завжди починається і
% закінчується на окремій одноколонковій сторінці (навіть якщо документ двоколонковий)
\newenvironment{alwayssingle}{%
	\thispagestyle{empty}
	\@restonecolfalse
	\if@twocolumn\@restonecoltrue\onecolumn
	\else\if@openright\cleardoublepage\else\clearpage\fi
	\fi}%
{\if@restonecol\twocolumn
	\else\newpage\thispagestyle{empty}\fi
}

% titlepagestyle — стиль tcolorbox "на всю ширину паперу" (виходить за межі текстового
% блока за допомогою enlarge left/right by) — використовується на титульній сторінці
\tcbset{%
	titlepagestyle/.style={%
			enhanced,
			colback=themecolordark,
			colframe=themecolorlight,
			arc=0pt,
			outer arc=0pt,
			leftrule=0pt,
			rightrule=0pt,
			enlarge left by=-1in-\hoffset-\oddsidemargin,
			enlarge right by=-\paperwidth+1in+\hoffset+\oddsidemargin+\textwidth,
			width=\paperwidth,
			left=1in+\hoffset+\oddsidemargin,
			right=\paperwidth-1in-\hoffset-\oddsidemargin-\textwidth,
		}%
}%

% Перевизначення стандартної \title: додатково зберігає назву книги у \realtitle
% (незалежно від \@title) — для використання, наприклад, у колонтитулах чи PDF-метаданих.
\ExplSyntaxOn
\RenewDocumentCommand{\title}{m}
{
	\tl_gset:cn { @title } { #1 } % needed by \maketitle
	\tl_gset:Nn { \realtitle } { #1 }
	%  \seq_set_split:Nnn \l_tmpa_seq { \\ } { #1 }
	%  \tl_gset:Nx \inlinetitle { \seq_use:Nn \l_tmpa_seq { ~ } }
}
\ExplSyntaxOff

%========================================================================================================
%
%										   Рубрикація
%
%========================================================================================================
% Тут зібрано все, що керує структурою і зовнішнім виглядом розділів книги:
% нумерація частин/глав/секцій, спеціальні режими "Додатки" й "Відповіді",
% та колонтитули (pagestyles) для кожного з цих режимів.

\let\cleardoublepage\clearpage   % без порожніх сторінок при переході на нову главу

% \schapter{Назва} — нумерована як частина книги "непронумерована" глава
% (з'являється у змісті, але без номера глави, напр. "Передмова", "Вступ")
\def\schapter#1{%
	\chapter*{#1}
	\addcontentsline{toc}{chapter}{#1}%
}


% ---------------------------------------- Верстка ДОДАТКІВ ---------------------------------------------
% Перевизначає стандартну \appendix: нумерація секцій літерами (А, Б, В...),
% своя нумерація таблиць/формул у межах секції, окремий колонтитул "appendix".
\renewcommand\appendix{\par
	\appendixtrue
	\gdef\thesection{\@Alph\c@section}
	\@addtoreset{table}{section}
	\renewcommand\thetable%
	{\thesection.\@arabic\c@table}
	\setcounter{chapter}{0}%
	\setcounter{section}{0}%
	\renewcommand{\theequation}{\thesection.\arabic{equation}}
	\clearpage\pagestyle{appendix}
	\def\@sectiontitlemark{\appendixname}
	\if@twocolumn
		\@restonecoltrue\onecolumn
	\else
		\@restonecolfalse
	\fi
	\chapter*{Додатки}%
	\addcontentsline{toc}{chapter}{Додатки}
	\if@restonecol\twocolumn\fi
}
% ---------------------------------------- Верстка ВІДПОВІДЕЙ -------------------------------------------
% \answers — окремий режим (аналогічний за духом до \appendix) для розділу з
% відповідями до задач: своя нумерація секцій/формул, свій колонтитул "answers".
\newcommand\answers{\par
	\answerstrue
	\setcounter{chapter}{0}%
	\setcounter{section}{0}%
	\renewcommand{\thesection}{\arabic{section}}
	\clearpage\pagestyle{answers}
	\chapter*{Відповіді}%
	\addcontentsline{toc}{chapter}{Відповіді}
	\renewcommand{\theequation}{\arabic{equation}}
	\if@restonecol\twocolumn\fi
}
% ---------------------------------------- Лічильник зносок починаються з кожної сторінки ---------------
\@newctr{footnote}[page]   % нумерація виносок починається заново на кожній сторінці



\RequirePackage[pagestyles, explicit]{titlesec}   % оформлення заголовків частин/глав/секцій
\RequirePackage{titletoc}                          % оформлення запису "Частина" у змісті

\newlength\chapnumb
\setlength\chapnumb{4cm}   % ширина колонки під великий номер глави в заголовку

% Заголовок частини (part) — великим шрифтом, з відступом і центруванням
\titleformat{\part}[display]{\bfseries\sffamily\huge}{\partname\ \thepart }{0pt}{\addvspace{1em}\Huge\centering #1}

% Як запис частини виглядає у змісті — з лінійкою над та потовщеним відступом
\titlecontents{part}%
[0pt]{\sffamily\bfseries\large\protect\addvspace{25pt}\addvspace{1.5ex}}
{}{\partname~}
{\hfill\contentspage}%
[\addvspace{0.7ex}\titlerule\addvspace{10pt}]%

\titleclass{\part}{top}          % частина завжди починається "з верху" нової сторінки
\newcommand\partbreak{\clearpage} % ручний розрив перед частиною (за потреби у тексті)

% Заголовок глави: величезний номер глави ліворуч (\chapnumb завширшки), назва
% та горизонтальна лінія праворуч від нього
\titleformat{\chapter}[block]
{\normalfont\sffamily}{}{0pt}
{\parbox[b]{\chapnumb}{%
		\color{themecolordark}\fontsize{100}{90}\selectfont\thechapter}%
	\parbox[b]{\dimexpr\textwidth-\chapnumb\relax}{%
		\raggedleft%
		\hfill{\LARGE#1}\\
		\rule{\dimexpr\textwidth-\chapnumb\relax}{0.4pt}}}

% Той самий вигляд, але без номера — для непронумерованих глав (\chapter*)
\titleformat{name=\chapter,numberless}[block]
{\normalfont\sffamily}{}{0pt}
{\parbox[b]{\chapnumb}{%
		\mbox{}}%
	\parbox[b]{\dimexpr\textwidth-\chapnumb\relax}{%
		\raggedleft%
		\hfill{\LARGE#1}\\
		\rule{\dimexpr\textwidth-\chapnumb\relax}{0.4pt}}}

% Заголовок секції: "N. Назва" жирним
\titleformat{\section}
{\normalsize\bfseries}{\thesection.}{1em}{#1}

% Заголовок підсекції: у підбір з текстом ("runin"), закінчується крапкою
\titleformat{\subsection}[runin]
{\normalsize\bfseries}
{\thesubsection.}
{1em}
{#1}
[.]


% Колонтитули: на парних сторінках — назва глави, на непарних — теж (крім
% спеціальних стилів для Відповідей/Додатків/Бібліографії, де замість назви
% глави друкується фіксований текст). Номер сторінки — завжди знизу по центру.
\newpagestyle{main}{\headrule%
	\sethead{\ifodd\thepage\relax\else\itshape\small\thechapter.\ \chaptertitle\fi}{}{\ifodd\thepage\itshape\small\thechapter.\
			\chaptertitle\else\relax\fi}
	\setfoot{}{\small\thepage}{}}

\newpagestyle{answers}{\headrule%
	\sethead{\ifodd\thepage\relax\else\itshape\small Відповіді\fi}{}{\ifodd\thepage\itshape\small Відповіді\else\relax\fi}
	\setfoot{}{\small\thepage}{}}

\newpagestyle{appendix}{\headrule%
	\sethead{\ifodd\thepage\relax\else\itshape\small Додатки\fi}{}{\ifodd\thepage\itshape\small Додатки\else\relax\fi}
	\setfoot{}{\small\thepage}{}}

\newpagestyle{bibliography}{\headrule%
	\sethead{\ifodd\thepage\relax\else\itshape\small\bibname\fi}{}{\ifodd\thepage\itshape\small\bibname\else\relax\fi}
	\setfoot{}{\small\thepage}{}}

% "plain" (стандартний стиль першої сторінки глави у LaTeX) — тут без колонтитула
% зверху, лише номер сторінки знизу
\renewpagestyle{plain}{%
	\sethead{}{}{}
	\setfoot{}{\small\thepage}{}}

\assignpagestyle{\chapter}{plain}   % перша сторінка кожної глави — стиль "plain"
\assignpagestyle{\part}{empty}      % сторінка частини — взагалі без колонтитулів


%===============================================================================
%
%									Бібліографія
%
%===============================================================================
% ---------------------------- Bibliography spacing ----------------------------
% Зменшений міжабзацний/міжпунктовий інтервал у списку літератури (типовий
% \thebibliography дає забагато "повітря" між джерелами).
\newlength{\bibitemsep}\setlength{\bibitemsep}{.1\baselineskip plus .05\baselineskip minus .05\baselineskip}
\newlength{\bibparskip}\setlength{\bibparskip}{0pt}
\let\oldthebibliography\thebibliography
\renewcommand\thebibliography[1]{%
	\oldthebibliography{#1}%
	\setlength{\parskip}{\bibitemsep}%
	\setlength{\itemsep}{\bibparskip}%
}

% Перемикач: якщо клас підключено з опцією [biblatex] — використовується biblatex
% з держстандартним стилем gost-numeric, інакше — вбудований механізм \bibliography
% LaTeX з українською назвою розділу "Література".
\ifbiblatex
	\RequirePackage[backend=biber, bibstyle=gost-numeric, babel=other, isbn=true, url=false, defernumbers=true]{biblatex}
	% Додає URL джерела як гіперпосилання прямо на назву (якщо url заповнено в .bib)
	\newbibmacro{string+url}[1]{%
		\iffieldundef{url}{#1}{\href{\thefield{url}}{#1}}%
	}
	\DeclareFieldFormat{title}{\usebibmacro{string+url}{#1}}
	\RequirePackage{csquotes}

	\DefineBibliographyStrings{ukrainian}{%
		bibliography = {Література},
	}
	\DeclareBibliographyCategory{Textbooks}   % категорія джерел: підручники
	\DeclareBibliographyCategory{Problems}    % категорія джерел: задачники
\else
	\renewcommand{\@biblabel}[1]{#1.}   % "[1]" -> "1." у списку літератури
	\addto\captionsukrainian{%
		\renewcommand{\bibname}{Література}%
	}
\fi

%===============================================================================
%
%									 HYPERREF
%
%===============================================================================
% Підключається майже наприкінці преамбули (як і рекомендує документація hyperref),
% після titlesec/titletoc/biblatex, щоб коректно перехопити всі потрібні команди.
\RequirePackage[%
	bookmarks = true,
	bookmarksnumbered=true,
	unicode,
	linktocpage = true,
	hypertexnames=false,
	pdftoolbar=true,
	pdfpagelayout=TwoPageRight,
	pdfauthor={Ponomarenko S.M.},
	pdfdisplaydoctitle=true,
	pdfkeywords={Electrostatics, Magnetostatics, Electrodynamics, Current, Field},
	pdfencoding=auto
]%
{hyperref}
\RequirePackage[all]{hypcap}   % посилання на рисунок/таблицю ведуть на верх об'єкта, а не на підпис

% --------------- Патч для україомовної назви розділу для nameref ----------- %
\addto\extrasukrainian{%
	\renewcommand{\chapterautorefname}{}%
}
% --------------------------------------------------------------------------------

% Якщо \inlinetitle визначено (див. закоментовану частину \RenewDocumentCommand{\title}
% вище) — використати його як заголовок PDF-документа замість стандартного \@title
\ifdefined\inlinetitle%
	\AtBeginDocument{\hypersetup{pdftitle={\inlinetitle}}}
\fi

%===============================================================================
%
%							Оформлення блоків (tcolorbox-середовища)
%
%===============================================================================
% Готові кольорові "врізки", якими користуються автори при написанні глав:
%   Theory    — блок теоретичних відомостей з автонумерацією;
%   pict      — рамка навколо окремого рисунка;
%   Attention — жовтий блок-попередження зі знаком оклику;
%   tornpage  — декоративний "пергаментний" фон (сторінка "під старовину").

% Theory — виділений блок теорії; заголовок винесено в окремий "жирний" бокс
% зверху, а параметр #1 (необов'язковий) друкується праворуч від заголовка.
\newtcolorbox[auto counter]{Theory}[1][]{
	breakable,
	enhanced,
	outer arc=0pt,
	arc=0pt,
	colframe=themecolordark,
	colback=themecolordark!20,
	attach boxed title to top left,
	fontupper=\small,
	before upper={\parindent15pt},
	boxed title style={
			colback=themecolordark,
			outer arc=0pt,
			arc=0pt,
			top=3pt,
			bottom=3pt,
		},
	fonttitle=\sffamily,
	colback=white,
	rightrule=0pt,
	%  toprule=0pt,
	before=\nopagebreak,
	title=Теоретичні відомості,
	overlay unbroken and first={
			\path
			let
			\p1=(title.north east),
			\p2=(frame.north east)
			in
			node[anchor=west,font=\sffamily,color=themecolordark,text width=\x2-\x1]
			at (title.east) {#1};
		}
}

% pict — проста тонка рамка з тінню навколо рисунка (без заголовка)
\newtcolorbox{pict}{
	colback=white,
	colframe=gray,
	boxrule=0.1pt,
	left=0pt,
	right=0pt,
	top=0pt,
	bottom=0pt,
	sharp corners,
	halign=center,
	enhanced,drop fuzzy shadow,
	hbox,
}

% Attention — жовта врізка-попередження з "загнутим кутом" знизу-праворуч і
% великим знаком оклику в лівій смузі
\newtcolorbox{Attention}[1][]{
	enhanced,
	breakable,
	before skip=2mm,after skip=3mm,
	before upper={\parindent15pt},
	boxrule=0.4pt,left=5mm,right=2mm,top=1mm,bottom=1mm,
	colback=yellow!10,
	colframe=yellow!50,
	fontupper=\itshape,
	sharp corners,rounded corners=southeast,arc is angular,arc=3mm,
	underlay={%
			\path[fill=tcbcolback!80!black] ([yshift=3mm]interior.south east)--++(-0.4,-0.1)--++(0.1,-0.2);
			\path[draw=tcbcolframe,shorten <=-0.05mm,shorten >=-0.05mm] ([yshift=3mm]interior.south east)--++(-0.4,-0.1)--++(0.1,-0.2);
			\path[fill=themecolordark,draw=none] (interior.south west) rectangle node[text=white]{\Large\bfseries !} ([xshift=4mm]interior.north west);
		},
	drop fuzzy shadow,#1}


% ---- Допоміжна графіка для "пергаментного" боксу tornpage нижче ----
% Шар "background", на якому малюється пергамент, уже оголошено й активовано
% разом із шаром "bg" у розділі "Рисування: TikZ, PGFPlots, CircuiTikz" вище
% (\pgfsetlayers{bg, background, main}) — тут лишається тільки декорація.

% This is the base for the fractal decoration. It takes a random point
% between the start and end, and raises it a random amount, thus
% transforming a segment into two, connected at that raised point This
% decoration can be applied again to each one of the resulting
% segments and so on, in a similar way of a Koch snowflake.
\pgfdeclaredecoration{irregular fractal line}{init}
{
	\state{init}[width=\pgfdecoratedinputsegmentremainingdistance]
	{
		\pgfpathlineto{%
			\pgfpoint{random * \pgfdecoratedinputsegmentremainingdistance}{%
				(random * \pgfdecorationsegmentamplitude - 0.02) *
				\pgfdecoratedinputsegmentremainingdistance}}
		\pgfpathlineto{\pgfpoint{\pgfdecoratedinputsegmentremainingdistance}{0pt}}
	}
}

% Define paper style — текстура старого паперу як заливка (файл ./Icons/OLD_PAPER_TEXTURE)
\tikzset{
	paper/.style={%
			draw=black!10,
			%    blur shadow,
			path picture={%
					\node at (path picture bounding box.center) {
						\includegraphics[width=\linewidth]{./Icons/OLD_PAPER_TEXTURE}
					};
				}
			},
	irregular border/.style={%
			decoration={irregular fractal line, amplitude=0.2},
			decorate,
		},
	ragged border/.style={%
			decoration={random steps, segment length=7mm, amplitude=2mm},
			decorate,
		}
}

% tornpage — бокс з "рваним" нижнім краєм і текстурою старого паперу; #1 —
% додаткові ключі tcolorbox (напр. заголовок), що передаються без змін.
\newtcolorbox{tornpage}[1][]{%
	% enhanced jigsaw, <-- Beware, This rendering engine let the
	%                      frame appear on some PDF viewers
	empty, % Better use this rendering engine to avoid the bug
	parbox=true,
	interior code={%
			\begin{pgfonlayer}{background}  % Draw the shape behind
				\fill[paper] % recursively decorate the bottom border
				decorate[irregular border]{%
						decorate{decorate{decorate{decorate[ragged border]{
														($(interior.south east) - (0, random * 5mm)$) --
														($(interior.south west) - (0, random * 5mm)$)
													}
											}
									}
							}
					}
				-- (interior.north west) -- (interior.north east) -- cycle;
			\end{pgfonlayer}
		},
	sharp corners,
	boxrule=0pt,
	left=5pt,
	right=5pt,
	top=5pt,
	bottom=1em,
	fonttitle=\sffamily\bfseries\LARGE,
	attach boxed title to top center={yshift*=-\tcboxedtitleheight},
	coltitle=black,
	#1
}


%===============================================================================
%
%										Верстка задач
%
%===============================================================================
% Задачі — окреме "теорема-подібне" середовище problem (через ntheorem),
% з автоматичним наскрізним лічильником totalproblems (xassoccnt) і посиланнями
% "задача <-> розв'язання" через \hypertarget/\hyperlink нижче.
%\usepackage[framemethod=tikz]{mdframed}
\RequirePackage{ntheorem}
\RequirePackage{answers}     % механізм "запитання/відповідь", на якому побудовано \Newassociation нижче
\RequirePackage{xassoccnt}   % асоційовані лічильники (totalproblems рахує задачі наскрізно по книзі)
\NewTotalDocumentCounter{totalproblems}

% Стиль заголовка задачі: номер-посилання, що веде на відповідь, якщо вона існує
% (перевіряється через \ifcsname r@solution...), інакше — просто номер без посилання.
\newtheoremstyle{problemstyle}%
{%
	\hypertarget{problem:\@roman{##2}}{}%
	\ifcsname r@solution\@roman{##2}\endcsname
		\item[\theorem@headerfont\hyperlink{solution:\@roman{##2}}{##2\theorem@separator}]
	\else
		\item[\theorem@headerfont##2\theorem@separator]
	\fi
}%
{%
	\hypertarget{problem:\@roman{##2}}{}%
	\ifcsname r@solution\@roman{##2}\endcsname
		\item[\theorem@headerfont\hyperlink{solution:\@roman{##2}}{##2\theorem@separator}] (##3)
	\else
		\item[\theorem@headerfont##2\theorem@separator] (##3)
	\fi
}

\theoremstyle{problemstyle}
\theoremheaderfont{\hspace{1ex}\bfseries}
\theorembodyfont{\normalfont}
\theoremseparator{.}

\newtheorem{problem}{}[chapter]                       % задачі нумеруються в межах глави
\DeclareAssociatedCounters{problem}{totalproblems}    % ...і водночас рахуються наскрізно всією книгою

%\tcbset{
%	answersolutionstyle/.style={
%		enhanced, colback=gray!10,
%%         interior hidden,
%		boxrule=0pt, frame hidden, breakable,
%		before skip=10pt, after skip=10pt,
%		overlay unbroken={\draw[line width=3pt, themecolordark] (frame.south west) -- (frame.north west);},
%		extras first={
%			overlay={\draw[line width=3pt, themecolordark] (frame.south west) -- (frame.north west);}
%		},
%		extras last={
%			overlay={\draw[line width=3pt, themecolordark] (frame.south west) -- (frame.north west);}
%		},
%	},
%}

% Робочий (актуальний) стиль оформлення і задачі, і відповіді — з тим самим
% "загнутим кутом", що й Attention, але зі знаком "?" замість "!"
\tcbset{
	answersolutionstyle/.style={
			enhanced,
			breakable,
			before skip=2mm,after skip=3mm,
			before upper={\parindent15pt},
			boxrule=0.4pt,left=5mm,right=2mm,top=1mm,bottom=1mm,
			colback=gray!5,
			colframe=yellow!50,
			fontupper=\itshape,
			sharp corners,rounded corners=southeast,arc is angular,arc=3mm,
			underlay={%
					\path[fill=tcbcolback!80!black] ([yshift=3mm]interior.south east)--++(-0.4,-0.1)--++(0.1,-0.2);
					\path[draw=tcbcolframe,shorten <=-0.05mm,shorten >=-0.05mm] ([yshift=3mm]interior.south east)--++(-0.4,-0.1)--++(0.1,-0.2);
					\path[fill=themecolordark,draw=none] (interior.south west) rectangle node[text=white]{\large\bfseries ?} ([xshift=4mm]interior.north
					west);
				},
			drop fuzzy shadow
		}
}


\tcolorboxenvironment{problem}{answersolutionstyle}   % застосувати цей стиль до самого середовища problem


%===============================================================================
%
%									Генеррування відповідей до задач
%
%===============================================================================
% answerbox — той самий візуальний стиль, але для тексту відповіді.
% \Newassociation{solution}{Solution}{answer} (з пакета answers) прив'язує
% середовище Solution до problem за номером, щоб відповіді можна було
% зверстати в окремому розділі книги (див. \answers вище), а не одразу під задачею.
\newtcolorbox{answerbox}{answersolutionstyle,halign=left}

\Newassociation{solution}{Solution}{answer}
\renewenvironment{Solution}[1]{%
	\begin{answerbox}
		\hypertarget{solution:\@roman{#1}}{\hyperlink{problem:\@roman{#1}}{\bfseries#1.}\label{solution\@roman{#1}}}
		}{%
	\end{answerbox}
}


%===============================================================================
%
%						Команда вставки задач та відповідей
%
%       https://tex.stackexchange.com/questions/382776/how-to-create-list-and-assign-it-to-variable
%===============================================================================
% \multiinclude{список файлів}[суфікс] — підключити (через \InputIfFileExists,
% тобто мовчки пропустити відсутні) кожен файл зі списку "chapter_list" за шаблоном
% "назва/назва<суфікс>". Використовується, напр., для послідовного підключення
% глав книги без ручного повторення \input для кожної.
\ExplSyntaxOn
% ---------------------- Another good solution ---------------------------------
%\NewDocumentCommand{\multiinclude}{ m O{} }
% {
%  \clist_map_inline:cn {chapter_list_#1_clist} { \InputIfFileExists{##1/##1#2}{}{}\par}
% }

%\NewDocumentCommand{\MakeChapterList}{ m m }
% {
%  \clist_set:cn {chapter_list_#1_clist} { #2 }
% }
% --------------------------------------------------------------------------------
\NewDocumentCommand{\multiinclude}{ m O{} }
{
	\clist_set:Nx \l_Chapters_clist{ #1 }
	\clist_map_inline:Nn \l_Chapters_clist { \InputIfFileExists{##1/##1#2}{}{}\par}
}

\ExplSyntaxOff
%===============================================================================

\endinput