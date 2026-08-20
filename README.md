# comfyui-setup

Wan 계열 image-to-video 모델을 로컬(Windows)에서 돌리기 위한 **환경 재현 저장소**.
빈 PC에서 이 repo를 clone 후 스크립트를 실행하면 ComfyUI + 커스텀 노드 + 모델 다운로드까지
자동으로 복원되는 것을 목표로 한다.

## 대상 환경

- Windows 11
- NVIDIA RTX 5080 (VRAM 16GB), RAM 64GB
- ComfyUI 본체·모델·생성물 설치 경로: `C:\comfyui` (repo 밖)

## 목표

1. 이미지 + 프롬프트 → 영상 생성 (Wan 경량 I2V 모델, fp8 등 16GB 최적화 전제)
2. 이후 같은 Wan 계열로 LoRA 학습·적용까지 확장 (14B 확장 가능한 구성 유지)

## 재현 방법

> 각 단계는 진행하면서 채워진다.

### 1. ComfyUI 설치

```powershell
powershell -ExecutionPolicy Bypass -File scripts\install_comfyui.ps1
```

- ComfyUI Windows Portable(NVIDIA, 버전 고정: 스크립트의 `$Version` 참조, 약 2GB)을 받아
  `C:\comfyui` 에 설치한다. 내장 Python + PyTorch(CUDA) 포함이라 별도 Python 설치 불필요.
- 압축 해제는 7-Zip이 있으면 사용, 없으면 Windows 내장 `tar` 로 시도한다.

실행:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\run_comfyui.ps1
```

브라우저에서 `http://127.0.0.1:8188` 접속.

### 2. Wan 모델 다운로드

```powershell
powershell -ExecutionPolicy Bypass -File scripts\download_models.ps1
```

- Wan 2.2 TI2V **5B**(약 17GB)와 I2V **14B fp8 + 4-step LoRA**(약 31GB)를 Hugging Face에서
  받아 `C:\comfyui\ComfyUI\models\` 아래에 배치한다. 중단돼도 재실행하면 이어받는다.
- 모델 목록은 [docs/models.md](docs/models.md) 참조.

### 2-1. 커스텀 노드 설치 (프레임 보간)

```powershell
powershell -ExecutionPolicy Bypass -File scripts\install_custom_nodes.ps1
```

- ComfyUI-Frame-Interpolation(RIFE)을 설치한다. 14B 워크플로우의 16fps 출력을
  32fps로 보간하는 데 쓰인다 (보간 모델 ~50MB는 첫 사용 시 자동 다운로드).
- 설치 후 ComfyUI를 재시작하고, 열려 있던 브라우저 탭도 새로고침해야 노드가 인식된다.

### 3. 워크플로우 로드 및 생성

1. `scripts\run_comfyui.ps1` 로 서버 실행 후 브라우저에서 `http://127.0.0.1:8188` 접속
2. 워크플로우 JSON을 화면에 드래그해 로드 (둘 다 공식 템플릿 기반):
   - [workflows/wan2.2_5b_i2v.json](workflows/wan2.2_5b_i2v.json) — 5B, 빠른 실험용 (24fps, 최대 121프레임)
   - [workflows/wan2.2_14b_i2v.json](workflows/wan2.2_14b_i2v.json) — 14B 고품질 (16fps, 81프레임≈5초,
     4-step LoRA 기본 ON. 서브그래프의 `enable_turbo_mode`를 끄면 20스텝 고품질 모드)
   - [workflows/wan2.2_14b_i2v_10s.json](workflows/wan2.2_14b_i2v_10s.json) — 14B **10초** (2구간 이어붙이기)
   - [workflows/wan2.2_14b_i2v_20s.json](workflows/wan2.2_14b_i2v_20s.json) — 14B **20초** (4구간 이어붙이기)

   이어붙이기 버전은 5초 클립을 자동 생성·연결한다 (각 구간 마지막 프레임 → 다음 구간 시작
   이미지). 구간별 프롬프트 노드가 따로 있어 시간대마다 다른 동작을 지시할 수 있다.
   생성 시간은 구간 수에 비례 (1구간 약 4분). 구간이 늘수록 색감·디테일 표류가 누적될 수 있다.
3. **LoadImage** 노드에 시작 이미지 업로드 → 긍정 프롬프트 입력 → **Queue** 실행
4. 결과는 `C:\comfyui\ComfyUI\output\video\` 에 mp4로 저장됨

기본 설정: 24fps, 121프레임(약 5초), KSampler 20 steps / cfg 5 / uni_pc.

- **해상도는 업로드한 이미지의 가로세로비에 자동으로 맞는다**: LoadImage 뒤의
  `ImageScaleToTotalPixels`(0.9MP, 32배수) → `GetImageSize` 체인이 소스 비율을 유지한
  최적 해상도를 계산해 latent에 전달한다. 수동 조절이 필요하면 이 두 노드를 지우고
  Wan22ImageToVideoLatent의 width/height를 직접 입력.
- 길이는 **Wan22ImageToVideoLatent**의 `length` (4의 배수+1, 121이 학습 상한 ≈ 5초.
  49≈2초 기준 RTX 5080에서 약 2분 소요, VRAM 여유 충분).

## repo 구조

```
scripts/     설치·다운로드 스크립트
workflows/   ComfyUI 워크플로우 JSON
docs/        모델 목록·경로 메모
```

## repo 규칙

- **커밋하는 것**: 스크립트, 워크플로우 JSON, 모델 목록·경로 메모, README
- **커밋 금지**: ComfyUI 본체, 모델 가중치, 생성된 영상·이미지 (`.gitignore` 등록됨)
