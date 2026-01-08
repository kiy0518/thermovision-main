#!/usr/bin/env bash

echo "=== WSL 환경 설정 스크립트 ==="
echo ""

# USBIP 도구 설치
echo "1. USBIP 도구 설치 중..."
sudo apt-get update
sudo apt-get install -y usbip hwdata usb.ids usbutils

# USBIP 커널 모듈 로드
echo ""
echo "2. USBIP 커널 모듈 로드 중..."
sudo modprobe usbip-core 2>/dev/null || echo "   경고: usbip-core 모듈을 로드할 수 없습니다"
sudo modprobe usbip-host 2>/dev/null || echo "   경고: usbip-host 모듈을 로드할 수 없습니다"

# 기존 Linux 설정 실행
echo ""
echo "3. 기본 Linux 설정 실행 중..."
if [ -f setup_linux.sh ]; then
    chmod +x setup_linux.sh
    ./setup_linux.sh
else
    echo "   setup_linux.sh를 찾을 수 없습니다"
fi

# Python 패키지 설치
echo ""
echo "4. Python 패키지 설치 중..."
if [ -f setup_python.sh ]; then
    chmod +x setup_python.sh
    ./setup_python.sh
else
    echo "   setup_python.sh를 찾을 수 없습니다"
    echo "   수동으로 설치: pip3 install PyQt5 opencv-python psutil h5py tifffile"
fi

echo ""
echo "=== 설정 완료 ==="
echo ""
echo "다음 단계:"
echo "1. Windows PowerShell에서 USBIPD를 설치하고 USB 디바이스를 연결하세요"
echo "2. ./test_usb_connection.sh를 실행하여 연결을 확인하세요"
echo "3. 자세한 내용은 WSL_SETUP.md를 참조하세요"

