param([string[]]$Modules = @('HugModel','ActiveHugModel','HugBarrier','ActiveHugSolution','Volterra','HugFullClaim','HugTools','HugBox','HugBounds','HugConstruction','HugExistenceSolution'))
$ErrorActionPreference = 'Stop'
$hugPackage = $PSScriptRoot
$hugWorkspace = Split-Path -Parent $hugPackage
$hugTools = Join-Path $hugWorkspace 'work/toolchains/lean-4.34.0-rc2-windows/bin'
$hugDeps = Join-Path $hugWorkspace 'work/NavierStokesAndEuler-audit/.lake/packages'
$hugLib = Join-Path $hugPackage '.lake/build/lib/lean'
New-Item -ItemType Directory -Path $hugLib -Force | Out-Null
$hugImportPaths = @($hugLib)
foreach ($hugDependency in Get-ChildItem -LiteralPath $hugDeps -Directory) {
    $hugCandidate = Join-Path $hugDependency.FullName '.lake/build/lib/lean'
    if (Test-Path -LiteralPath $hugCandidate) { $hugImportPaths += $hugCandidate }
}
$env:LEAN_PATH = $hugImportPaths -join ';'
$env:LEAN_NUM_THREADS = '4'
Push-Location -LiteralPath $hugPackage
try {
    foreach ($hugModule in $Modules) {
        & (Join-Path $hugTools 'lean.exe') '-o' (Join-Path $hugLib ($hugModule + '.olean')) ($hugModule + '.lean')
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }
} finally { Pop-Location }
