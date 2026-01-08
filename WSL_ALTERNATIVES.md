# WSL2 USB 연결 문제 - 대안 방법

## 현재 문제
- `usbipd attach --wsl --busid 8-1` 실행 시 성공 메시지가 나오지만
- `usbipd list`에서 상태가 `Attached`로 바뀌지 않음
- WSL에서 `lsusb`로 디바이스가 보이지 않음

이는 WSL2의 USB 지원 제한 때문일 수 있습니다.

## 대안 1: Windows에서 직접 실행 (권장)

WSL에서 USB 연결이 불안정한 경우, Windows에서 직접 실행하는 것이 가장 안정적입니다.

### Windows Python 환경 설정

1. **Python 설치** (이미 설치되어 있다면 생략)
   - Python 3.10 이상 설치

2. **필요한 패키지 설치**:
```powershell
pip install PyQt5 opencv-python-headless psutil h5py tifffile numpy
```

3. **libuvc Windows 버전 설치**
   - Windows용 libuvc를 설치하거나
   - WSL의 libuvc를 사용할 수 있도록 설정

4. **프로젝트 실행**:
```powershell
cd \\wsl$\Ubuntu-22.04\home\humiro\thermovision-main\src
python FeverDetector.py
```

## 대안 2: WSL2 USB 지원 확인

WSL2에서 USB 지원은 Windows 11에서 더 잘 작동합니다.

### Windows 버전 확인:
```powershell
winver
```

Windows 10을 사용 중이라면, Windows 11로 업그레이드하는 것을 고려해볼 수 있습니다.

### WSL 업데이트:
```powershell
wsl --update
```

### USBIPD 재설치:
```powershell
winget uninstall dorssel.usbipd-win
winget install dorssel.usbipd-win
```

## 대안 3: 가상 머신 사용

WSL2 대신 VirtualBox나 VMware를 사용하여 완전한 Linux 환경을 만드는 방법입니다. 이 경우 USB 디바이스를 가상 머신에 직접 연결할 수 있습니다.

## 대안 4: 네이티브 Linux 또는 듀얼 부팅

가장 안정적인 방법은 네이티브 Linux 환경을 사용하는 것입니다:
- Ubuntu 듀얼 부팅
- 별도의 Linux PC/서버 사용

## 권장 사항

**지금 당장 실행 가능한 방법**: Windows에서 직접 실행 (대안 1)

WSL에서 USB 연결 문제를 해결하려면:
1. Windows 11 사용 확인
2. WSL 최신 버전으로 업데이트
3. USBIPD 최신 버전 사용
4. Windows 방화벽 및 보안 설정 확인

## 다음 단계

Windows에서 직접 실행하는 방법을 시도해보시겠습니까? 아니면 WSL2 USB 연결 문제를 계속 해결해보시겠습니까?

