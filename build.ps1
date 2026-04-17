param(
    [switch]$SkipComposerInstall,
    [switch]$SkipDefenderScan
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

Write-Step "Validating toolchain"
if (-not (Get-Command php -ErrorAction SilentlyContinue)) {
    throw "PHP is not installed or not available in PATH."
}
if (-not (Get-Command composer -ErrorAction SilentlyContinue)) {
    throw "Composer is not installed or not available in PATH."
}

Write-Step "Switching to repository root"
$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $repoRoot

if (-not $SkipComposerInstall) {
    Write-Step "Installing PHP dependencies"
    composer install --no-dev --optimize-autoloader
} else {
    Write-Step "Skipping composer install"
}

Write-Step "Building PHAR artifact"
$env:ENABLE_PRINT_TEST = "false"
php -d phar.readonly=0 .\build_phar.php

$artifactPath = Join-Path $repoRoot "miaplicacion.phar"
if (-not (Test-Path $artifactPath)) {
    throw "Build failed. Artifact not found: $artifactPath"
}

if (-not $SkipDefenderScan) {
    $mpCmdRun = Join-Path ${env:ProgramFiles} "Windows Defender\MpCmdRun.exe"
    if (Test-Path $mpCmdRun) {
        Write-Step "Running Microsoft Defender custom scan"
        & $mpCmdRun -Scan -ScanType 3 -File $artifactPath
    } else {
        Write-Step "Microsoft Defender CLI not found. Skipping Defender scan."
    }
} else {
    Write-Step "Skipping Defender scan"
}

Write-Host "`nBuild completed successfully: $artifactPath" -ForegroundColor Green
