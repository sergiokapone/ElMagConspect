@echo off
:: Удаление папок
if exist _html rmdir /s /q _html
if exist _minted* rmdir /s /q _minted*
if exist main-html-images rmdir /s /q main-html-images

:: Удаление вспомогательных файлов
del *.aux 2>nul
del *.synctex.gz 2>nul
del *.synctex(busy) 2>nul
del *.log 2>nul
del *.run.xml 2>nul
del *.bak* 2>nul
del *.bcf 2>nul
del *.bbl 2>nul
del *.blg 2>nul
del *.nav 2>nul
del *.toc 2>nul
del *.thm 2>nul
del *.snm 2>nul
del *.out 2>nul
del *.fls 2>nul
del *.fdb_latexmk 2>nul
del test.pdf 2>nul
del *.curve.table 2>nul
del *.curve.gnuplot 2>nul
del *.vrb 2>nul
del *.tmp 2>nul
del *.cut 2>nul
del lwarp* 2>nul
del sample_project.css 2>nul
del *.sidetoc 2>nul
del *.lwarpmkconf 2>nul
del main-html_html.tex 2>nul
del main-html-images.txt 2>nul

:: Удаление всех .html в корне, кроме index.html и google*.html
powershell -Command "Get-ChildItem *.html | Where-Object { $_.Name -ne 'index.html' -and $_.Name -notlike 'google*.html' } | Remove-Item"

