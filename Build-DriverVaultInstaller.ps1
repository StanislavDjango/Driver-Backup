param(
    [string]$Version = "0.4.2.0",
    [string]$OutputDir = ""
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSCommandPath
$issPath = Join-Path $root "installer\DriverVault.iss"
$driverVaultExe = Join-Path $root "dist\DriverVault.exe"

if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    $OutputDir = Join-Path $root "dist"
}

if (-not (Test-Path -LiteralPath $issPath)) {
    throw "Installer script was not found: $issPath"
}

if (-not (Test-Path -LiteralPath $driverVaultExe)) {
    throw "DriverVault.exe was not found. Build the app EXE before building the installer."
}

if (-not (Test-Path -LiteralPath $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

$isccCandidates = @()
if (-not [string]::IsNullOrWhiteSpace(${env:ProgramFiles(x86)})) {
    $isccCandidates += (Join-Path ${env:ProgramFiles(x86)} "Inno Setup 6\ISCC.exe")
}
if (-not [string]::IsNullOrWhiteSpace($env:ProgramFiles)) {
    $isccCandidates += (Join-Path $env:ProgramFiles "Inno Setup 6\ISCC.exe")
}

$isccPath = $isccCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (-not $isccPath) {
    $command = Get-Command ISCC.exe -ErrorAction SilentlyContinue
    if ($command) {
        $isccPath = $command.Source
    }
}

if (-not $isccPath) {
    throw "Inno Setup compiler ISCC.exe was not found. Install Inno Setup 6 first."
}

$env:DRIVERVAULT_SEMVER = $Version
$outputFullPath = [IO.Path]::GetFullPath($OutputDir)

Write-Host "Building DriverVault installer..."
Write-Host "Inno Setup: $isccPath"
Write-Host "Version: $Version"

& $isccPath $issPath "/O$outputFullPath" "/FDriverVaultSetup"
if ($LASTEXITCODE -ne 0) {
    throw "Inno Setup failed with exit code $LASTEXITCODE."
}

$installerPath = Join-Path $outputFullPath "DriverVaultSetup.exe"
$item = Get-Item -LiteralPath $installerPath
Write-Host "Built: $($item.FullName)"
Write-Host "Size: $($item.Length) bytes"
