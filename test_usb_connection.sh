#!/bin/bash

echo "=== WSL USB 연결 테스트 ==="
echo ""

# 1. USBIP 모듈 확인
echo "1. USBIP 커널 모듈 확인:"
if lsmod | grep -q usbip; then
    echo "   ✓ USBIP 모듈이 로드되어 있습니다"
    lsmod | grep usbip
else
    echo "   ✗ USBIP 모듈이 로드되지 않았습니다"
    echo "   다음 명령으로 로드하세요:"
    echo "   sudo modprobe usbip-core"
    echo "   sudo modprobe usbip-host"
fi
echo ""

# 2. lsusb 확인
echo "2. USB 디바이스 확인:"
if command -v lsusb &> /dev/null; then
    USB_DEVICES=$(lsusb 2>/dev/null)
    if [ -n "$USB_DEVICES" ]; then
        echo "   ✓ USB 디바이스가 감지되었습니다:"
        echo "$USB_DEVICES" | sed 's/^/   /'
        # FLIR Lepton 카메라 확인 (Vendor ID: 1e4e)
        if echo "$USB_DEVICES" | grep -q "1e4e"; then
            echo ""
            echo "   ✓ FLIR Lepton 카메라가 감지되었습니다!"
        else
            echo ""
            echo "   ⚠ FLIR Lepton 카메라가 감지되지 않았습니다"
            echo "   Windows에서 USBIPD를 사용하여 USB를 연결했는지 확인하세요"
        fi
    else
        echo "   ✗ USB 디바이스가 감지되지 않았습니다"
    fi
else
    echo "   ✗ lsusb가 설치되지 않았습니다"
    echo "   설치: sudo apt-get install usbutils"
fi
echo ""

# 3. libuvc 확인
echo "3. libuvc 라이브러리 확인:"
if ldconfig -p 2>/dev/null | grep -q libuvc; then
    echo "   ✓ libuvc가 설치되어 있습니다:"
    ldconfig -p | grep libuvc | sed 's/^/   /'
else
    echo "   ✗ libuvc가 설치되지 않았습니다"
    echo "   ./setup_linux.sh를 실행하여 설치하세요"
fi
echo ""

# 4. Python 패키지 확인
echo "4. Python 패키지 확인:"
python3 -c "import cv2; print('   ✓ opencv-python 설치됨')" 2>/dev/null || echo "   ✗ opencv-python 미설치"
python3 -c "import PyQt5; print('   ✓ PyQt5 설치됨')" 2>/dev/null || echo "   ✗ PyQt5 미설치"
python3 -c "import h5py; print('   ✓ h5py 설치됨')" 2>/dev/null || echo "   ✗ h5py 미설치"
python3 -c "import tifffile; print('   ✓ tifffile 설치됨')" 2>/dev/null || echo "   ✗ tifffile 미설치"
python3 -c "import psutil; print('   ✓ psutil 설치됨')" 2>/dev/null || echo "   ✗ psutil 미설치"
echo ""

# 5. uvctypes 모듈 테스트
echo "5. uvctypes 모듈 테스트:"
cd "$(dirname "$0")/src" 2>/dev/null || cd src 2>/dev/null
if python3 -c "from uvctypesParabilis_v2 import *; print('   ✓ uvctypesParabilis_v2 모듈 로드 성공')" 2>/dev/null; then
    echo "   ✓ uvctypesParabilis_v2 모듈이 정상적으로 로드됩니다"
else
    echo "   ✗ uvctypesParabilis_v2 모듈 로드 실패"
    echo "   libuvc가 제대로 설치되었는지 확인하세요"
fi
echo ""

# 6. udev 규칙 확인
echo "6. udev 규칙 확인:"
if [ -f /etc/udev/rules.d/99-pt1.rules ]; then
    echo "   ✓ udev 규칙 파일이 존재합니다:"
    cat /etc/udev/rules.d/99-pt1.rules | sed 's/^/   /'
else
    echo "   ✗ udev 규칙 파일이 없습니다"
    echo "   ./setup_linux.sh를 실행하여 생성하세요"
fi
echo ""

echo "=== 테스트 완료 ==="
echo ""
echo "모든 항목이 정상이면 다음 명령으로 애플리케이션을 실행할 수 있습니다:"
echo "  cd src && python3 FeverDetector.py"

