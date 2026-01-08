# WSL USB 연결 문제 해결

## 현재 상황
- Windows에서 `usbipd attach --wsl --busid 8-1` 실행 성공
- 하지만 `usbipd list`에서 여전히 `Shared` 상태 (Attached가 아님)
- WSL에서 `lsusb`로 디바이스가 보이지 않음

## 가능한 원인 및 해결 방법

### 1. WSL2 버전 확인
WSL2에서 USB 지원은 제한적입니다. WSL을 재시작해보세요:

**Windows PowerShell에서:**
```powershell
wsl --shutdown
```

그 다음 WSL을 다시 시작하고:
```bash
lsusb
```

### 2. Windows 11 및 최신 WSL 사용 확인
- Windows 11을 사용하고 계신가요?
- WSL 버전 확인: `wsl --version`
- WSL 업데이트: `wsl --update`

### 3. USBIPD 서비스 상태 확인
USBIPD는 Windows 서비스로 실행됩니다. 서비스 상태 확인:

**PowerShell(관리자 권한):**
```powershell
Get-Service -Name usbipd
```

또는 작업 관리자에서 "USBIPD" 서비스 확인

### 4. detach 후 재연결
기존 연결을 완전히 해제하고 다시 시도:

**PowerShell(관리자 권한):**
```powershell
# 기존 연결 해제
usbipd detach --busid 8-1
usbipd unbind --busid 8-1

# 잠시 대기
Start-Sleep -Seconds 2

# 다시 바인딩 및 연결
usbipd bind --busid 8-1
usbipd attach --wsl --busid 8-1
```

### 5. Windows 방화벽 확인
USBIPD 연결이 Windows 방화벽에 의해 차단될 수 있습니다. 

방화벽에서 "USBIPD" 또는 포트 3240 (USBIP 기본 포트)를 허용해야 할 수 있습니다.

### 6. WSL 배포판 이름 확인
WSL 배포판 이름이 정확한지 확인:

**PowerShell에서:**
```powershell
wsl --list --verbose
```

기본 배포판이 `Ubuntu-22.04`가 아닐 수 있습니다. 정확한 이름으로 attach:

```powershell
usbipd attach --wsl --distribution <정확한_배포판_이름> --busid 8-1
```

### 7. 대안: 네이티브 Windows에서 실행
WSL에서 USB 연결이 계속 문제가 있다면, Python 애플리케이션을 Windows에서 직접 실행하는 것을 고려해볼 수 있습니다:

1. Windows에 Python 설치
2. 필요한 패키지 설치 (PyQt5, opencv-python-headless, etc.)
3. libuvc를 Windows 버전으로 사용

### 8. 로그 확인
USBIPD 로그 확인:

**PowerShell(관리자 권한):**
```powershell
# 이벤트 뷰어에서 USBIPD 관련 이벤트 확인
Get-EventLog -LogName Application -Source "USBIPD*" -Newest 10
```

## 다음 단계
위의 방법들을 순서대로 시도해보세요. 특히 WSL 재시작과 detach/unbind 후 재연결이 가장 효과적일 수 있습니다.

