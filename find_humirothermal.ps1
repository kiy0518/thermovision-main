# Find HumiroThermal device in `usbipd list`
# Run PowerShell as Administrator if you plan to bind/attach.

$ErrorActionPreference = "Stop"

Write-Host "=== Find device: HumiroThermal (usbipd-win) ===" -ForegroundColor Cyan
Write-Host ""

# USBIPD 경로 찾기
$usbipdPath = $null
$possiblePaths = @(
    "C:\Program Files\usbipd-win\usbipd.exe",
    "C:\Program Files (x86)\usbipd-win\usbipd.exe",
    "$env:ProgramFiles\usbipd-win\usbipd.exe",
    "$env:ProgramFiles(x86)\usbipd-win\usbipd.exe"
)

foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $usbipdPath = $path
        break
    }
}

if (-not $usbipdPath) {
    Write-Host "ERROR: usbipd.exe not found." -ForegroundColor Red
    Write-Host "Try restarting PowerShell or run using full path:" -ForegroundColor Yellow
    Write-Host "  C:\Program Files\usbipd-win\usbipd.exe" -ForegroundColor White
    exit 1
}

# USB 디바이스 목록 가져오기
$deviceList = & $usbipdPath list 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: usbipd list failed. Output:" -ForegroundColor Red
    Write-Host $deviceList
    exit 1
}

Write-Host "All devices from `usbipd list`:" -ForegroundColor Cyan
Write-Host $deviceList
Write-Host ""

# HumiroThermal 검색
Write-Host "Searching for 'HumiroThermal'..." -ForegroundColor Cyan
$humiroDevices = $deviceList | Select-String -Pattern "HumiroThermal" -CaseSensitive:$false

if ($humiroDevices) {
    Write-Host ""
    Write-Host "✓ Found HumiroThermal device(s)!" -ForegroundColor Green
    Write-Host ""
    foreach ($device in $humiroDevices) {
        $busid = ($device -split '\s+')[0]
        Write-Host "  BUSID: $busid" -ForegroundColor White
        Write-Host "  Line:  $device" -ForegroundColor White
        Write-Host ""
        Write-Host "  Bind command:" -ForegroundColor Yellow
        Write-Host "    usbipd bind --busid $busid --wsl Ubuntu-22.04" -ForegroundColor Cyan
    }
} else {
    Write-Host ""
    Write-Host "✗ 'HumiroThermal' not found." -ForegroundColor Red
    Write-Host ""
    Write-Host "Check:" -ForegroundColor Yellow
    Write-Host "  1) Device is physically connected to Windows"
    Write-Host "  2) Windows Device Manager sees it"
    Write-Host "  3) No other app is using it"
    Write-Host ""
    Write-Host "Look at the list above and pick the BUSID." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Done." -ForegroundColor Cyan

