# WSL USB 재연결 스크립트 (Windows PowerShell)
# 관리자 권한으로 실행하세요

Write-Host "=== WSL USB 재연결 스크립트 ===" -ForegroundColor Cyan
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
    Write-Host "Error: USBIPD not found. Please restart PowerShell." -ForegroundColor Red
    exit 1
}

$busid = "8-1"

# 현재 상태 확인
Write-Host "1. Checking current USB device status..." -ForegroundColor Cyan
$deviceList = & $usbipdPath list
$deviceStatus = $deviceList | Select-String "^\s*$busid"

if ($deviceStatus) {
    Write-Host "   Device found: $deviceStatus" -ForegroundColor White
    
    if ($deviceStatus -match "Attached") {
        Write-Host "   Device is already attached." -ForegroundColor Yellow
        Write-Host ""
        $choice = Read-Host "   Do you want to reconnect? (Y/N)"
        if ($choice -ne "Y" -and $choice -ne "y") {
            Write-Host "   Cancelled." -ForegroundColor Yellow
            exit 0
        }
        Write-Host ""
        Write-Host "2. Detaching device..." -ForegroundColor Cyan
        & $usbipdPath detach --busid $busid
        Start-Sleep -Seconds 2
    }
}

# Bind 확인
if ($deviceStatus -match "Not shared") {
    Write-Host ""
    Write-Host "2. Binding device..." -ForegroundColor Cyan
    & $usbipdPath bind --busid $busid
    if ($LASTEXITCODE -ne 0) {
        Write-Host "   Error: Failed to bind device" -ForegroundColor Red
        exit 1
    }
    Write-Host "   Success: Device bound" -ForegroundColor Green
    Start-Sleep -Seconds 1
}

# Attach
Write-Host ""
Write-Host "3. Attaching device to WSL..." -ForegroundColor Cyan
& $usbipdPath attach --wsl --busid $busid

if ($LASTEXITCODE -eq 0) {
    Write-Host "   Success: Device attached to WSL" -ForegroundColor Green
    Write-Host ""
    Write-Host "=== Connection Complete ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "Verify in WSL:" -ForegroundColor Cyan
    Write-Host "  lsusb | grep -i '1e4e\|humiro'" -ForegroundColor White
} else {
    Write-Host "   Error: Failed to attach device" -ForegroundColor Red
    Write-Host ""
    Write-Host "Try:" -ForegroundColor Yellow
    Write-Host "  1. Check if WSL is running" -ForegroundColor White
    Write-Host "  2. Restart USBIPD service: usbipd stop && usbipd start" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "Script completed" -ForegroundColor Cyan



