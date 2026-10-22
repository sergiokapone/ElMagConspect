<#
.SYNOPSIS
    Перейменовує main.pdf -> ElMagConspect.pdf, лінеаризує та переміщує в docs.

.NOTES
    Запуск:
    pwsh -File rename_main.ps1

    Потрібен qpdf у PATH:
    winget install qpdf
#>

param(
    [string]$Folder = $PSScriptRoot,
    [string]$DocsSubfolder = "docs"
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

$src    = Join-Path $Folder "main.pdf"
$dst    = Join-Path $Folder "ElMagConspect.pdf"
$docs   = Join-Path $Folder $DocsSubfolder
$final  = Join-Path $docs "ElMagConspect.pdf"

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
# Прапорець --warning-exit-0 змушує qpdf повертати код 0, якщо були лише попередження (warnings)
& qpdf --warning-exit-0 --linearize --newline-before-endstream $src $dst

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

# --- 7. Переміщення в папку docs ---
if (-not (Test-Path $docs)) {
    New-Item -ItemType Directory -Path $docs | Out-Null
}

if (Test-Path $final) {
    Remove-Item $final -Force
}

Move-Item -Path $dst -Destination $final -Force

if (-not (Test-Path $final)) {
    Write-Host "Не вдалося перемістити файл у $docs" -ForegroundColor Red
    exit 1
}

$size = (Get-Item $final).Length
Write-Host ("OK: main.pdf -> {0} (лінеаризовано, {1:N0} байт)" -f $final, $size) -ForegroundColor Green