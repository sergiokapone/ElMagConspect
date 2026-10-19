# build-html.ps1 - builds the HTML version of the book (lwarp). Put it in the project root.
# Usage:   .\build-html.ps1                 full build
#          .\build-html.ps1 -Placeholder    pictures that cannot be built are replaced by a box
#          .\build-html.ps1 -SkipPrepare    skip macros/pictures preparation (nothing changed there)
#          .\build-html.ps1 -NoImages       skip lwarpmk limages
# On an error the script stops and writes the first LaTeX error with its context to build-error.txt
# (send that file's text). ASCII only on purpose: Windows PowerShell 5 reads files without BOM as ANSI.
param(
    [switch]$Placeholder,
    [switch]$SkipPrepare,
    [switch]$NoImages
)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
$main = 'main-html'

# Prints (and saves to build-error.txt) the first LaTeX error of a log: file being read, error, context.
function Show-FirstError([string]$log) {
    if (-not (Test-Path $log)) { return }
    $lines = Get-Content -LiteralPath $log -Encoding UTF8
    $idx = -1
    for ($i = 0; $i -lt $lines.Count; $i++) { if ($lines[$i].StartsWith('!')) { $idx = $i; break } }
    if ($idx -lt 0) { return }
    $file = ''
    for ($j = $idx; $j -ge 0; $j--) {
        if ($lines[$j] -match '\((\.[\\/][^\s()]*\.(tex|tikz|cls|sty))') { $file = $Matches[1]; break }
    }
    $end = [Math]::Min($idx + 9, $lines.Count - 1)
    $block = @("log: $log", "file being read: $file") + $lines[$idx..$end]
    $block | Set-Content -LiteralPath 'build-error.txt' -Encoding UTF8
    Write-Host ""
    Write-Host "FIRST LaTeX ERROR (also saved to build-error.txt):" -ForegroundColor Red
    $block | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
}

function Step([string]$label, [scriptblock]$cmd, [string]$log = '') {
    Write-Host ""
    Write-Host "==> $label" -ForegroundColor Cyan
    & $cmd
    if ($LASTEXITCODE -ne 0) {
        if ($log) { Show-FirstError $log }
        throw "$label failed (exit code $LASTEXITCODE)"
    }
}

# --- checks ------------------------------------------------------------------
$py = $null
foreach ($c in 'py', 'python') { if (Get-Command $c -ErrorAction SilentlyContinue) { $py = $c; break } }
$missing = @()
if (-not $py) { $missing += 'python (or py)' }
foreach ($t in 'lualatex', 'lwarpmk', 'biber', 'pdfcrop', 'pdftocairo') {
    if (-not (Get-Command $t -ErrorAction SilentlyContinue)) { $missing += $t }
}
if (-not (Get-Command gnuplot -ErrorAction SilentlyContinue)) {
    Write-Host "Warning: gnuplot not found in PATH (needed by 2 pictures in FieldInMetalls)." -ForegroundColor Yellow
}
if ($missing.Count -gt 0) { throw "Not found in PATH: $($missing -join ', ')" }
foreach ($f in "$main.tex", 'ConspectBookHTML.cls', 'mathjax-macros.tex', 'mathjax2lwarp.py', 'prepare_html.py') {
    if (-not (Test-Path $f)) { throw "File not found: $f" }
}
Remove-Item -ErrorAction SilentlyContinue build-error.txt
$sw = [Diagnostics.Stopwatch]::StartNew()

# --- 1. preparation ------------------------------------------------------------
if (-not $SkipPrepare) {
    Step 'MathJax macros -> lwarp-mathjax.tex' { & $py mathjax2lwarp.py mathjax-macros.tex lwarp-mathjax.tex }
    $prepArgs = @('prepare_html.py')
    if ($Placeholder) { $prepArgs += '--placeholder' }
    Step 'PDF pictures -> SVG, fixed copies of tikz files' { & $py @prepArgs }
}

# --- 2. compilation ------------------------------------------------------------
# lwarp records --shell-escape in lwarpmk.conf only if THIS first pass runs with it (needed for 'plot gnuplot').
# Old config files are removed so that they are recreated with the right command.
Remove-Item -ErrorAction SilentlyContinue lwarpmk.conf, "$main.lwarpmkconf"
Step "lualatex -shell-escape $main (print pass)" {
    lualatex -shell-escape -interaction=nonstopmode -halt-on-error $main
} "$main.log"
Step "biber $main" { biber $main }
# lwarpmk does not notice changes of the class or of included files: force the rebuild.
Step 'lwarpmk again' { lwarpmk again -p $main }
Step 'lwarpmk html (long: several passes)' { lwarpmk html -p $main } "${main}_html.log"

# --- 3. problems in the HTML pass ----------------------------------------------
$log = "${main}_html.log"
if (Test-Path $log) {
    $errs = Select-String -Path $log -Pattern '^!' | Select-Object -First 1
    if ($errs) { Show-FirstError $log }
    $undef = (Select-String -Path $log -Pattern 'Reference .* undefined|Citation .* undefined').Count
    if ($undef -gt 0) { Write-Host "Undefined references/citations in the log: $undef" -ForegroundColor Yellow }
}

# --- 4. images -------------------------------------------------------------------
if (-not $NoImages) {
    Step 'lwarpmk limages' { lwarpmk limages -p $main }
    Write-Host "Images are finished in the background; wait a minute before opening the pages." -ForegroundColor Yellow
}

$sw.Stop()
Write-Host ""
Write-Host ("Done in {0:mm\:ss}. Open {1}.html in a browser (internet is needed for MathJax)." -f $sw.Elapsed, $main) -ForegroundColor Green
