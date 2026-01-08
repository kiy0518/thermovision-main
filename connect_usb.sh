#!/bin/bash

# WSL USB 연결 스크립트
# Windows에서 usbipd bind --busid 8-1 을 먼저 실행한 후
# 이 스크립트를 WSL에서 실행하세요

echo "=== WSL USB 연결 스크립트 ==="
echo ""

# USBIP 도구 확인
if ! command -v usbip &> /dev/null; then
    echo "오류: usbip가 설치되지 않았습니다."
    echo "설치: sudo apt-get install -y usbip hwdata usb.ids usbutils"
    exit 1
fi

# USBIP 커널 모듈 확인 및 로드
echo "1. USBIP 커널 모듈 확인 중..."
if ! lsmod | grep -q usbip_core; then
    echo "   USBIP 모듈 로드 중..."
    sudo modprobe usbip-core
    sudo modprobe usbip-host
    echo "   ✓ USBIP 모듈 로드 완료"
else
    echo "   ✓ USBIP 모듈이 이미 로드되어 있습니다"
fi
echo ""

# Windows 호스트 IP 확인
echo "2. Windows 호스트 IP 확인 중..."
WSL_HOST_IP=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')
if [ -z "$WSL_HOST_IP" ]; then
    echo "   ✗ Windows 호스트 IP를 찾을 수 없습니다"
    exit 1
fi
echo "   ✓ Windows 호스트 IP: $WSL_HOST_IP"
echo ""

# 기존 연결 확인 및 해제 (있으면)
echo "3. 기존 USBIP 연결 확인 중..."
if lsusb | grep -q "1e4e:0100"; then
    echo "   ✓ HumiroThermal이 이미 연결되어 있습니다:"
    lsusb | grep "1e4e:0100"
    echo ""
    read -p "   다시 연결하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "   연결 취소됨"
        exit 0
    fi
    echo "   기존 연결 해제 중..."
    sudo usbip detach -p 0 2>/dev/null || true
    sleep 1
fi
echo ""

# USB 디바이스 연결
BUSID="8-1"
echo "4. USB 디바이스 연결 중 (BUSID: $BUSID)..."
sudo usbip attach -r $WSL_HOST_IP -b $BUSID

if [ $? -eq 0 ]; then
    echo "   ✓ USB 디바이스 연결 성공!"
    sleep 2
    echo ""
    echo "5. 연결 확인 중..."
    if lsusb | grep -q "1e4e:0100"; then
        echo "   ✓ HumiroThermal 디바이스 확인됨:"
        lsusb | grep "1e4e:0100"
        echo ""
        echo "=== 연결 완료 ==="
        echo "이제 애플리케이션을 실행할 수 있습니다:"
        echo "  cd src && python3 FeverDetector.py"
    else
        echo "   ⚠ 디바이스가 보이지 않습니다. 잠시 후 다시 확인하세요"
    fi
else
    echo "   ✗ USB 디바이스 연결 실패"
    echo ""
    echo "다음 사항을 확인하세요:"
    echo "  1. Windows PowerShell에서 'usbipd bind --busid 8-1' 실행했는지"
    echo "  2. Windows 방화벽이 USBIP 연결을 차단하지 않는지"
    echo "  3. Windows에서 'usbipd list'로 상태가 'Shared'인지"
    exit 1
fi



