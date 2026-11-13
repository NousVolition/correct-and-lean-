param(
    [Parameter(Mandatory = $true)][string]$ToolchainBin,
    [Parameter(Mandatory = $true)][string]$DependencyRoot,
    [string]$BuildRoot = "$PSScriptRoot/.lake/build/lib/lean",
    [string]$LogRoot = "$PSScriptRoot/logs/rebuild",
    [string[]]$Modules = @('FullModel','OriginalAS','OriginalASEnergy','OriginalASBalance','OriginalASIntegrated','EnergyAccounting','UnwrappedWork','HistoryAudit')
)
# Rebuilds every local source file with an existing matching Lean + Mathlib cache.
# This script does not install tools, download dependencies, or edit that cache.
$ErrorActionPreference = 'Stop'
$ToolchainBin = (Resolve-Path -LiteralPath $ToolchainBin).Path
$DependencyRoot = (Resolve-Path -LiteralPath $DependencyRoot).Path
$compiler = Join-Path $ToolchainBin 'lean.exe'
if (-not (Test-Path -LiteralPath $compiler)) { throw "Missing compiler: $compiler" }
New-Item -ItemType Directory -Path $BuildRoot,$LogRoot -Force | Out-Null
$BuildRoot = (Resolve-Path -LiteralPath $BuildRoot).Path
$LogRoot = (Resolve-Path -LiteralPath $LogRoot).Path
$importPaths = @($BuildRoot)
foreach ($dependency in Get-ChildItem -LiteralPath $DependencyRoot -Directory) {
    $candidate = Join-Path $dependency.FullName '.lake/build/lib/lean'
    if (Test-Path -LiteralPath $candidate) { $importPaths += $candidate }
}
$previousLeanPath = $env:LEAN_PATH
$previousThreads = $env:LEAN_NUM_THREADS
$env:LEAN_PATH = $importPaths -join ';'
$env:LEAN_NUM_THREADS = '2'
$results = @()
Push-Location -LiteralPath $PSScriptRoot
try {
    & $compiler --version | Set-Content -LiteralPath (Join-Path $LogRoot 'lean-version.txt') -Encoding utf8
    if ($LASTEXITCODE -ne 0) { throw 'Compiler version check failed' }
    foreach ($module in $Modules) {
        $source = Join-Path $PSScriptRoot ($module + '.lean')
        $object = Join-Path $BuildRoot ($module + '.olean')
        $log = Join-Path $LogRoot ($module + '.log')
        $before = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
        $start = [DateTime]::UtcNow.ToString('o')
        Write-Output "Compiling $module"
        & $compiler '-o' $object ($module + '.lean') 2>&1 | Tee-Object -FilePath $log
        $code = $LASTEXITCODE
        # Quiet successful modules still receive an empty log.
        if (-not (Test-Path -LiteralPath $log)) { New-Item -ItemType File -Path $log | Out-Null }
        $results += [ordered]@{
            module = $module; exit_code = $code; started_utc = $start;
            finished_utc = [DateTime]::UtcNow.ToString('o'); source_sha256 = $before;
            source_unchanged = ($before -eq (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash);
            source = $source; command = @($compiler, '-o', $object, ($module + '.lean'));
            log = $log; log_sha256 = (Get-FileHash -LiteralPath $log -Algorithm SHA256).Hash
        }
        $results | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $LogRoot 'build-results.json') -Encoding utf8
        Write-Output "$module exit=$code"
        if ($code -ne 0) { throw "Compilation failed: $module (see $log)" }
    }
} finally {
    Pop-Location
    $env:LEAN_PATH = $previousLeanPath
    $env:LEAN_NUM_THREADS = $previousThreads
}
