# purge-docs-blobs.ps1 - for clean_repo.cmd: writes the ids of OLD versions of the files in docs/ (the published site,
# rebuilt and committed again and again) to a file for  git filter-repo --strip-blobs-with-ids.
# Never listed:
#   - any file of the current commit, whatever its path (the current state stays exactly as it is);
#   - any version that was ever at a path outside docs/ (the pictures in docs/ are byte copies of */Pictures/*:
#     their old versions stay in the history of the sources).
# ASCII only on purpose: Windows PowerShell 5 reads files without BOM as ANSI.
#   powershell -NoProfile -ExecutionPolicy Bypass -File purge-docs-blobs.ps1 [-Out purge-blobs.txt]
param([string]$Out = 'purge-blobs.txt')
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot

$keep = @{}
foreach ($l in (git ls-tree -r HEAD)) {                       # "<mode> blob <id>\t<path>"
    $f = $l -split '\s+'
    if ($f[1] -eq 'blob') { $keep[$f[2]] = $true }
}
# every (version, path) pair that ever entered the history: one line per changed file of every commit
# ":<old mode> <new mode> <old id> <new id> <status>\t<path>"
$docs = @{}
foreach ($l in (git -c core.quotepath=off log --all --root -m --raw --no-renames --no-abbrev --format=)) {
    if (-not $l.StartsWith(':')) { continue }
    $t = $l.IndexOf("`t"); if ($t -lt 0) { continue }
    $f = $l.Substring(0, $t) -split ' '
    $id = $f[3]; $path = $l.Substring($t + 1)
    if ($id -match '^0+$' -or $f[1] -eq '160000') { continue }   # deleted file / submodule
    if ($path.StartsWith('docs/')) { $docs[$id] = $true } else { $keep[$id] = $true }
}
$ids = @($docs.Keys | Where-Object { -not $keep.ContainsKey($_) } | Sort-Object)

# sizes for the report (not piped into git: PowerShell 5 would put a BOM before the first id)
$want = @{}; foreach ($id in $ids) { $want[$id] = $true }
$bytes = 0
foreach ($l in (git cat-file --batch-all-objects --batch-check='%(objectname) %(objectsize:disk)')) {
    $f = $l -split ' '
    if ($want.ContainsKey($f[0])) { $bytes += [long]$f[1] }
}
[IO.File]::WriteAllLines((Join-Path $PSScriptRoot $Out), [string[]]$ids)
Write-Host ("Old versions of files in docs/: {0} ({1:N1} MB in the repository) -> {2}" -f $ids.Count, ($bytes / 1MB), $Out)
