# Connect a USB device to WSL using usbipd-win
# Run PowerShell as Administrator for bind operations.

$ErrorActionPreference = "Stop"

Write-Host "=== WSL USB attach helper (usbipd-win) ===" -ForegroundColor Cyan
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
        Write-Host "Found usbipd: $path" -ForegroundColor Green
        break
    }
}

if (-not $usbipdPath) {
    Write-Host "ERROR: usbipd.exe not found." -ForegroundColor Red
    Write-Host "Checked paths:" -ForegroundColor Yellow
    foreach ($path in $possiblePaths) {
        Write-Host "  - $path"
    }
    Write-Host ""
    Write-Host "Try restarting PowerShell or reinstall usbipd-win." -ForegroundColor Yellow
    exit 1
}

# WSL 배포판 확인
Write-Host ""
Write-Host "Detecting WSL distro..." -ForegroundColor Cyan
$wslList = wsl --list --verbose 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: WSL not available." -ForegroundColor Red
    exit 1
}

Write-Host $wslList
$defaultWsl = ($wslList | Select-String "^\*" | ForEach-Object { ($_ -split '\s+')[1] })
if ($defaultWsl) {
    Write-Host "Default WSL distro: $defaultWsl" -ForegroundColor Green
} else {
    $defaultWsl = "Ubuntu-22.04"
    Write-Host "Couldn't detect default distro; using '$defaultWsl'." -ForegroundColor Yellow
}

# USB 디바이스 목록
Write-Host ""
Write-Host "USB devices (usbipd list):" -ForegroundColor Cyan
$deviceList = & $usbipdPath list 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: usbipd list failed. Output:" -ForegroundColor Red
    Write-Host $deviceList
    Write-Host ""
    Write-Host "Make sure 'usbipd' is installed and try running in an elevated PowerShell." -ForegroundColor Yellow
    exit 1
}
Write-Host $deviceList

# HumiroThermal 디바이스 찾기 (우선 검색)
Write-Host ""
Write-Host "Searching for 'HumiroThermal'..." -ForegroundColor Cyan
$humiroDevices = $deviceList | Select-String -Pattern "HumiroThermal" -CaseSensitive:$false

# HumiroThermal을 찾지 못한 경우 FLIR Lepton 카메라 찾기 (Vendor ID: 1e4e)
if (-not $humiroDevices) {
    Write-Host "Not found. Falling back to Vendor ID search (VID=1e4e)..." -ForegroundColor Yellow
    $leptonDevices = $deviceList | Select-String "1e4e"
} else {
    Write-Host "Found HumiroThermal!" -ForegroundColor Green
    $leptonDevices = $humiroDevices
}

if (-not $leptonDevices) {
    Write-Host ""
    Write-Host "WARNING: Couldn't find 'HumiroThermal' nor VID 1e4e." -ForegroundColor Yellow
    Write-Host "Check:" -ForegroundColor Yellow
    Write-Host "  1) The device is physically connected to Windows"
    Write-Host "  2) Windows Device Manager sees it (and no other app is using it)"
    Write-Host ""
    Write-Host "All devices shown by usbipd:" -ForegroundColor Cyan
    $allDevices = $deviceList | Select-String "Not attached|Attached"
    if ($allDevices) {
        $index = 1
        $deviceArray = @()
        foreach ($device in $allDevices) {
            $busid = ($device -split '\s+')[0]
            $deviceArray += $busid
            Write-Host "  $index. $device" -ForegroundColor White
            $index++
        }
        Write-Host ""
        Write-Host "Select a device number or type BUSID directly (e.g. 1 or 1-1):" -ForegroundColor Cyan
        $input = Read-Host
        if ($input -match '^\d+$') {
            # 숫자만 입력한 경우 (인덱스)
            $busid = $deviceArray[[int]$input - 1]
        } else {
            # BUSID 직접 입력
            $busid = $input
        }
        if ($busid) {
            Write-Host ""
            Write-Host "Binding to WSL... (BUSID: $busid)" -ForegroundColor Cyan
            & $usbipdPath bind --busid $busid --wsl $defaultWsl
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Success: device bound to WSL." -ForegroundColor Green
                Write-Host ""
                Write-Host "Next (inside WSL):" -ForegroundColor Cyan
                Write-Host "  sudo modprobe usbip-core" -ForegroundColor White
                Write-Host "  sudo modprobe usbip-host" -ForegroundColor White
                Write-Host "  export WSL_HOST_IP=`$(cat /etc/resolv.conf | grep nameserver | awk '{print `$2}')" -ForegroundColor White
                Write-Host "  sudo usbip attach -r `$WSL_HOST_IP -b $busid" -ForegroundColor White
            } else {
                Write-Host "ERROR: bind failed. Try running PowerShell as Administrator." -ForegroundColor Red
            }
        }
    }
    exit 0
}

# HumiroThermal 또는 FLIR Lepton 카메라가 여러 개인 경우
$deviceCount = ($leptonDevices | Measure-Object).Count
if ($deviceCount -gt 1) {
    Write-Host ""
    if ($humiroDevices) {
        Write-Host "Multiple HumiroThermal devices found:" -ForegroundColor Yellow
    } else {
        Write-Host "Multiple VID=1e4e devices found:" -ForegroundColor Yellow
    }
    $index = 1
    $deviceArray = @()
    foreach ($device in $leptonDevices) {
        $busid = ($device -split '\s+')[0]
        $deviceArray += $busid
        Write-Host "  $index. BUSID: $busid - $device" -ForegroundColor White
        $index++
    }
    Write-Host ""
    Write-Host "Select device number (1-$deviceCount):" -ForegroundColor Cyan
    $selection = Read-Host
    $selectedBusid = $deviceArray[[int]$selection - 1]
} else {
    # 하나만 있는 경우
    $selectedBusid = ($leptonDevices -split '\s+')[0]
    if ($humiroDevices) {
        Write-Host "HumiroThermal found: BUSID $selectedBusid" -ForegroundColor Green
    } else {
        Write-Host "VID=1e4e device found: BUSID $selectedBusid" -ForegroundColor Green
    }
}

# USB 디바이스 바인딩
Write-Host ""
Write-Host "Binding device to WSL..." -ForegroundColor Cyan
& $usbipdPath bind --busid $selectedBusid --wsl $defaultWsl

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✓ Success: device bound to WSL." -ForegroundColor Green
    Write-Host ""
    Write-Host "=== Next (inside WSL) ===" -ForegroundColor Cyan
    Write-Host "Run:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  # Install usbip tools (if needed)" -ForegroundColor White
    Write-Host "  sudo apt-get update" -ForegroundColor White
    Write-Host "  sudo apt-get install -y usbip hwdata usb.ids usbutils" -ForegroundColor White
    Write-Host ""
    Write-Host "  # Load usbip kernel modules" -ForegroundColor White
    Write-Host "  sudo modprobe usbip-core" -ForegroundColor White
    Write-Host "  sudo modprobe usbip-host" -ForegroundColor White
    Write-Host ""
    Write-Host "  # Attach to Windows host" -ForegroundColor White
    Write-Host "  export WSL_HOST_IP=`$(cat /etc/resolv.conf | grep nameserver | awk '{print `$2}')" -ForegroundColor White
    Write-Host "  sudo usbip attach -r `$WSL_HOST_IP -b $selectedBusid" -ForegroundColor White
    Write-Host ""
    Write-Host "  # Verify" -ForegroundColor White
    Write-Host "  lsusb" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "✗ ERROR: bind failed." -ForegroundColor Red
    Write-Host "Check:" -ForegroundColor Yellow
    Write-Host "  1) Run PowerShell as Administrator"
    Write-Host "  2) Device not in use by other apps"
    Write-Host "  3) usbipd service running"
}

Write-Host ""
Write-Host "Done." -ForegroundColor Cyan

