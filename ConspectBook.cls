\NeedsTeXFormat{LaTeX2e}[1994/06/01]
\ProvidesClass{ConspectBook}[2024/12/21]
\LoadClass[onecolumn, twoside]{book}
%\LoadClass[]{tufte-book}

%===============================================================================
%
%										Налаштування опцій класу
%
%===============================================================================
\newif\ifelectronic
\newif\ifbiblatex
\newif\ifmarginversioninfo

\DeclareOption{print}{
	\PassOptionsToPackage{colorlinks=false}{hyperref}
	\PassOptionsToPackage{pdfsubject={Version for Printing}}{hyperref}
	\electronicfalse
}

\DeclareOption{electronic}{\def\defcolor{\RequirePackage[usenames,dvipsnames,svgnames,table]{xcolor}\definecolor{malina}{rgb}{0.6,0.0,0.0}}
	\PassOptionsToPackage{linkcolor=malina}{hyperref}
	\PassOptionsToPackage{colorlinks=true}{hyperref}
	\PassOptionsToPackage{urlcolor=blue}{hyperref}
	\PassOptionsToPackage{citecolor=green!60!black}{hyperref}
	\PassOptionsToPackage{pdfsubject={Electronic Version}}{hyperref}
	\electronictrue
}

\DeclareOption{marginversioninfo}{%
	\marginversioninfotrue
}

\DeclareOption{biblatex}{
	\biblatextrue
}

\ExecuteOptions{electronic}
\ProcessOptions\relax
\defcolor{}

%===============================================================================
%
%							Геометрія сторінки
%
%===============================================================================
\newlength{\topspace}
\setlength{\topspace}{2cm}
\RequirePackage[%
	a4paper,%
	footskip=1cm,%
	headsep=0.3cm,%
	top=\topspace, %поле сверху
	bottom=2cm, %поле снизу
	left=2cm, %поле ліворуч
	right=2cm, %поле праворуч
]{geometry}
%\usepackage[lmargin=8cm,rmargin=1cm,marginparwidth=6cm,marginparsep=2em]{geometry}


%===============================================================================
%
%							Налаштування мови та компіляторів
%
%===============================================================================

\RequirePackage[fontsize=14pt]{fontsize}
\RequirePackage{iftex}


\ifluatex
	\RequirePackage{fontspec}
%    \RequirePackage[sfdefault,regular]{roboto}
	\setmainfont{BookmanOldStyle}%{alegreya}%{CMU Serif}
	\setsansfont{Roboto}%{Arial}
	\setmonofont{JetBrains Mono}%{Consolas}
	\defaultfontfeatures{Ligatures={TeX}}
	\newfontfamily\Annabelle{Annabelle}
    \newfontfamily\Alexander{Alexander}
	\RequirePackage{luacolor}
\else
	\RequirePackage[T2A,T1]{fontenc}
	\RequirePackage[utf8]{inputenc}
	\input{glyphtounicode}
	\pdfgentounicode=1
	%\RequirePackage{pscyr}
	\RequirePackage{cmap}
	\renewcommand{\sfdefault}{fos}
	\renewcommand{\bfdefault}{b}
\fi
\RequirePackage[english,russian,ukrainian]{babel}

%===============================================================================
%
%										Логічні змінні
%
%===============================================================================

\newif\ifappendix
\newif\ifanswers
\newif\iftoc
\newif\ifbibliography
\newif\ifintro

%===============================================================================
%
%							Налаштування типографських вимог
%
%===============================================================================

\RequirePackage{microtype}
%\RequirePackage[nosingleletter, hyphenation, lastparline]{impnattypo}
%\usepackage[defaultlines=4,all]{nowidow}
%\clubpenalty =1000
%\widowpenalty=1000
%\setlength{\parskip}{0.5ex}%
\setlength{\parindent}{2em}%
%\renewcommand{\baselinestretch}{1.1}
\def\@textbottom{\vskip \z@ \@plus 1pt}
\let\@texttop\relax
%\setlength{\emergencystretch}{1em}


%===============================================================================
%
%										Кольори
%
%===============================================================================

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

%===============================================================================
%
%										Пакети
%
%===============================================================================

\RequirePackage[overload]{textcase}
\let\MakeUppercase\MakeTextUppercase

\RequirePackage{indentfirst}
% ------------------------------------ Плаваючі об'єкти ------------------------
%\RequirePackage{subfig}
%\renewcommand\thesubfigure{\alph{subfigure}}
\RequirePackage{wrapfig}
% ------------------------------------ Таблиці ---------------------------------
\RequirePackage{tabularray}
\setlength\arrayrulewidth{1pt}
% ------------------------------------ Математика ------------------------------
\ifluatex
%	\RequirePackage{lualatex-math}
	\RequirePackage[math-style=TeX,bold-style=TeX]{unicode-math}
	\setmathfont[]{Stix Two Math}
\else
	\RequirePackage{amsfonts}
	\RequirePackage{amssymb}
\fi
\RequirePackage{esint}
\RequirePackage{nicefrac}
\let\nfrac\nicefrac
\allowdisplaybreaks
% ------------------------- Визначення математичних команд ---------------------
\def\EMF{\mathcal{E}}
\newcommand{\vect}[1]{\symbf{#1}}
\def\Efield{\vect{E}}          % --- Визначення вектора електричного поля            ---
\def\Dfield{\vect{D}}          % --- Визначення електричної індукції                 ---
\def\Bfield{\vect{B}}          % --- Визначення вектора магнітногї індукції          ---
\def\Hfield{\vect{H}}          % --- Визначення вектора напруженості магнітного поля ---
\def\rot{\symbf{\nabla}\times} % --- Визначення ротора                               ---
\def\divg{\symbf{\nabla}\cdot} % --- Визначення дівергенції                          ---
\AtBeginDocument{%
	\let\phi\varphi
	\let\epsilon\varepsilon
	\DeclareMathOperator{\const}{const}
	\DeclareMathOperator{\Div}{div}
	\DeclareMathOperator{\Rot}{rot}
    \DeclareMathOperator{\Grad}{grad}
	\DeclareMathOperator{\inv}{inv}
	\newcommand{\Laplasian}{\Delta}
}

\NewDocumentCommand{\emphx}{m}{\emph{\textcolor{malina}{#1}}}

\RequirePackage{mhchem, chemfig}
% ------------------------- Таблиці --------------------------------------------
\newcommand{\localinput}[1]{\input{\currfilebase/tikz/#1}}
\RequirePackage{booktabs}
\setlength{\aboverulesep}{0pt}
\setlength{\belowrulesep}{0pt}
\setlength{\extrarowheight}{0.75ex}
\RequirePackage[justification=centering,labelsep=period]{caption}
\usepackage[outercaption, wide]{sidecap}
\sidecaptionvpos{figure}{c}
\RequirePackage{subcaption}
\RequirePackage{multirow}
% ---------------------------- Фалові операції ---------------------------------
\RequirePackage{currfile}
% ---------------------------- Пакети LaTeX3 -----------------------------------
% --------------------------------------------------------------------------------
\RequirePackage{epigraph}
\setlength\epigraphwidth{.8\textwidth}
\setlength\epigraphrule{0pt}
\renewcommand{\textflush}{flushepinormal}
\RequirePackage{lastpage}
\RequirePackage[disable]{todonotes}
\RequirePackage{pdftexcmds}
\RequirePackage[most, many]{tcolorbox}

%===============================================================================
%
%										Рисування
%
%===============================================================================

\RequirePackage{tikz, pgfplots, tikz-3dplot}
%---------------------------------------------------
%\usetikzlibrary{external}
%\usepgfplotslibrary{external}
%\tikzexternalize[optimize=false, prefix=figures/]
%---------------------------------------------------
\usetikzlibrary{decorations.text, decorations.markings}
\usetikzlibrary{intersections}
\usetikzlibrary{arrows.meta}
\usetikzlibrary{shapes, shadows}
\usetikzlibrary{quotes,angles,tikzmark}
\pgfdeclarelayer{bg}    % declare background layer
\pgfsetlayers{bg,main}  % set the order of the layers (main is the standard layer)
\usetikzlibrary{shapes.geometric,calc}
\usepgfplotslibrary{fillbetween}
\pgfplotsset{
	%every tick label/.append style={scale=0.5},
	every axis label/.append style={font=\small},
	compat=newest,
}
\tikzset{every picture/.style={font=\small}}
\tikzset{
	partial ellipse/.style args={#1:#2:#3}{
			insert path={+ (#1:#3) arc (#1:#2:#3)}
		}
}
% --------------------------- Електричні кола ----------------------------------
\usetikzlibrary{circuits.ee.IEC}
\tikzset{circuit ee IEC,
	every info/.style=red,
	semithick,
	every info/.style={font=\footnotesize},
	small circuit symbols,
	circuit declare symbol = ocontact,
	circuit declare symbol = multimeter,
	circuit declare symbol = ampermeter,
	circuit declare symbol = voltmeter,
	circuit declare symbol = galvanometer,
	circuit declare symbol = ac source,
	set ocontact graphic = {draw, fill = white, generic circle IEC, shape=circle, minimum size=1mm},
	set multimeter graphic = {draw,generic circle IEC, minimum size=5mm},
	set ampermeter graphic = {draw,generic circle IEC, minimum size=5mm,info=center:A},%
	set voltmeter graphic = {draw,generic circle IEC, minimum size=5mm,info=center:V},
	set galvanometer graphic = {draw,generic circle IEC, minimum size=5mm,info=center:G},
	set ac source graphic = ac source IEC graphic,
	ac source IEC graphic/.style=
		{
			transform shape,
			circuit symbol lines,
			circuit symbol size = width 3 height 3,
			shape=generic circle IEC,
			/pgf/generic circle IEC/before background=
				{
					\pgfpathmoveto{\pgfpoint{-0.575pt}{0pt}}
					\pgfpathsine{\pgfpoint{0.3pt}{0.3pt}}
					\pgfpathcosine{\pgfpoint{0.3pt}{-0.3pt}}
					\pgfpathsine{\pgfpoint{0.3pt}{-0.3pt}}
					\pgfpathcosine{\pgfpoint{0.3pt}{0.3pt}}
					\pgfusepathqstroke
				}
		}
}

% ---------------------------- Паттерни ----------------------------------------
\usetikzlibrary{patterns}
\tikzstyle{ground}=[fill,pattern=north east lines,draw=none,minimum width=0.3,minimum height=0.6]


\tikzstyle{midarrow} = [
postaction={ decorate,
		decoration={ markings, mark=at position .5 with {\arrow{>}}}}
]



\tikzstyle{midarrowR} = [
postaction={ decorate,
		decoration={ markings, mark=at position .5 with {\arrow{<}}}}
]



\tikzset{
	arrowpos/.style n args={3}{
			decoration={markings,mark=at position #1 with {\arrow[xshift=#2]{Latex[length=#3]}}},
			postaction={decorate}
		}
}

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

\newenvironment{alwayssingle}{%
	\thispagestyle{empty}
	\@restonecolfalse
	\if@twocolumn\@restonecoltrue\onecolumn
	\else\if@openright\cleardoublepage\else\clearpage\fi
	\fi}%
{\if@restonecol\twocolumn
	\else\newpage\thispagestyle{empty}\fi
}

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

\ExplSyntaxOn
\RenewDocumentCommand{\title}{m}
 {
  \tl_gset:cn { @title } { #1 } % needed by \maketitle
  \tl_gset:Nn { \realtitle } { #1 }
%  \seq_set_split:Nnn \l_tmpa_seq { \\ } { #1 }
%  \tl_gset:Nx \inlinetitle { \seq_use:Nn \l_tmpa_seq { ~ } }
 }
\ExplSyntaxOff


%===============================================================================
%
%								Рубрикація
%
%===============================================================================
\let\cleardoublepage\clearpage
\def\@sectiontitlemark{\S}
\newcommand{\@secnum@dot}{.}
\newcommand{\@chapnum@dot}{.}
% ----------------------------- Верстка ДОДАТКІВ -------------------------------

\renewcommand\appendix{\par
	\appendixtrue
	\gdef\thesection{\@Alph\c@section}
	\@addtoreset{table}{section}
	\renewcommand\thetable%
	{\thesection.\@arabic\c@table}
	\setcounter{chapter}{0}%
	\setcounter{section}{0}%
	\renewcommand{\theequation}{\thesection.\arabic{equation}}
	\clearpage\pagestyle{main}
	\def\@sectiontitlemark{\appendixname}
	\if@twocolumn
		\@restonecoltrue\onecolumn
	\else
		\@restonecolfalse
	\fi
	\chapter*{Додатки}%
	\if@restonecol\twocolumn\fi
}
% ------------------------------- Верстка ВІДПОВІДЕЙ ---------------------------
\newcommand\answers{\par
	\answerstrue
	\setcounter{chapter}{0}%
	\setcounter{section}{0}%
	\renewcommand{\thesection}{\arabic{section}}
	\def\@sectiontitlemark{Відповіді до розділу}
	\if@twocolumn
		\@restonecoltrue\onecolumn
	\else
		\@restonecolfalse
	\fi
	\chapter*{Відповіді}%
	\if@restonecol\twocolumn\fi
}
% ------------------ Лічильник зносок починаються з кожної сторінки ------------
\@newctr{footnote}[page]
% ------------------------ Верстка ЗМІСТУ---------------------------------------
\renewcommand\tableofcontents{%
	\if@twocolumn
		\@restonecoltrue\onecolumn
	\else
		\@restonecolfalse
	\fi
	\toctrue
	\chapter*{\contentsname
%		\@mkboth{%
%			\MakeUppercase\contentsname}{\MakeUppercase\contentsname}%
	}\hypertarget{tocpage}{}%
	\@starttoc{toc}%
	\if@restonecol\twocolumn\fi
	\tocfalse
}
% ---------------------- Верстка ЗМІСТУ для Розділів ------------------------

\renewcommand*\l@chapter[2]{%
	\ifnum \c@tocdepth >\m@ne
		\addpenalty{-\@highpenalty}%
		\vskip 1.0em \@plus\p@
		\setlength\@tempdima{1.5em}%
		\begingroup
		\parindent \z@ \rightskip \@pnumwidth
		\parfillskip -\@pnumwidth
		\leavevmode \bfseries
		\advance\leftskip\@tempdima
		\hskip -\leftskip
		#1\leaders\hbox to .5em{\hss.\hss}\hfil \nobreak\hb@xt@\@pnumwidth{\hss  #2}\par
		\penalty\@highpenalty%
		\endgroup
	\fi}

% ----------------------- Верстка РОЗДІЛУ -------------------------------------
\renewcommand\chapter{\if@openright\cleardoublepage\else\clearpage\fi
  \thispagestyle{chapterpage}%
  \global\@topnum\z@
  \@afterindentfalse
  \secdef\@chapter\@schapter}

\def\@chapter[#1]#2{\ifnum \c@secnumdepth >\m@ne%     #1 -- скорочена назва розділу, #2 -- повна назва розділу
		\if@mainmatter
			\refstepcounter{chapter}%                         При виклику команди \chapter змінювати лічильник на одиницю
			\addcontentsline{toc}{chapter}%
			{\@chapapp~\protect\numberline{\thechapter\@chapnum@dot~}#1}% Додати в зміст "Друк Розділ 1. Назва розділу", #1 -- аргумент команди \chapter"
		\else
			\addcontentsline{toc}{chapter}{#1}%
		\fi
	\else
		\addcontentsline{toc}{chapter}{#1}%
	\fi
	\chaptermark{#1}%                                 Додати "Назву розділу" для колонтитулів
	\addtocontents{lot}{\protect\addvspace{10\p@}}%
	\if@twocolumn
		\@topnewpage[\@makechapterhead{#2}]%
	\else
		\@makechapterhead{#2}%                            Створити вигляд розділу
		\@afterheading
	\fi}

\def\@schapter#1{%                                    Аналогічно до команди \@chapter, але для версії з зірочкою
	\if@twocolumn
		\@topnewpage[\@makeschapterhead{#1}]%
	\else
		\@makeschapterhead{#1}%
		\@afterheading
	\fi
	\chaptermark{#1}%
	\iftoc\relax\else
		\addcontentsline{toc}{chapter}{#1}
	\fi
}

\tcbset{%
		chaptertitlestyle/.style={%
				enhanced,
				colback=white,
				%boxrule=0.25cm,
				colframe=themecolorlight,
				arc=0pt,
				outer arc=0pt,
				leftrule=0pt,
				rightrule=0pt,
				fontupper=\sffamily\bfseries\LARGE,
				enlarge left by=-1in-\hoffset-\oddsidemargin,
				enlarge right by=-\paperwidth+1in+\hoffset+\oddsidemargin+\textwidth,
				width=\paperwidth,
				left=1in+\hoffset+\oddsidemargin,
				right=\paperwidth-1in-\hoffset-\oddsidemargin-\textwidth,
				top=0.7cm,
				bottom=0.7cm,
				halign = center,
				frame hidden,
		}%
}%

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

\def\@makechapterhead#1{%
	\vspace*{50\p@}%
		\begin{tcolorbox}[%
				chaptertitlestyle,
				overlay={%
						\draw[line width = 0.15cm, themecolorlight] (frame.north west) -- (frame.north east);
						\draw[line width = 0.15cm, themecolorlight] (frame.south west) -- (frame.south east);
						\node[%
							fill=themecolordark,
							draw=themecolorlight,
							line width=0.15cm,
							inner sep=0pt,
							text width=2cm,
							minimum height=2cm,
							align=center,
							anchor=east,
							font=\color{white}\sffamily\bfseries\fontsize{40}{52}\selectfont
						]%
						(chapname)
						at (frame.north east)
						{\thechapter};
						\node[font=\small,anchor=south,inner sep=2pt] at (chapname.north)
						{\MakeTextUppercase{\sffamily\bfseries\@chapapp}};
					}
			]%
			#1%
		\end{tcolorbox}%
		\nobreak%
		\vskip 50\p@%
	}%

\def\@makeschapterhead#1{%
	\vspace*{50\p@}%
		\begin{tcolorbox}[chaptertitlestyle,
				overlay={%
						\draw[line width = 0.15cm, themecolorlight] (frame.south west) -- (frame.south east);
						\draw[line width = 0.15cm, themecolorlight] (frame.north west) -- (frame.north east);
					}]
			#1
		\end{tcolorbox}%
		\nobreak%
		\vskip 50\p@%
	}%

% ----------------------- Верстка ЗМІСТУ для Секцій ----------------------------
\newlength\@sectoctitle@len                                                           % Ширина мітки разом з номером для секції
\newlength\@chaptoclabel@len\settowidth\@chaptoclabel@len{\@chapapp}                  % Ширина мітки для розділу
\newlength\@sectiontitlemark@box\settowidth\@sectiontitlemark@box{\@sectiontitlemark} % Ширина мітки для секції
\advance\@chaptoclabel@len by -\@sectiontitlemark@box
\renewcommand*\l@section{\@dottedtocline{2}{\@chaptoclabel@len}{\@sectoctitle@len}}
% -------------------- Верстка ЗМІСТУ для Підсекцій ---------------------------

\newlength{\thesubsection@len}\settowidth{\thesubsection@len}{\thesubsection}
\renewcommand*\l@subsection{\@dottedtocline{2}{7.2em}{\thesubsection@len}}

% -------------------------- Верстка СЕКЦІЇ-------------------------------------
\renewcommand\section{\global\@topnum\z@
  \@afterindentfalse
  \secdef\@section\@ssection}
\def\@section[#1]#2{\refstepcounter{section}%
	\def\@sectoclabel@format{\@sectiontitlemark\hspace\@spase\thesection\@secnum@dot\space}
	\settowidth{\@tempdimb}{\@sectoclabel@format}
	\ifdim\@tempdimb=\@sectoctitle@len
		\relax
	\else
		\setlength\@sectoctitle@len{\@tempdimb}
		\addtocontents{toc}{\setlength\@sectoctitle@len{\the\@tempdimb}}
	\fi
	\addcontentsline{toc}{section}{\protect\numberline{\@sectoclabel@format}#1}%
	\sectionmark{#1}%
	\addtocontents{lof}{\protect\addvspace{10\p@}}%
	\addtocontents{lot}{\protect\addvspace{10\p@}}%
	\@makesectionhead{#2}%
	\@afterheading
}
\def\@makesectionhead#1{%
	\settowidth{\length@titlemark}{\@sectiontitlemark\hspace\@spase\thesection\@secnum@dot}
	\vspace*{10\p@}%
	{\parindent \z@ \raggedright%
	%\normalfont\sffamily\normalsize\bfseries
		\begin{tikzpicture}[overlay,every node/.style={signal, draw, text=white, signal to=nowhere}]
		  \node[baseline,themecolordark,fill, signal to=east, inner sep=0.25em, drop shadow,
		    text=white,font=\bfseries\normalfont,anchor=west,
		    xshift=-2cm, yshift=1ex]
		    at (0,0) {\color{white}\@sectiontitlemark\hspace\@spase\thesection\@secnum@dot};
		\end{tikzpicture}%
		\bfseries\sffamily\normalsize\hspace*{\dimexpr\length@titlemark-1cm\relax}\parbox{\dimexpr\linewidth-1cm\relax}{#1}%
		\par\nopagebreak
		%\vskip-1.75ex{\hskip-2cm\color{gray!60}\rule{\textwidth + 2cm}{2pt}}\nobreak
		\vskip 10\p@\nopagebreak
	}}
\def\@ssection#1{\refstepcounter{section}%
	\if@twocolumn
		\@topnewpage[\@makessectionhead{#1}]%
	\else
		\@makessectionhead{#1}%
		\@afterheading
		%\addcontentsline{toc}{section}{#1}% % 21/12/2017
		\sectionmark{#1}%
	\fi}
\def\@makessectionhead#1{%
	\vspace*{10\p@}%
	{\parindent \z@ \raggedright
		\normalfont
		\interlinepenalty\@M
		\sffamily\large\bfseries  #1\par\nopagebreak
		\vskip 10\p@
	}}
% -------------------------- Верстка ПІДСЕКЦІЇ----------------------------------

\renewcommand\subsection{\@startsection{subsection}{2}{\z@}%
	{-3.25ex\@plus -1ex \@minus -.2ex}%
	{1.5ex \@plus .2ex}%
	{\normalfont\normalsize\bfseries}}

%===============================================================================
%
%										Колонтитули
%
%===============================================================================

% ------------------------- Колонтитули для РОЗДІЛУ ----------------------------
\def\ps@chapterpage{%
	\renewcommand{\@oddhead}%
	{
	}% конец макроопределения

	\renewcommand{\@evenhead}%
	{
	}%

	\renewcommand{\@oddfoot}%
	{\raisebox{0pt}[\headheight][0pt]{%
			\vbox{\hbox to\textwidth{\strut
					\small{\hfil\small\hyperlink{tocpage}{\thepage}}\hfil}}}% конец блока
	}%

	\renewcommand{\@evenfoot}%
	{\raisebox{0pt}[\headheight][0pt]{%
			\vbox{\hbox to\textwidth{\strut
					\small{\hfil{\small\hyperlink{tocpage}{\thepage}}\hfil}}}}% конец блока
	}% ия
}

% ----------------------- Колонтитули для основних сторінок --------------------

\def\ps@main{%
\def\chaptermark##1{                       % ##1 - містить значення, яке сюди вкладують команди \@chapter та \@schapter
\markboth {%
	\ifnum \c@secnumdepth >\m@ne
		\if@mainmatter%
			\ifappendix\relax      % Якщо сторінка додатків то друкувати "Додатки"
			\else
				\iftoc\relax                    % Якщо сторінка змісту то друкувати "Зміст"
				\else
					\ifanswers\relax             % Якщо сторінка з відповідями, друкувати "Відповіді"
					\else
						\protect\hyperlink{\@currentHref}{\@chapapp\ \thechapter\@chapnum@dot} \ % Якщо стрінка з задачими, друкувати "Розділ 1." (тут \@chapapp=Розділ)
					\fi
				\fi
			\fi
		\fi
	\fi
	##1}{%
		\iftoc\contentsname\fi%
		\ifintro##1\fi%
		}%
}%
\def\sectionmark##1{%
\markright {%
	\ifnum \c@secnumdepth >\z@
		\ifbibliography\bibname
			\else%
			\protect\hyperlink{\@currentHref}{\@sectiontitlemark~\thesection\@secnum@dot}\ ##1%\@sectiontitlemark = \S (для Розділів), інші значення встановлюються командами \appendix та \answers
		\fi
	\fi
	}}

\renewcommand{\@oddhead}%
{\raisebox{0pt}[\headheight][0pt]{% начало блока
		\vbox{\hbox to\textwidth{\strut
				\small{\hfil\small\leftmark\hfil}}\hrule}}% конец блока
}% конец макроопределения

\renewcommand{\@evenhead}%
{\raisebox{0pt}[\headheight][0pt]{% начало блока
		\vbox{\hbox to\textwidth{\strut
				\small{\hfil{\small\rightmark}\hfil}}\hrule}}% конец блока
}% конец макроопределения

\renewcommand{\@oddfoot}%
{\raisebox{0pt}[\headheight][0pt]{% начало блока
		\vbox{\hbox to\textwidth{\strut
				\small{\hfil\small\hyperlink{tocpage}{\thepage}}\hfil}}}% конец блока
}% конец макроопределения

\renewcommand{\@evenfoot}%
{\raisebox{0pt}[\headheight][0pt]{% начало блока
		\vbox{\hbox to\textwidth{\strut
				\small{\hfil{\small\hyperlink{tocpage}{\thepage}}\hfil}}}}% конец блока
}% конец макроопределения
}

%===============================================================================
%
%							Підписи під таблицями, рисунками та списки
%
%===============================================================================

\def\tabcaption{\def\@captype{table}\caption}
\def\figcaption{\def\@captype{figure}\caption}
\RequirePackage[inline]{enumitem}
\setlist{nosep}
%\setlist{nolistsep}


% ------------------------------- Відступи в формулах --------------------------

\setlength\abovedisplayskip{1ex}
\setlength\belowdisplayskip{1ex}
\setlength\abovedisplayshortskip{1ex}
\setlength\belowdisplayshortskip{1ex}

% --------------------- Відступ між написом та рисунком ------------------------

\setlength{\textfloatsep}{5pt}

% --------------------- Підписи до рисунку (розмір тексту) ---------------------

\captionsetup[figure]{font=small,labelfont=small}
\captionsetup[table]{font=small,labelfont=small}

% ---------------------------- Bibliography spacing ----------------------------
\newlength{\bibitemsep}\setlength{\bibitemsep}{.1\baselineskip plus .05\baselineskip minus .05\baselineskip}
\newlength{\bibparskip}\setlength{\bibparskip}{0pt}
\let\oldthebibliography\thebibliography
\renewcommand\thebibliography[1]{%
	\oldthebibliography{#1}%
	\setlength{\parskip}{\bibitemsep}%
	\setlength{\itemsep}{\bibparskip}%
}

%===============================================================================
%
%									 HYPERREF
%
%===============================================================================

\RequirePackage[%
	bookmarks = true,
	bookmarksnumbered=true,
	unicode,
	linktocpage = true,
	hypertexnames=false,
	pdftoolbar=false,
	pdfpagelayout=TwoPageRight,
	pdfauthor={Ponomarenko S.M.},
	pdfdisplaydoctitle=true,
	pdfkeywords={Electrostatics, Magnetostatics, Electrodynamics, Current, Field},
	pdfencoding=auto
]%
{hyperref}
\RequirePackage[all]{hypcap}

% --------------- Патч для україомовної назви розділу для nameref ----------- %
\addto\extrasukrainian{%
	\renewcommand{\chapterautorefname}{}%
}
% --------------------------------------------------------------------------------

\ifdefined\inlinetitle%
\AtBeginDocument{\hypersetup{pdftitle={\inlinetitle}}}
\fi

%===============================================================================
%
%							Налаштування бібліографії
%
%===============================================================================

\ifbiblatex
  \RequirePackage[backend=biber, bibstyle=gost-numeric, babel=other, isbn=true, url=false, defernumbers=true]{biblatex}
  \newbibmacro{string+url}[1]{%
  	\iffieldundef{url}{#1}{\href{\thefield{url}}{#1}}%
  }
  \DeclareFieldFormat{title}{\usebibmacro{string+url}{#1}}
  \RequirePackage{csquotes}

  \DefineBibliographyStrings{ukrainian}{%
  	bibliography = {Література},
  }
  \DeclareBibliographyCategory{Textbooks}
  \DeclareBibliographyCategory{Problems}
\else
    \renewcommand{\@biblabel}[1]{#1.}
    \addto\captionsukrainian{%
    \renewcommand{\bibname}{Література}%
    }
\fi

%===============================================================================
%
%								Верстка теоретичних відомостей
%
%===============================================================================



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

\newtcolorbox{Attention}[1][]{enhanced,
  breakable,
  before skip=2mm,after skip=3mm,
  before upper={\parindent15pt},
  boxrule=0.4pt,left=5mm,right=2mm,top=1mm,bottom=1mm,
  colback=yellow!10,
  colframe=yellow!50,
  fontupper=\sffamily,
  sharp corners,rounded corners=southeast,arc is angular,arc=3mm,
  underlay={%
    \path[fill=tcbcolback!80!black] ([yshift=3mm]interior.south east)--++(-0.4,-0.1)--++(0.1,-0.2);
    \path[draw=tcbcolframe,shorten <=-0.05mm,shorten >=-0.05mm] ([yshift=3mm]interior.south east)--++(-0.4,-0.1)--++(0.1,-0.2);
    \path[fill=themecolordark,draw=none] (interior.south west) rectangle node[text=white]{\Large\bfseries !} ([xshift=4mm]interior.north west);
    },
  drop fuzzy shadow,#1}





% Define a background layer, in which the parchment shape is drawn
\pgfdeclarelayer{background}
\pgfsetlayers{background,main}

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

% Define paper style
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
%\usepackage[framemethod=tikz]{mdframed}
\RequirePackage{ntheorem}
\RequirePackage{answers}
\RequirePackage{xassoccnt}
\NewTotalDocumentCounter{totalproblems}

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

\newtheorem{problem}{}[chapter]
\DeclareAssociatedCounters{problem}{totalproblems}

\tcbset{
		answersolutionstyle/.style={
			enhanced jigsaw,colframe=cyan,interior hidden, boxrule=0pt, frame hidden,
				breakable,before skip=10pt,after skip=10pt,
				overlay unbroken = {\draw[line width=1pt, themecolorlight, rounded corners] (frame.south west) rectangle (frame.north east);},
				extras first={
		        overlay={%
			            \draw[line width=1pt, themecolorlight, rounded corners] (frame.south west) -- (frame.north west) -- (frame.north east) --(frame.south east);
						},
				},
				extras last={
		        overlay={%
			            \draw[line width=1pt, themecolorlight, rounded corners] (frame.north west) -- (frame.south west) -- (frame.south east) --(frame.north east);
						},
				},
			},
}

\tcolorboxenvironment{problem}{answersolutionstyle}


%===============================================================================
%
%										Генеррування відповідей до задач
%
%===============================================================================

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