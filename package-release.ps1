param(
    [Parameter(Mandatory = $true)]
    [string]$PhpRuntimeDir,
    [string]$Version = "v1.0.0",
    [string]$OutputDir = ".\dist",
    [switch]$SkipComposerInstall,
    [switch]$SkipPharBuild
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Resolve-RepoRoot {
    return $PSScriptRoot
}

function Test-RequiredTool {
    param([string]$CommandName, [string]$ErrorMessage)
    if (-not (Get-Command $CommandName -ErrorAction SilentlyContinue)) {
        throw $ErrorMessage
    }
}

function New-RarArchive {
    param(
        [string]$ArchivePath,
        [string]$DirectoryToPack
    )

    $rarCandidates = @()
    $rarFromPath = Get-Command rar -ErrorAction SilentlyContinue
    if ($rarFromPath) {
        $rarCandidates += $rarFromPath.Source
    }

    $programFilesRar = Join-Path ${env:ProgramFiles} "WinRAR\Rar.exe"
    if (Test-Path $programFilesRar) {
        $rarCandidates += $programFilesRar
    }

    if ($env:ProgramFiles(x86)) {
        $programFilesX86Rar = Join-Path ${env:ProgramFiles(x86)} "WinRAR\Rar.exe"
        if (Test-Path $programFilesX86Rar) {
            $rarCandidates += $programFilesX86Rar
        }
    }

    $rarExe = $rarCandidates | Select-Object -First 1
    if (-not $rarExe) {
        throw "Could not find RAR executable. Install WinRAR (Rar.exe) or add 'rar' to PATH."
    }

    $parent = Split-Path -Parent $DirectoryToPack
    $leaf = Split-Path -Leaf $DirectoryToPack
    Push-Location $parent
    try {
        & $rarExe a -r $ArchivePath $leaf | Out-Host
    } finally {
        Pop-Location
    }

    if ($LASTEXITCODE -ne 0) {
        throw "RAR packaging failed with exit code $LASTEXITCODE"
    }
}

Write-Step "Switching to repository root"
$repoRoot = Resolve-RepoRoot
Set-Location $repoRoot

$runtimePathInfo = Resolve-Path $PhpRuntimeDir -ErrorAction SilentlyContinue
if (-not $runtimePathInfo) {
    throw "PhpRuntimeDir not found: $PhpRuntimeDir"
}
$runtimePath = $runtimePathInfo.Path

if (-not (Test-Path (Join-Path $runtimePath "php.exe"))) {
    throw "PhpRuntimeDir must contain php.exe. Provided: $runtimePath"
}

$outputRoot = [System.IO.Path]::GetFullPath((Join-Path $repoRoot $OutputDir))
$stagingParent = Join-Path $outputRoot "staging"
$stagingDir = Join-Path $stagingParent "esc-pos-printer-manager"
$archivePath = Join-Path $outputRoot "esc-pos-printer-manager.$Version.rar"
$builtPharPath = Join-Path $repoRoot "miaplicacion.phar"
$releasePharPath = Join-Path $stagingDir "data.phar"
$launcherPath = Join-Path $repoRoot "escpos-printer.cmd"

if (-not $SkipPharBuild) {
    Write-Step "Validating toolchain for PHAR build"
    Test-RequiredTool -CommandName "php" -ErrorMessage "PHP is not installed or not available in PATH."
    Test-RequiredTool -CommandName "composer" -ErrorMessage "Composer is not installed or not available in PATH."

    if (-not $SkipComposerInstall) {
        Write-Step "Installing PHP dependencies"
        composer install --no-dev --optimize-autoloader
    } else {
        Write-Step "Skipping composer install"
    }

    Write-Step "Building PHAR artifact"
    $env:ENABLE_PRINT_TEST = "false"
    php -d phar.readonly=0 .\build_phar.php

    if (-not (Test-Path $builtPharPath)) {
        throw "Build failed. Artifact not found: $builtPharPath"
    }
} else {
    Write-Step "Skipping PHAR build"
    if (-not (Test-Path $builtPharPath)) {
        throw "miaplicacion.phar not found. Build it first or remove -SkipPharBuild."
    }
}

Write-Step "Preparing release staging directory"
New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null
if (Test-Path $stagingParent) {
    Remove-Item -Path $stagingParent -Recurse -Force
}
New-Item -ItemType Directory -Path $stagingDir -Force | Out-Null

Write-Step "Copying runtime, launcher, and PHAR"
Copy-Item -Path $runtimePath -Destination (Join-Path $stagingDir "data") -Recurse
Copy-Item -Path $launcherPath -Destination (Join-Path $stagingDir "escpos-printer.cmd") -Force
Copy-Item -Path $builtPharPath -Destination $releasePharPath -Force

Write-Step "Creating RAR archive"
if (Test-Path $archivePath) {
    Remove-Item -Path $archivePath -Force
}
New-RarArchive -ArchivePath $archivePath -DirectoryToPack $stagingDir

Write-Host "`nRelease package created successfully:" -ForegroundColor Green
Write-Host "  Folder:  $stagingDir"
Write-Host "  Archive: $archivePath"
