# clwarp-clean.ps1 - removes from the project root everything that the HTML build (lwarp) has left behind.
# Run it from anywhere: it works in the folder where it lies.
# Not touched: sources, the print PDF and the docs folder (the published book with its site files).
# Also removes the local junk of the print build (main.aux ..., *.bak*, aux/log of pictures in chapter folders),
# _chapters, _lint and __pycache__ (step 4). The print PDF and *-Answers.tex are kept.
#   .\clwarp-clean.ps1

Set-Location -LiteralPath $PSScriptRoot
$main = 'main-html'

Write-Host "Cleaning what lwarp has generated in the project..." -ForegroundColor Cyan

# 1. Generated folders (_html also holds the cache of compiled pictures: the next build recompiles them)
foreach ($folder in @("$main-images", '_html', 'lateximages')) {
    if (Test-Path -LiteralPath $folder) {
        Remove-Item -LiteralPath $folder -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "  [folder removed] $folder" -ForegroundColor Yellow
    }
}

# 2. Files in the project root (names are matched with -like)
$masks = @(
    # lwarp itself: lwarpmk.conf, lwarp_*.css, lwarp-mathjax.tex, lwarp-tikzdefs.tex, lwarp_one_limage.cmd ...
    'lwarp*', '*.lwarpmkconf', '*_html.tex', '*.cut', '*.sidetoc', '*-images.txt', 'sitemap.xml', 'sample_project.css',
    # temporary files of the HTML build and its report
    "$main*.aux", "$main*.log", "$main*.out", "$main*.toc", "$main*.lof", "$main*.lot",
    "$main*.bcf", "$main*.blg", "$main*.run.xml", "$main*.bbl", "$main*.ind", "$main*.ilg", "$main*.idx",
    "$main*.pdf", 'build-error.txt',
    # pages that were not moved to docs (an interrupted build or -NoPublish)
    "$main*.html", 'ch*.html'
)
$removed = 0
foreach ($f in Get-ChildItem -LiteralPath . -File) {
    $hit = $false
    foreach ($m in $masks) { if ($f.Name -like $m) { $hit = $true; break } }
    if (-not $hit) { continue }
    Remove-Item -LiteralPath $f.FullName -Force -ErrorAction SilentlyContinue
    if (-not (Test-Path -LiteralPath $f.FullName)) { $removed++ }
}

# 3. SVG pictures made from PDF pictures (prepare_html.py -> lwarpmk pdftosvg): Pictures/x.pdf -> Pictures/x.svg.
#    They are normally moved to docs by the publish step; this removes the ones that are still lying there.
$svgs = 0
foreach ($pdf in Get-ChildItem -Path '*/Pictures/*.pdf' -File) {
    $svg = [IO.Path]::ChangeExtension($pdf.FullName, '.svg')
    if (Test-Path -LiteralPath $svg) {
        Remove-Item -LiteralPath $svg -Force -ErrorAction SilentlyContinue
        if (-not (Test-Path -LiteralPath $svg)) { $svgs++ }
    }
}

# 4. Local junk of the print build and of the helper scripts (all git-ignored; the print PDF and *-Answers.tex stay)
foreach ($folder in @('_chapters', '_lint')) {
    if (Test-Path -LiteralPath $folder) {
        Remove-Item -LiteralPath $folder -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "  [folder removed] $folder" -ForegroundColor Yellow
    }
}
$pycache = 0
foreach ($d in Get-ChildItem -Path . -Directory -Recurse -Filter '__pycache__' -Force -ErrorAction SilentlyContinue |
         Where-Object { $_.FullName -notmatch '[\\/]node_modules[\\/]' }) {
    Remove-Item -LiteralPath $d.FullName -Recurse -Force -ErrorAction SilentlyContinue
    $pycache++
}
# aux files of the print build (root: main.*, but not main.tex / main.pdf) and of single pictures in chapter folders
$rootMasks = @('main.aux', 'main.log', 'main.out', 'main.toc', 'main.lof', 'main.lot', 'main.bcf*', 'main.blg', 'main.run.xml',
               'main.bbl', 'main.ind', 'main.ilg', 'main.idx', 'main.fls', 'main.fdb_latexmk', 'main.thm', 'main.synctex.gz',
               'main.curve.*', 'main.xdv', 'main2.tex', '*.bak*')
$junk = 0
foreach ($f in Get-ChildItem -LiteralPath . -File) {
    foreach ($m in $rootMasks) {
        if ($f.Name -like $m) { Remove-Item -LiteralPath $f.FullName -Force -ErrorAction SilentlyContinue; $junk++; break }
    }
}
$subMasks = @('*.aux', '*.log', '*.out', '*.thm', '*.synctex.gz', '*.bak*', '*.plot.table')
foreach ($f in Get-ChildItem -Path . -File -Recurse -Force -ErrorAction SilentlyContinue |
         Where-Object { $_.DirectoryName -ne $PSScriptRoot -and $_.FullName -notmatch '[\\/](node_modules|docs|\.git|\.garbage|\.archive|review)[\\/]' }) {
    foreach ($m in $subMasks) {
        if ($f.Name -like $m) { Remove-Item -LiteralPath $f.FullName -Force -ErrorAction SilentlyContinue; $junk++; break }
    }
}

Write-Host "Done. Files removed: $removed, SVG pictures made from PDF: $svgs, print-build junk: $junk, __pycache__: $pycache" -ForegroundColor Green
