<#
.SYNOPSIS
    Перейменовує main.pdf -> ElMagConspect.pdf та лінеаризує результат.

.NOTES
    Запуск:
    pwsh -File rename_main.ps1

    Потрібен qpdf у PATH:
    winget install qpdf
#>

param(
    [string]$Folder = $PSScriptRoot
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

$src = Join-Path $Folder "main.pdf"
$dst = Join-Path $Folder "ElMagConspect.pdf"

# --- 1. Перевірка наявності qpdf ---
$qpdf = Get-Command qpdf -ErrorAction SilentlyContinue
if (-not $qpdf) {
    Write-Host "qpdf не знайдено в PATH. Встановіть: winget install qpdf" -ForegroundColor Red
    exit 1
}

# --- 2. Перевірка вхідного файлу ---
if (-not (Test-Path $src)) {
    Write-Host "Не знайдено: $src" -ForegroundColor Red
    exit 1
}

# --- 3. Видалення старого цільового файлу ---
if (Test-Path $dst) {
    Remove-Item $dst -Force
}

# --- 4. Лінеаризація напряму в цільовий файл ---
# qpdf --linearize src dst: читає main.pdf, пише вже лінеаризований ElMagConspect.pdf
& qpdf --linearize --newline-before-endstream $src $dst

if ($LASTEXITCODE -ne 0) {
    Write-Host "qpdf завершився з помилкою (код $LASTEXITCODE)." -ForegroundColor Red
    exit $LASTEXITCODE
}

# --- 5. Видалення вихідного main.pdf ---
Remove-Item $src -Force

# --- 6. Перевірка результату ---
if (-not (Test-Path $dst)) {
    Write-Host "Після лінеаризації не створено $dst" -ForegroundColor Red
    exit 1
}

$size = (Get-Item $dst).Length
Write-Host ("OK: main.pdf -> ElMagConspect.pdf (лінеаризовано, {0:N0} байт)" -f $size) -ForegroundColor Green