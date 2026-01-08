# WSL2 USB 연결 안정화 가이드

## WSL2에서는 일반적인 usbip 클라이언트가 작동하지 않을 수 있습니다

WSL2는 Microsoft 커널을 사용하므로, Linux의 표준 `usbip` 도구가 아닌 Windows의 USBIPD 서비스를 통해서만 연결이 가능합니다.

## 올바른 연결 방법

### 1. Windows PowerShell(관리자 권한)에서 한 번만 실행:

```powershell
# 1단계: USB 디바이스를 "Shared" 상태로 만들기
usbipd bind --busid 8-1

# 2단계: WSL에 연결 (이것만 하면 됨!)
usbipd attach --wsl --busid 8-1
```

### 2. 연결 확인:

**PowerShell에서:**
```powershell
usbipd list
```
`8-1`이 `Attached` 상태로 보이면 성공입니다.

**WSL 터미널에서:**
```bash
lsusb | grep -i "1e4e\|humiro"
```

### 3. 연결이 끊어지는 경우

- **PowerShell에서 `attach`를 반복 실행하지 마세요!**
- 한 번만 실행하면 됩니다.
- 연결이 끊어지면 PowerShell에서 다시 실행하세요 (WSL에서 직접 연결할 수 없습니다).

## 연결이 불안정한 경우 해결 방법

### 방법 1: USBIPD 서비스 재시작

PowerShell(관리자 권한)에서:

```powershell
# USBIPD 서비스 재시작
usbipd stop
usbipd start

# 다시 연결
usbipd bind --busid 8-1
usbipd attach --wsl --busid 8-1
```

### 방법 2: WSL 재시작 없이 재연결

```powershell
# 기존 연결 해제
usbipd detach --busid 8-1

# 다시 연결
usbipd attach --wsl --busid 8-1
```

### 방법 3: 자동 재연결 스크립트 (Windows)

PowerShell 스크립트를 만들어서 주기적으로 연결 상태를 확인하고 재연결할 수 있습니다.

## 주의사항

1. **Windows에서 `attach`를 여러 번 실행하지 마세요!** 이것이 "연결 소리가 계속 발생"하는 원인입니다.
2. **WSL에서 직접 `usbip attach` 명령을 사용할 수 없습니다.** WSL2에서는 Windows의 USBIPD를 통해서만 가능합니다.
3. **USBIPD 서비스가 실행 중이어야 합니다.** Windows 시작 시 자동으로 실행됩니다.

## 확인 명령

**Windows PowerShell:**
```powershell
# USBIPD 서비스 상태 확인
usbipd list

# 특정 디바이스 정보 확인
usbipd list --busid 8-1
```

**WSL 터미널:**
```bash
# USB 디바이스 확인
lsusb

# 특정 디바이스 확인
lsusb | grep 1e4e
```



