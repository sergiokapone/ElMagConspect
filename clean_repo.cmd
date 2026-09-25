@echo off
chcp 65001 > nul
echo ====================================================================
echo  Очищення історії Git для https://github.com/sergiokapone/ElMagConspect
echo ====================================================================
echo.

:: Назва файлу для видалення
set "TARGET_FILE=ElMagConspect.pdf"

echo [1/4] Видалення файлу "%TARGET_FILE%" з усієї історії...
git filter-repo --invert-paths --path "%TARGET_FILE%" --force
if %errorlevel% neq 0 (
    echo.
    echo [ПОМИЛКА] Помилка виконання git filter-repo.
    echo Перевірте, чи встановлено утиліту: pip install git-filter-repo
    pause
    exit /b %errorlevel%
)

echo.
echo [2/4] Відновлення прив'язки до GitHub (remote origin)...
git remote remove origin >nul 2>&1
git remote add origin https://github.com/sergiokapone/ElMagConspect.git

echo.
echo [3/4] Примусове оновлення гілки main на GitHub...
git push origin main --force -u
if %errorlevel% neq 0 (
    echo.
    echo [ПОМИЛКА] Не вдалося відправити зміни на GitHub.
    pause
    exit /b %errorlevel%
)

echo.
echo [4/4] Оновлення тегів на GitHub...
git push origin --force --tags

echo.
echo ====================================================================
echo  Успішно! Файл "%TARGET_FILE%" видалено з локальної історії та GitHub.
echo ====================================================================
pause
