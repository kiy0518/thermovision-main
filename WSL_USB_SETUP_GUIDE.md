# WSL USB 연결 설정 가이드 (한국어)

## 문제: usbipd 명령어를 찾을 수 없음

USBIPD를 설치한 후 PowerShell을 재시작하지 않으면 `usbipd` 명령어를 찾을 수 없을 수 있습니다.

## 해결 방법

### 방법 1: PowerShell 재시작 (권장)

1. 현재 PowerShell 창을 닫습니다
2. **새로운 PowerShell을 관리자 권한으로 실행**합니다
3. 다시 시도합니다

### 방법 2: 전체 경로로 실행

PowerShell에서 다음 경로를 확인하고 사용하세요:

```powershell
# 일반적인 설치 경로
& "C:\Program Files\usbipd-win\usbipd.exe" list

# 또는
& "C:\Program Files (x86)\usbipd-win\usbipd.exe" list
```

### 방법 3: PATH 확인 및 추가

```powershell
# USBIPD 경로 확인
Get-ChildItem "C:\Program Files" -Filter "usbipd*" -Recurse -ErrorAction SilentlyContinue
Get-ChildItem "C:\Program Files (x86)" -Filter "usbipd*" -Recurse -ErrorAction SilentlyContinue

# PATH에 추가 (필요한 경우)
$env:Path += ";C:\Program Files\usbipd-win"
```

## 올바른 사용 방법

### 1단계: USB 디바이스 목록 확인

```powershell
usbipd list
```

출력 예시:
```
BUSID  VID:PID    DEVICE                                                        STATE
1-1    1e4e:0100  PureThermal 1                                                 Not attached
```

### 2단계: USB 디바이스를 WSL에 바인딩

**주의**: `--bind Ubuntu`가 아니라 `--busid`를 사용해야 합니다!

```powershell
# 먼저 USB 디바이스를 바인딩 (BUSID는 위의 list 명령에서 확인)
usbipd bind --busid 1-1

# 또는 WSL 배포판 이름을 지정하여 자동 연결
usbipd bind --busid 1-1 --wsl Ubuntu-22.04
```

### 3단계: WSL에서 USB 디바이스 연결

WSL 터미널에서:

```bash
# USBIP 도구 설치 (아직 안 했다면)
sudo apt-get update
sudo apt-get install -y usbip hwdata usb.ids usbutils

# USBIP 커널 모듈 로드
sudo modprobe usbip-core
sudo modprobe usbip-host

# Windows 호스트의 IP 주소 확인 (보통 .1로 끝남)
export WSL_HOST_IP=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')

# USB 디바이스 연결 (BUSID는 Windows에서 확인한 값)
sudo usbip attach -r $WSL_HOST_IP -b 1-1
```

### 4단계: 연결 확인

```bash
# USB 디바이스 확인
lsusb

# FLIR Lepton 카메라가 보여야 합니다 (1e4e:0100)
```

## 자동화 스크립트

Windows PowerShell에서 실행할 스크립트:

```powershell
# USBIPD 경로 확인 및 설정
$usbipdPath = "C:\Program Files\usbipd-win\usbipd.exe"
if (-not (Test-Path $usbipdPath)) {
    $usbipdPath = "C:\Program Files (x86)\usbipd-win\usbipd.exe"
}

# USB 디바이스 목록
& $usbipdPath list

# FLIR Lepton 카메라 찾기 (Vendor ID: 1e4e)
$devices = & $usbipdPath list | Select-String "1e4e"
if ($devices) {
    $busid = ($devices -split '\s+')[0]
    Write-Host "FLIR Lepton 카메라 발견: BUSID $busid"
    
    # 바인딩
    & $usbipdPath bind --busid $busid --wsl Ubuntu-22.04
    Write-Host "USB 디바이스가 WSL에 연결되었습니다"
} else {
    Write-Host "FLIR Lepton 카메라를 찾을 수 없습니다"
}
```

## 문제 해결

### "usbipd를 찾을 수 없음" 오류

1. **PowerShell 재시작**: 가장 간단한 해결책
2. **설치 경로 확인**: 
   ```powershell
   Get-ChildItem "C:\Program Files" -Filter "*usbipd*" -Recurse
   ```
3. **수동으로 PATH 추가**:
   ```powershell
   [Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\usbipd-win", "User")
   ```

### USB 디바이스가 "Not attached" 상태

- USB 디바이스가 물리적으로 연결되어 있는지 확인
- 다른 프로그램에서 사용 중인지 확인
- USB 포트를 다른 포트로 변경해보기

### WSL에서 USB 디바이스를 찾을 수 없음

1. **USBIP 모듈이 로드되었는지 확인**:
   ```bash
   lsmod | grep usbip
   ```

2. **수동으로 모듈 로드**:
   ```bash
   sudo modprobe usbip-core
   sudo modprobe usbip-host
   ```

3. **Windows 방화벽 확인**: USBIPD가 Windows 방화벽을 통과할 수 있도록 허용되어 있는지 확인

## 참고

- USB 디바이스는 Windows를 재부팅하거나 USB를 다시 연결할 때마다 다시 바인딩해야 할 수 있습니다
- USBIPD를 사용하면 Windows에서도 해당 USB 디바이스를 사용할 수 없게 됩니다
- WSL을 재시작해도 USB 연결은 유지되지 않으므로, 필요할 때마다 다시 연결해야 합니다

