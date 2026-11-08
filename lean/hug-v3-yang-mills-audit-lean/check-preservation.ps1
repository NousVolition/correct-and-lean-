param(
    [string]$CorpusFile = $env:HUG_CORPUS_FILE,
    [string]$ArchiveRoot = $env:HUG_SOURCE_ARCHIVE,
    [string]$OutputFile
)
$ErrorActionPreference = 'Stop'
$package = $PSScriptRoot
$repo = Split-Path -Parent (Split-Path -Parent $package)
$baseline = Get-Content -Raw -LiteralPath (Join-Path $package 'preserved-inputs.json') | ConvertFrom-Json -AsHashtable
$checks = foreach ($name in $baseline.files.Keys) {
    $path = Join-Path $package $name
    $source = Join-Path (Join-Path $repo $baseline.source_directory) $name
    $hash = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLower()
    $original = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash.ToLower()
    if ($hash -ne $baseline.files[$name] -or $hash -ne $original) { throw "Preserved input changed: $name" }
    @{file=$name; source="$($baseline.source_directory)/$name"; sha256=$hash; unchanged=$true}
}
$sealedDirectory = Join-Path $repo 'lean/hug-v3-source-lean/sources'
$seal = Get-Content -Raw -LiteralPath (Join-Path $sealedDirectory 'source_seal.json') | ConvertFrom-Json -AsHashtable
$roots = [ordered]@{published=$sealedDirectory}
if ($ArchiveRoot) { $roots['external_archive'] = $ArchiveRoot }
$sourceChecks = foreach ($label in $roots.Keys) {
    foreach ($name in $seal.Keys) {
        $hash = (Get-FileHash -LiteralPath (Join-Path $roots[$label] $name) -Algorithm SHA256).Hash.ToLower()
        if ($hash -ne $seal[$name]) { throw "Sealed source changed: $label/$name" }
        @{copy=$label; file=$name; sha256=$hash; unchanged=$true}
    }
}
if (-not $CorpusFile) { throw 'Set HUG_CORPUS_FILE or pass -CorpusFile to check the external corrected corpus.' }
$corpus = Get-Content -Raw -LiteralPath (Join-Path $package 'corpus/corpus-passages.json') | ConvertFrom-Json -AsHashtable
$corpusHash = (Get-FileHash -LiteralPath $CorpusFile -Algorithm SHA256).Hash.ToLower()
if ($corpusHash -ne $corpus.source_sha256) { throw 'The corrected corpus changed after passage extraction.' }
$record = [ordered]@{checked_utc=[DateTime]::UtcNow.ToString('o'); preserved_inputs=$checks; sealed_source_copies=$sourceChecks; corpus=@{sha256=$corpusHash; unchanged=$true}; all_checked_match=$true}
$json = $record | ConvertTo-Json -Depth 8
if ($OutputFile) { [IO.File]::WriteAllText($OutputFile, $json + [Environment]::NewLine, [Text.UTF8Encoding]::new($false)) }
Write-Output $json
