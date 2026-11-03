param([string[]]$Modules = @('ASModel', 'ASOpenClaims', 'ASProofs', 'Volterra', 'InputRegularity', 'IntegralBarrier', 'ScalarSubsystems', 'PairTools', 'InfluenceSubsystem', 'MeaningSubsystem', 'Stages', 'FullAssembly', 'ASExistenceSolution'))
$ErrorActionPreference = 'Stop'
$asPackage = $PSScriptRoot
$asWorkspace = Split-Path -Parent $asPackage
$asTools = Join-Path $asWorkspace 'work/toolchains/lean-4.34.0-rc2-windows/bin'
$asDeps = Join-Path $asWorkspace 'work/NavierStokesAndEuler-audit/.lake/packages'
$asLib = Join-Path $asPackage '.lake/build/lib/lean'
New-Item -ItemType Directory -Path $asLib -Force | Out-Null
$asImportPaths = @($asLib)
foreach ($asDependency in Get-ChildItem -LiteralPath $asDeps -Directory) {
    $asCandidate = Join-Path $asDependency.FullName '.lake/build/lib/lean'
    if (Test-Path -LiteralPath $asCandidate) { $asImportPaths += $asCandidate }
}
$env:LEAN_PATH = $asImportPaths -join ';'
$env:LEAN_NUM_THREADS = '4'
Push-Location -LiteralPath $asPackage
try {
    foreach ($asModule in $Modules) {
        & (Join-Path $asTools 'lean.exe') '-o' (Join-Path $asLib ($asModule + '.olean')) ($asModule + '.lean')
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }
} finally { Pop-Location }
