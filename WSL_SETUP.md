# WSL 환경에서 실행하기

이 프로젝트는 WSL2 환경에서 실행 가능하지만, USB 디바이스(FLIR Lepton 카메라) 접근을 위해 추가 설정이 필요합니다.

## 문제점

WSL은 기본적으로 USB 디바이스를 직접 접근할 수 없습니다. USB 디바이스를 사용하려면 Windows에서 WSL로 USB를 전달해야 합니다.

## 해결 방법

### 방법 1: USBIPD를 사용한 USB 전달 (권장)

#### 1. Windows에서 USBIPD 설치

PowerShell을 관리자 권한으로 실행하고 다음 명령 실행:

```powershell
# USBIPD 설치
winget install --interactive --exact dorssel.usbipd-win

# 또는 Chocolatey 사용 시
choco install usbipd
```

#### 2. USB 디바이스 확인

PowerShell에서 연결된 USB 디바이스 확인:

```powershell
usbipd list
```

FLIR Lepton 카메라가 연결되어 있다면 목록에 표시됩니다.

#### 3. USB 디바이스를 WSL에 연결

```powershell
# WSL 배포판 이름 확인 (보통 "Ubuntu" 또는 "Debian")
wsl --list --verbose

# USB 디바이스를 WSL에 연결 (BUSID는 usbipd list에서 확인)
usbipd bind --busid <BUSID>

# WSL에서 USBIP 클라이언트 설정
wsl --distribution <배포판이름> --exec sudo usbip attach -r localhost -b <BUSID>
```

#### 4. WSL에서 USB 디바이스 확인

WSL 터미널에서:

```bash
lsusb
# 또는
ls -la /dev/bus/usb/
```

### 방법 2: WSL2 USB 확장 사용 (Windows 11)

Windows 11을 사용하는 경우, WSL2 USB 확장 기능을 사용할 수 있습니다:

1. Windows에서 USBIPD-WIN 설치 (방법 1과 동일)
2. WSL에서 자동으로 USB 디바이스가 인식됩니다

## 프로젝트 설정

USB 디바이스가 인식되면 다음 단계를 진행하세요:

### 1. 시스템 의존성 설치

```bash
cd /home/humiro/thermovision-main
chmod +x setup_linux.sh
./setup_linux.sh
```

### 2. Python 패키지 설치

```bash
chmod +x setup_python.sh
./setup_python.sh
```

또는 수동으로:

```bash
pip3 install PyQt5 opencv-python psutil h5py tifffile
```

### 3. USB 디바이스 권한 확인

```bash
# USB 그룹에 사용자 추가 (이미 되어 있을 수 있음)
sudo usermod -aG usb $USER

# udev 규칙이 제대로 설정되었는지 확인
cat /etc/udev/rules.d/99-pt1.rules

# udev 규칙 재로드
sudo udevadm control --reload-rules
sudo udevadm trigger
```

### 4. 애플리케이션 실행

```bash
cd src
python3 FeverDetector.py
```

## 문제 해결

### USB 디바이스를 찾을 수 없는 경우

1. **Windows에서 USBIPD 서비스 확인:**
   ```powershell
   # USBIPD 서비스 시작
   usbipd start
   ```

2. **WSL에서 USBIP 클라이언트 설치:**
   ```bash
   sudo apt-get update
   sudo apt-get install usbip hwdata usb.ids
   ```

3. **USBIP 커널 모듈 로드:**
   ```bash
   sudo modprobe usbip-core
   sudo modprobe usbip-host
   ```

### libuvc.so를 찾을 수 없는 경우

```bash
# libuvc 라이브러리 경로 확인
ldconfig -p | grep libuvc

# 라이브러리 경로가 없다면
sudo ldconfig
```

### GUI 애플리케이션이 실행되지 않는 경우

WSL에서 GUI를 표시하려면 X11 전달이 필요합니다:

1. **Windows에서 X 서버 설치:**
   - VcXsrv 또는 X410 설치

2. **WSL에서 DISPLAY 환경 변수 설정:**
   ```bash
   export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0.0
   ```

3. **X 서버 실행 후 애플리케이션 실행**

## 참고 사항

- USB 디바이스는 Windows를 재부팅하거나 USB를 다시 연결할 때마다 다시 바인딩해야 할 수 있습니다
- USBIPD를 사용하면 Windows에서도 해당 USB 디바이스를 사용할 수 없게 됩니다
- WSL2를 사용하는 것이 WSL1보다 USB 지원이 더 좋습니다

## 대안

USB 전달이 복잡한 경우, 다음 대안을 고려할 수 있습니다:

1. **네이티브 Linux 환경 사용** (가상 머신 또는 듀얼 부팅)
2. **Windows에서 직접 실행** (WSL이 아닌 Windows Python 환경)
3. **원격 Linux 서버 사용** (SSH를 통한 접근)

