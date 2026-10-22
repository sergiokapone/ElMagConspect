@echo off
chcp 65001 > nul
setlocal
cd /d "%~dp0"

set "TARGET_FILE=ElMagConspect.pdf"
set "LIST=purge-paths.txt"
set "REMOTE=https://github.com/sergiokapone/ElMagConspect.git"
set "BRANCH=main"

echo ====================================================================
echo  Очищення історії Git для https://github.com/sergiokapone/ElMagConspect
echo ====================================================================
echo.

:: 0. Перевірки
if not exist "%LIST%" goto :no_list
git rev-parse --is-inside-work-tree >nul 2>&1
if errorlevel 1 goto :no_repo
git filter-repo --version >nul 2>&1
if errorlevel 1 goto :no_filter_repo
set "DIRTY="
for /f "delims=" %%i in ('git status --porcelain --untracked-files=no') do set "DIRTY=1"
if defined DIRTY goto :dirty

echo Зі ВСІЄЇ історії та з поточного коміту буде видалено такі шляхи з %LIST%:
echo.
type "%LIST%"
echo.
echo Потім гілку %BRANCH% і теги буде примусово перезаписано на GitHub.
echo Для всіх, хто вже склонував репозиторій, історія зміниться незворотно.
echo.
set "ANS="
set /p "ANS=Продовжити? Введіть YES великими літерами: "
if not "%ANS%"=="YES" goto :cancel

echo.
echo [1/5] Резервна копія всього репозиторію (git bundle) поруч із проєктом...
for /f %%t in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd-HHmmss"') do set "TS=%%t"
set "BUNDLE=%~dp0..\ElMagConspect-backup-%TS%.bundle"
git bundle create "%BUNDLE%" --all
if errorlevel 1 goto :fail
echo       %BUNDLE%

echo.
echo [2/5] Копія %TARGET_FILE% (filter-repo видалить його і з диска)...
set "KEEP=%TEMP%\%TARGET_FILE%.keep"
if exist "%KEEP%" del "%KEEP%"
if exist "%TARGET_FILE%" copy /y "%TARGET_FILE%" "%KEEP%" >nul

echo.
echo [3/5] Видалення шляхів зі списку з усієї історії...
git filter-repo --invert-paths --paths-from-file "%LIST%" --force
if errorlevel 1 goto :fail_filter
if exist "%KEEP%" move /y "%KEEP%" "%TARGET_FILE%" >nul

echo.
echo [4/5] Відновлення прив'язки до GitHub (remote origin)...
git remote remove origin >nul 2>&1
git remote add origin %REMOTE%

echo.
echo [5/5] Примусове оновлення гілки %BRANCH% і тегів на GitHub...
git push origin %BRANCH% --force -u
if errorlevel 1 goto :fail_push
git push origin --force --tags

echo.
echo ====================================================================
echo  Успішно! Шляхи зі списку %LIST% видалено з локальної історії та GitHub.
echo  Резервна копія: %BUNDLE%
echo ====================================================================
pause
exit /b 0

:no_list
echo [ПОМИЛКА] Немає файлу %LIST% поруч зі скриптом.
goto :fail
:no_repo
echo [ПОМИЛКА] Це не репозиторій Git.
goto :fail
:no_filter_repo
echo [ПОМИЛКА] Не знайдено git filter-repo. Встановіть: pip install git-filter-repo
goto :fail
:dirty
echo [ПОМИЛКА] Є незакомічені зміни у відстежуваних файлах. filter-repo відкотить їх.
echo Спершу закомітьте їх: git add -A  і  git commit -m "..."
goto :fail
:cancel
echo Скасовано.
pause
exit /b 1
:fail_filter
echo [ПОМИЛКА] git filter-repo не виконався. Резервна копія: %BUNDLE%
if exist "%KEEP%" copy /y "%KEEP%" "%TARGET_FILE%" >nul
goto :fail
:fail_push
echo [ПОМИЛКА] Не вдалося відправити зміни на GitHub. Історію локально вже переписано.
echo Резервна копія: %BUNDLE%
goto :fail
:fail
echo.
pause
exit /b 1
