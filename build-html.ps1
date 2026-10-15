# build-html.ps1 - builds the HTML version of the book (lwarp). Put it in the project root.
# Usage:   .\build-html.ps1              full build
#          .\build-html.ps1 -Again       after editing chapters/class: lwarpmk again, then rebuild
#          .\build-html.ps1 -SkipPrepare skip macros/pictures preparation (nothing changed there)
#          .\build-html.ps1 -NoImages    skip lwarpmk limages
# ASCII only on purpose: Windows PowerShell 5 reads files without BOM as ANSI.
param(
    [switch]$Again,
    [switch]$SkipPrepare,
    [switch]$NoImages
)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
$main = 'main-html'

function Step([string]$label, [scriptblock]$cmd) {
    Write-Host ""
    Write-Host "==> $label" -ForegroundColor Cyan
    & $cmd
    if ($LASTEXITCODE -ne 0) { throw "$label failed (exit code $LASTEXITCODE)" }
}

# --- checks ------------------------------------------------------------------
$py = $null
foreach ($c in 'py', 'python') { if (Get-Command $c -ErrorAction SilentlyContinue) { $py = $c; break } }
$missing = @()
if (-not $py) { $missing += 'python (or py)' }
foreach ($t in 'lualatex', 'lwarpmk', 'biber', 'pdfcrop') {
    if (-not (Get-Command $t -ErrorAction SilentlyContinue)) { $missing += $t }
}
if ($missing.Count -gt 0) { throw "Not found in PATH: $($missing -join ', ')" }
foreach ($f in "$main.tex", 'ConspectBookHTML.cls', 'mathjax-macros.tex', 'mathjax2lwarp.py', 'prepare_html.py') {
    if (-not (Test-Path $f)) { throw "File not found: $f" }
}

$sw = [Diagnostics.Stopwatch]::StartNew()

# --- 1. preparation ------------------------------------------------------------
if (-not $SkipPrepare) {
    Step 'MathJax macros -> lwarp-mathjax.tex' { & $py mathjax2lwarp.py mathjax-macros.tex lwarp-mathjax.tex }
    Step 'PDF pictures -> SVG, fixed copies of tikz files' { & $py prepare_html.py }
}

# --- 2. compilation ------------------------------------------------------------
if ($Again) { Step 'lwarpmk again' { lwarpmk again -p $main } }
Step "lualatex $main (print pass, creates lwarp support files)" { lualatex -interaction=nonstopmode $main }
Step "biber $main" { biber $main }
Step 'lwarpmk html (long: several passes)' { lwarpmk html -p $main }

# --- 3. look for LaTeX errors in the HTML pass ---------------------------------
$log = "${main}_html.log"
if (Test-Path $log) {
    $errs = Select-String -Path $log -Pattern '^!' | Select-Object -First 10
    if ($errs) {
        Write-Host ""
        Write-Host "LaTeX errors in $log (first 10):" -ForegroundColor Yellow
        $errs | ForEach-Object { Write-Host "  $($_.Line)" -ForegroundColor Yellow }
    }
    $undef = (Select-String -Path $log -Pattern 'Reference .* undefined|Citation .* undefined').Count
    if ($undef -gt 0) { Write-Host "Undefined references/citations in the last pass: $undef" -ForegroundColor Yellow }
}

# --- 4. images -------------------------------------------------------------------
if (-not $NoImages) {
    Step 'lwarpmk limages' { lwarpmk limages -p $main }
    Write-Host "Images are finished in the background; wait a minute before opening the pages." -ForegroundColor Yellow
}

$sw.Stop()
Write-Host ""
Write-Host ("Done in {0:mm\:ss}. Open {1}.html in a browser (internet is needed for MathJax)." -f $sw.Elapsed, $main) -ForegroundColor Green
