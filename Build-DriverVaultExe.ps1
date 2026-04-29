param(
    [string]$OutputPath = "",
    [string]$Version = "0.4.2.0",
    [string]$IconPath = "",
    [switch]$SkipInstall
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSCommandPath
$inputFile = Join-Path $root "DriverVault.ps1"
$distDir = Join-Path $root "dist"

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path $distDir "DriverVault.exe"
}

if ([string]::IsNullOrWhiteSpace($IconPath)) {
    $IconPath = Join-Path $root "assets\DriverVault.ico"
}

if (-not (Test-Path -LiteralPath $inputFile)) {
    throw "DriverVault.ps1 was not found: $inputFile"
}

if (-not (Test-Path -LiteralPath $distDir)) {
    New-Item -ItemType Directory -Path $distDir -Force | Out-Null
}

if (-not (Get-Command Invoke-PS2EXE -ErrorAction SilentlyContinue)) {
    if (-not (Get-Module -ListAvailable ps2exe) -and -not $SkipInstall) {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
            Write-Host "Installing NuGet provider for current user..."
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Scope CurrentUser -Force | Out-Null
        }
        $psGallery = Get-PSRepository -Name PSGallery -ErrorAction SilentlyContinue
        if ($psGallery -and $psGallery.InstallationPolicy -ne "Trusted") {
            Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        }
        Write-Host "Installing PS2EXE for current user..."
        Install-Module ps2exe -Scope CurrentUser -Force -AllowClobber
    }

    Import-Module ps2exe -ErrorAction Stop
}

if (-not (Get-Command Invoke-PS2EXE -ErrorAction SilentlyContinue)) {
    throw "Invoke-PS2EXE was not found. Install the ps2exe module first or run without -SkipInstall."
}

Write-Host "Building DriverVault EXE..."
$ps2exeParams = @{
    inputFile   = $inputFile
    outputFile  = $OutputPath
    noConsole   = $true
    requireAdmin = $true
    DPIAware    = $true
    title       = "DriverVault"
    description = "Backup and restore Windows drivers"
    company     = "DriverVault"
    product     = "DriverVault"
    version     = $Version
}

if (Test-Path -LiteralPath $IconPath) {
    $ps2exeParams.iconFile = $IconPath
    Write-Host "Icon: $IconPath"
}
else {
    Write-Host "Icon not found, building without custom icon: $IconPath"
}

Invoke-PS2EXE @ps2exeParams

$item = Get-Item -LiteralPath $OutputPath
Write-Host "Built: $($item.FullName)"
Write-Host "Size: $($item.Length) bytes"
