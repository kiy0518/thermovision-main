# FFC (Flat Field Correction) 모드 설명

## FFC란?

**FFC (Flat Field Correction, 평면장 보정)**는 열화상 카메라에서 매우 중요한 보정 기능입니다.

### 왜 필요한가?

열화상 센서의 각 픽셀은 제조 과정에서 미세한 차이가 있어서, 같은 온도의 물체를 촬영해도 픽셀마다 다른 값을 보여줄 수 있습니다. FFC는 이러한 픽셀 간의 불균일성을 보정하여 정확한 온도 측정을 가능하게 합니다.

### FFC 동작 원리

1. **셔터(Shutter) 사용**: FFC를 수행할 때는 셔터를 닫아서 센서에 균일한 온도의 기준 이미지를 제공합니다.
2. **보정 데이터 생성**: 기준 이미지를 기반으로 각 픽셀의 보정 계수를 계산합니다.
3. **실시간 보정**: 이후 촬영되는 모든 이미지에 이 보정 계수를 적용하여 정확한 온도 측정을 합니다.

## 코드에서 구현된 FFC 모드

프로젝트에는 세 가지 FFC 모드가 구현되어 있습니다:

### 1. MANUAL (수동 모드)

**설명**: 사용자가 직접 "Perform FFC" 버튼을 눌러서 FFC를 실행합니다.

**특징**:
- 사용자가 원할 때 수동으로 FFC 수행
- FFC 수행 시 비디오가 일시적으로 멈춤 (`videoFreezeDuringFFC = 1`)
- 셔터 모드: Manual (0)

**사용 시나리오**:
- 정확한 측정이 필요한 순간에 수동으로 보정
- 자동 보정이 원하지 않을 때
- 특정 상황에서만 보정이 필요할 때

**코드 위치**: `set_manual_ffc(devh)`, `perform_manual_ffc(devh)`

### 2. AUTO (자동 모드)

**설명**: 센서가 자동으로 주기적으로 FFC를 수행합니다.

**특징**:
- 자동으로 주기적으로 FFC 수행 (기본 주기: 180초 = 3분)
- 온도 변화가 일정 수준 이상일 때 자동으로 FFC 수행
- 셔터 모드: Auto (1)
- `desiredFfcPeriod`: 180000ms (3분)
- `desiredFfcTempDelta`: 150 (온도 변화 임계값)

**사용 시나리오**:
- 일반적인 사용 환경
- 지속적인 모니터링이 필요할 때
- 사용자 개입 없이 자동으로 정확도 유지

**코드 위치**: `set_auto_ffc(devh)`

### 3. EXTERNAL (외부 모드)

**설명**: 외부 신호나 명령에 의해 FFC를 수행합니다.

**특징**:
- 외부 하드웨어나 시스템에서 FFC 트리거
- 셔터 모드: External (2)
- 외부 제어 시스템과 연동 가능

**사용 시나리오**:
- 자동화 시스템과 연동
- 외부 센서나 제어 시스템에서 FFC 제어
- 특정 이벤트 발생 시 FFC 수행

**코드 위치**: `set_external_ffc(devh)`

## FFC 모드 설정 방법

### GUI에서 설정

1. **FFC 모드 선택**: `Set FFC Mode` 콤보박스에서 모드 선택
   - MANUAL
   - AUTO
   - EXTERNAL

2. **수동 FFC 실행**: `Perform FFC` 버튼 클릭 (MANUAL 모드에서)

### 코드에서 설정

```python
from uvctypesParabilis_v2 import *

# 자동 모드 설정
set_auto_ffc(devh)

# 수동 모드 설정
set_manual_ffc(devh)

# 외부 모드 설정
set_external_ffc(devh)

# 수동으로 FFC 실행 (MANUAL 모드에서)
perform_manual_ffc(devh)
```

## FFC 관련 파라미터

코드에서 사용되는 주요 FFC 파라미터:

- **shutterMode**: 셔터 모드 (0=Manual, 1=Auto, 2=External)
- **videoFreezeDuringFFC**: FFC 수행 중 비디오 일시정지 여부
- **ffcDesired**: FFC 수행 필요 여부
- **elapsedTimeSinceLastFfc**: 마지막 FFC 이후 경과 시간 (ms)
- **desiredFfcPeriod**: 자동 FFC 주기 (기본: 180000ms = 3분)
- **desiredFfcTempDelta**: FFC 트리거 온도 변화 임계값 (기본: 150)
- **explicitCmdToOpen**: 명시적 셔터 열기 명령 여부
- **imminentDelay**: FFC 수행 전 지연 시간

## FFC 상태 확인

```python
from uvctypesParabilis_v2 import print_shutter_info

# 현재 FFC/셔터 상태 확인
print_shutter_info(devh)
```

출력 예시:
```
Shutter Info:
 1     shutterMode          (0=Manual, 1=Auto, 2=External)
 0     tempLockoutState
 1     videoFreezeDuringFFC
 0     ffcDesired
 0     elapsedTimeSinceLastFfc
 180000 desiredFfcPeriod
 True  explicitCmdToOpen
 0     desiredFfcTempDelta
 150   imminentDelay
```

## 권장 사용법

### 일반적인 사용
- **AUTO 모드 권장**: 대부분의 경우 자동 모드가 가장 편리하고 정확합니다.

### 정밀 측정이 필요한 경우
- **MANUAL 모드**: 측정 전에 수동으로 FFC를 수행하여 최대 정확도 확보

### 자동화 시스템
- **EXTERNAL 모드**: 외부 시스템과 연동하여 자동으로 FFC 제어

## 주의사항

1. **FFC 수행 중**: 비디오가 일시적으로 멈출 수 있습니다 (약 1-2초)
2. **셔터 소음**: FFC 수행 시 셔터 작동 소리가 날 수 있습니다
3. **주기적 보정**: AUTO 모드에서도 주기적으로 FFC가 수행되므로 정확도가 유지됩니다
4. **온도 변화**: 급격한 온도 변화 시 자동으로 FFC가 수행될 수 있습니다

## 참고

- FLIR Lepton 센서는 일반적으로 3분마다 자동 FFC를 수행하는 것이 권장됩니다
- FFC를 너무 자주 수행하면 셔터 수명에 영향을 줄 수 있습니다
- FFC를 너무 드물게 수행하면 측정 정확도가 떨어질 수 있습니다
