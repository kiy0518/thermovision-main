# USBIPD로 WSL에 USB 연결 - 단계별 가이드

## 사전 준비

### 1. WSL 배포판 확인 (Windows PowerShell)
```powershell
wsl --list --verbose
```
정확한 배포판 이름을 확인하세요 (예: `Ubuntu-22.04`, `Ubuntu`, 등)

### 2. USB 디바이스 확인
```powershell
usbipd list
```
연결할 디바이스의 BUSID를 확인하세요 (예: `8-1`)

## 연결 단계 (Windows PowerShell - 관리자 권한)

### 단계 1: 기존 연결 완전히 해제
```powershell
# 기존 연결이 있다면 해제
usbipd detach --busid 8-1
usbipd unbind --busid 8-1

# 잠시 대기
Start-Sleep -Seconds 2
```

### 단계 2: USB 디바이스 바인딩
```powershell
usbipd bind --busid 8-1
```

### 단계 3: 상태 확인
```powershell
usbipd list
```
`8-1`이 `Shared` 상태인지 확인

### 단계 4: WSL에 연결
```powershell
# 배포판 이름을 명시적으로 지정
usbipd attach --wsl Ubuntu-22.04 --busid 8-1
```

또는 기본 배포판 사용:
```powershell
usbipd attach --wsl --busid 8-1
```

### 단계 5: 연결 확인
```powershell
usbipd list
```
`8-1`이 `Attached` 상태로 바뀌어야 합니다.

## 문제 해결

### 문제 1: "Attached" 상태로 바뀌지 않는 경우

#### 해결책 A: WSL 재시작
```powershell
# WSL 완전히 종료
wsl --shutdown

# 잠시 대기 (10초 이상 권장)
Start-Sleep -Seconds 10

# WSL을 다시 시작 (임의 명령으로)
wsl echo "WSL started"

# 다시 attach 시도
usbipd attach --wsl Ubuntu-22.04 --busid 8-1
```

#### 해결책 B: auto-attach 옵션 사용
```powershell
# auto-attach로 자동 재연결 설정
usbipd attach --wsl Ubuntu-22.04 --busid 8-1 --auto-attach
```

#### 해결책 C: host-ip 명시적 지정
```powershell
# WSL의 resolv.conf에서 IP 확인 후 지정
wsl cat /etc/resolv.conf | findstr nameserver

# 예: 172.20.64.1인 경우
usbipd attach --wsl Ubuntu-22.04 --busid 8-1 --host-ip 172.20.64.1
```

#### 해결책 D: USBIPD 서비스 재시작
```powershell
# USBIPD 서비스 확인
Get-Service -Name "*usbipd*"

# 서비스 재시작 (서비스 이름이 다를 수 있음)
Restart-Service -Name "USBIPD" -ErrorAction SilentlyContinue

# 또는 USBIPD 프로세스 재시작
Get-Process | Where-Object {$_.ProcessName -like "*usbipd*"} | Stop-Process -Force
```

### 문제 2: Windows 방화벽 차단

Windows 방화벽이 USBIPD 연결을 차단할 수 있습니다:

1. **Windows 보안** → **방화벽 및 네트워크 보호**
2. **고급 설정**
3. **인바운드 규칙** 확인
4. USBIPD 관련 규칙이 차단되어 있지 않은지 확인

### 문제 3: 배포판 이름 오류

정확한 배포판 이름 사용:
```powershell
# 배포판 이름 확인
wsl --list --verbose

# 확인된 정확한 이름으로 attach
usbipd attach --wsl "Ubuntu-22.04" --busid 8-1
```

### 문제 4: 여러 번 시도 후에도 안 되는 경우

완전히 초기화 후 재시도:
```powershell
# 1. 모든 연결 해제
usbipd detach --busid 8-1
usbipd unbind --busid 8-1

# 2. WSL 종료
wsl --shutdown

# 3. 잠시 대기
Start-Sleep -Seconds 5

# 4. 다시 시작
usbipd bind --busid 8-1
wsl echo "WSL restarted"
Start-Sleep -Seconds 3
usbipd attach --wsl Ubuntu-22.04 --busid 8-1 --auto-attach
```

## WSL에서 확인 (WSL 터미널)

연결이 성공했는지 확인:
```bash
# USB 디바이스 확인
lsusb

# HumiroThermal 확인
lsusb | grep -i "1e4e\|humiro"

# 또는 전체 목록에서 찾기
lsusb -v | grep -i humiro
```

## 자동 재연결 설정

재부팅 후에도 자동으로 연결되도록:
```powershell
# auto-attach 옵션 사용
usbipd attach --wsl Ubuntu-22.04 --busid 8-1 --auto-attach
```

## 참고 사항

1. **Windows 11 권장**: WSL2 USB 지원은 Windows 11에서 더 안정적입니다.
2. **최신 버전 사용**: USBIPD와 WSL을 최신 버전으로 업데이트하세요.
3. **권한 확인**: PowerShell을 관리자 권한으로 실행해야 합니다.
4. **서비스 실행**: USBIPD 서비스가 Windows에서 실행 중이어야 합니다.


