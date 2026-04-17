# What is ESC-POS PRINTER MANAGER

A Windows executable that runs a local php server with the ability to manage the ESC POS printer on your PC

[![Buy Me a Coffee](https://www.buymeacoffee.com/assets/img/custom_images/yellow_img.png)](https://www.buymeacoffee.com/yayidg22)

# ESC-POS PRINTER MANAGER [RELEASES](https://github.com/yayidg22/esc-pos-printer-manager-releases/releases)

# [JAVASCRIPT/TYPESCRIPT LIBRARY](https://www.npmjs.com/package/esc-pos-printer)

# [DOCUMENTATION](https://escpos-printermanager.netlify.app/)

## Build on Windows (PHAR)

This project can be packaged into `miaplicacion.phar` on Windows.

### Prerequisites

1. Windows 10/11
2. PHP 8.x available in `PATH`
3. Composer available in `PATH`
4. `phar` extension enabled in PHP

### Manual build steps

1. Open **PowerShell** in the repository root.
2. Install dependencies:

```powershell
composer install --no-dev --optimize-autoloader
```

3. Disable the test endpoint for the build process:

```powershell
$env:ENABLE_PRINT_TEST = "false"
```

4. Build the PHAR artifact:

```powershell
php -d phar.readonly=0 .\build_phar.php
```

5. Confirm that `miaplicacion.phar` was created in the project root.

### One-command build script

You can use the included script:

```powershell
.\build.ps1
```

Optional flags:

```powershell
.\build.ps1 -SkipComposerInstall
.\build.ps1 -SkipDefenderScan
```

The script performs:

1. Toolchain checks (`php`, `composer`)
2. Dependency installation (unless skipped)
3. PHAR build with `phar.readonly=0`
4. Optional Microsoft Defender custom scan of the artifact

### Optional Microsoft Defender check

If you want to run Defender manually:

```powershell
& "$Env:ProgramFiles\Windows Defender\MpCmdRun.exe" -Scan -ScanType 3 -File .\miaplicacion.phar
```

### Troubleshooting

If you see `creating archive ... disabled by the php.ini setting phar.readonly`, either:

1. Use the command shown above with `-d phar.readonly=0`, or
2. Set `phar.readonly = Off` in your active `php.ini`.

## MIT license
Copyright (c) 2024 yayidg22

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
