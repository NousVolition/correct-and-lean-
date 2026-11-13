param(
    [string[]]$Modules = @('ASModel','ASOpenClaims','ASProofs','Volterra','InputRegularity','IntegralBarrier','ScalarSubsystems','PairTools','InfluenceSubsystem','MeaningSubsystem','Stages','FullAssembly','ASExistenceSolution','SuppressionComparison','ASSuppressionSolution'),
    [string]$Toolchain = $env:AS_LEAN_TOOLCHAIN,
    [string]$Dependencies = $env:AS_LEAN_DEPENDENCIES
)
$ErrorActionPreference = 'Stop'
if (-not $Toolchain -or -not $Dependencies) { throw 'Set AS_LEAN_TOOLCHAIN and AS_LEAN_DEPENDENCIES, or pass -Toolchain and -Dependencies.' }
$asLib = Join-Path $PSScriptRoot '.lake/build/lib/lean'
New-Item -ItemType Directory -Path $asLib -Force | Out-Null
$asPaths = @($asLib)
foreach ($asDep in Get-ChildItem -LiteralPath $Dependencies -Directory) {
    $asCandidate = Join-Path $asDep.FullName '.lake/build/lib/lean'
    if (Test-Path -LiteralPath $asCandidate) { $asPaths += $asCandidate }
}
$env:LEAN_PATH = $asPaths -join ';'
$env:LEAN_NUM_THREADS = '4'
Push-Location -LiteralPath $PSScriptRoot
try {
    foreach ($asModule in $Modules) {
        Write-Output "Checking $asModule"
        & (Join-Path $Toolchain 'bin/lean.exe') '-o' (Join-Path $asLib ($asModule + '.olean')) ($asModule + '.lean')
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }
} finally { Pop-Location }
