# WSL USB 연결 불안정 문제 해결

## 문제: USB 연결이 계속 끊어지거나 연결 소리가 반복되는 경우

이 문제는 WSL에서 USBIP 클라이언트가 제대로 설정되지 않아서 발생합니다.

## 해결 방법

### 1. WSL에서 USBIP 도구 설치

```bash
sudo apt-get update
sudo apt-get install -y usbip hwdata usb.ids usbutils
```

### 2. USBIP 커널 모듈 로드

```bash
sudo modprobe usbip-core
sudo modprobe usbip-host
```

### 3. Windows에서 USB 디바이스를 "Shared" 상태로 만들기만

PowerShell(관리자 권한)에서:

```powershell
# bind만 하고 attach는 하지 않음
usbipd bind --busid 8-1
```

### 4. WSL에서 수동으로 연결

WSL 터미널에서:

```bash
# Windows 호스트 IP 확인
export WSL_HOST_IP=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')

# USB 디바이스 연결 (BUSID는 Windows에서 확인한 값: 8-1)
sudo usbip attach -r $WSL_HOST_IP -b 8-1
```

### 5. 연결 확인

```bash
lsusb
# 1e4e:0100 HumiroThermal이 보여야 함
```

## 자동화 스크립트

`connect_usb.sh` 파일을 만들어서 매번 쉽게 연결할 수 있습니다:

```bash
#!/bin/bash
WSL_HOST_IP=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')
echo "Connecting USB device from Windows host: $WSL_HOST_IP"
sudo usbip attach -r $WSL_HOST_IP -b 8-1
lsusb | grep -i "1e4e\|humiro"
```

실행:
```bash
chmod +x connect_usb.sh
sudo ./connect_usb.sh
```

## 연결이 계속 끊어지는 경우

1. **USBIP 서비스 확인**: Windows에서 USBIPD 서비스가 실행 중인지 확인
2. **방화벽 확인**: Windows 방화벽이 USBIP 연결을 차단하지 않는지 확인
3. **다른 USB 포트 사용**: USB 3.0 포트를 사용하는 것이 더 안정적
4. **USB 케이블 교체**: 케이블 문제일 수 있음

## Windows에서 자동 재연결

PowerShell 스크립트를 만들어서 주기적으로 연결을 확인하고 재연결할 수 있습니다.



