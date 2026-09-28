<#
.SYNOPSIS
    Перейменовує main.pdf -> ElMagConspect.pdf

.NOTES
    Запуск:
    pwsh -File rename-pdf.ps1
#>

param(
    [string]$Folder = $PSScriptRoot
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null

$src = Join-Path $Folder "main.pdf"
$dst = Join-Path $Folder "ElMagConspect.pdf"

if (-not (Test-Path $src)) {
    Write-Host "Не знайдено: $src" -ForegroundColor Red
    exit 1
}

if (Test-Path $dst) {
    Remove-Item $dst -Force
}

Move-Item -Path $src -Destination $dst -Force

Write-Host "OK: main.pdf -> ElMagConspect.pdf" -ForegroundColor Green