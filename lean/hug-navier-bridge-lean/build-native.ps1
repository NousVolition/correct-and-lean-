param([string[]]$Modules = @('HugModel','ActiveHugModel','BridgeModel','BridgeSolution'))
$ErrorActionPreference = 'Stop'
$bridgePackage = $PSScriptRoot
$bridgeWorkspace = Split-Path -Parent $bridgePackage
$bridgeTools = Join-Path $bridgeWorkspace 'work/toolchains/lean-4.34.0-rc2-windows/bin'
$bridgeDeps = Join-Path $bridgeWorkspace 'work/NavierStokesAndEuler-audit/.lake/packages'
$bridgeLib = Join-Path $bridgePackage '.lake/build/lib/lean'
New-Item -ItemType Directory -Path $bridgeLib -Force | Out-Null
$bridgeImportPaths = @($bridgeLib)
foreach ($bridgeDependency in Get-ChildItem -LiteralPath $bridgeDeps -Directory) {
    $bridgeCandidate = Join-Path $bridgeDependency.FullName '.lake/build/lib/lean'
    if (Test-Path -LiteralPath $bridgeCandidate) { $bridgeImportPaths += $bridgeCandidate }
}
$env:LEAN_PATH = $bridgeImportPaths -join ';'
$env:LEAN_NUM_THREADS = '4'
Push-Location -LiteralPath $bridgePackage
try {
    foreach ($bridgeModule in $Modules) {
        & (Join-Path $bridgeTools 'lean.exe') '-o' (Join-Path $bridgeLib ($bridgeModule + '.olean')) ($bridgeModule + '.lean')
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }
} finally { Pop-Location }
