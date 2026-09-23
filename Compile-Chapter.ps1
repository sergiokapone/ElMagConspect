<#
.SYNOPSIS
    Компіляція одного розділу книги (LuaLaTeX) через jobname-трюк,
    без зміни % !TeX root у самих файлах розділів.

.DESCRIPTION
    Показує список тек поруч зі скриптом, які одночасно є назвами
    розділів (тека Foo вважається розділом, якщо всередині неї є
    Foo.tex — саме так у вас влаштовано: SteadyEfield/SteadyEfield.tex,
    ElEnergy/ElEnergy.tex тощо, аналогічно вашому \includechapter з
    test.tex).

    Компілює обраний розділ через _Single.tex з підміненим \jobname,
    тож PDF виходить під назвою розділу, а .tex файл розділу
    залишається повністю незайманим.

.PARAMETER Chapter
    Назва розділу (без .tex). Якщо не задано — запитає інтерактивно.

.PARAMETER Bib
    Прогнати biber після першого проходу lualatex (якщо в розділі є цитати).

.PARAMETER Open
    Відкрити PDF після успішної компіляції.

.EXAMPLE
    .\Compile-Chapter.ps1
    .\Compile-Chapter.ps1 -Chapter SteadyEfield -Open
    .\Compile-Chapter.ps1 -Chapter ElEnergy -Bib -Open
#>

param(
    [string]$Chapter,
    [switch]$Bib,
    [switch]$Open
)

$Root      = $PSScriptRoot
$SingleTex = Join-Path $Root '_Single.tex'

function Get-ChapterList {
    # Розділ = тека <Name>, всередині якої лежить <Name>.tex
    # (наприклад SteadyEfield/SteadyEfield.tex). Це автоматично
    # відсіює службові теки (Additions, Icons, logo, .archive, ...),
    # бо в них немає файлу з таким самим іменем, як тека.
    Get-ChildItem -Path $Root -Directory |
        Where-Object {
            -not $_.Name.StartsWith('.') -and
            (Test-Path (Join-Path $_.FullName "$($_.Name).tex"))
        } |
        Sort-Object Name |
        Select-Object -ExpandProperty Name
}

if (-not (Test-Path $SingleTex)) {
    Write-Error "Не знайдено $SingleTex поруч зі скриптом."
    exit 1
}

if (-not $Chapter) {
    $chapters = @(Get-ChapterList)
    if ($chapters.Count -eq 0) {
        Write-Error "Не знайдено жодної теки-розділу (тека + однойменний .tex) поруч зі скриптом."
        exit 1
    }

    Write-Host "`nДоступні розділи:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $chapters.Count; $i++) {
        '{0,3}) {1}' -f ($i + 1), $chapters[$i] | Write-Host
    }

    do {
        $sel = Read-Host "`nНомер розділу (або впиши назву напряму)"
        if ($sel -match '^\d+$' -and [int]$sel -ge 1 -and [int]$sel -le $chapters.Count) {
            $Chapter = $chapters[[int]$sel - 1]
        }
        elseif ($chapters -contains $sel) {
            $Chapter = $sel
        }
        else {
            Write-Warning "Не розпізнано '$sel'. Спробуй ще раз."
        }
    } while (-not $Chapter)
}

Write-Host "`n>> Компілюю розділ: $Chapter`n" -ForegroundColor Green

Push-Location $Root
try {
    & lualatex -synctex=1 -interaction=nonstopmode -jobname=""$Chapter"" $SingleTex
    if ($LASTEXITCODE -ne 0) {
        throw "lualatex завершився з помилкою (код $LASTEXITCODE). Дивись $Chapter.log"
    }

    if ($Bib) {
        & biber $Chapter
        & lualatex -synctex=1 -interaction=batchmode -jobname=$Chapter $SingleTex Out-Null
    }

    Write-Host "`n>> Готово: $Chapter.pdf`n" -ForegroundColor Green

    if ($Open) {
        Start-Process (Join-Path $Root "$Chapter.pdf")
    }
}
finally {
    Pop-Location
}
