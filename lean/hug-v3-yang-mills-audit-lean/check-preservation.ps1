$ErrorActionPreference = 'Stop'
$package = $PSScriptRoot
$workspace = Split-Path -Parent $package
$baseline = Get-Content -Raw -LiteralPath (Join-Path $package 'preserved-inputs.json') | ConvertFrom-Json -AsHashtable
$checks = @()
foreach ($name in $baseline.files.Keys) {
    $path = Join-Path $package $name
    $source = Join-Path $baseline.source_directory $name
    $hash = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLower()
    $original = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash.ToLower()
    if ($hash -ne $baseline.files[$name] -or $hash -ne $original) { throw "Preserved input changed: $name" }
    $checks += @{file=$name; path=$path; source=$source; sha256=$hash; unchanged=$true}
}
$sealedDirectory = Join-Path $workspace 'hug-v3-source-lean/sources'
$seal = Get-Content -Raw -LiteralPath (Join-Path $sealedDirectory 'source_seal.json') | ConvertFrom-Json -AsHashtable
$roots = @($sealedDirectory, 'C:/Users/ziman/Documents/Codex/2026-10-08/referenced-chatgpt-conversation-this-is-an-2/outputs/hug-structural-memory-v3')
$sourceChecks = @()
foreach ($root in $roots) {
    foreach ($name in $seal.Keys) {
        $path = Join-Path $root $name
        $hash = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLower()
        if ($hash -ne $seal[$name]) { throw "Sealed source changed: $path" }
        $sourceChecks += @{path=$path; sha256=$hash; unchanged=$true}
    }
}
$corpus = Get-Content -Raw -LiteralPath (Join-Path $package 'corpus/corpus-passages.json') | ConvertFrom-Json -AsHashtable
$corpusHash = (Get-FileHash -LiteralPath $corpus.source -Algorithm SHA256).Hash.ToLower()
if ($corpusHash -ne $corpus.source_sha256) { throw 'The corrected corpus changed after passage extraction.' }
$record = [ordered]@{checked_utc=[DateTime]::UtcNow.ToString('o'); read_only=$true; preserved_inputs=$checks; sealed_source_copies=$sourceChecks; corpus=@{path=$corpus.source; sha256=$corpusHash; unchanged=$true}; all_unchanged=$true}
[IO.File]::WriteAllText((Join-Path $package 'source-preservation-check.json'),(($record | ConvertTo-Json -Depth 8)+"`n"),[Text.UTF8Encoding]::new($false))
Write-Output "PASS: $($checks.Count) preserved inputs, $($sourceChecks.Count) sealed source copies, and corrected corpus unchanged."
