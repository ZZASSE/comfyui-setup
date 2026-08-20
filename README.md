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

- Wan 2.2 TI2V 5B 구성(본체 + VAE + 텍스트 인코더, 약 17GB)을 Hugging Face에서 받아
  `C:\comfyui\ComfyUI\models\` 아래에 배치한다. 중단돼도 재실행하면 이어받는다.
- 모델 목록·확장 계획은 [docs/models.md](docs/models.md) 참조.

### 3. 워크플로우 로드 및 생성

1. `scripts\run_comfyui.ps1` 로 서버 실행 후 브라우저에서 `http://127.0.0.1:8188` 접속
2. [workflows/wan2.2_5b_i2v.json](workflows/wan2.2_5b_i2v.json) 을 화면에 드래그해 로드
   (공식 Wan 2.2 5B TI2V 템플릿 기반, I2V용으로 LoadImage 활성화됨)
3. **LoadImage** 노드에 시작 이미지 업로드 → 긍정 프롬프트 입력 → **Queue** 실행
4. 결과는 `C:\comfyui\ComfyUI\output\video\` 에 mp4로 저장됨

기본 설정: 1280×704, 24fps, 121프레임(약 5초), KSampler 20 steps / cfg 5 / uni_pc.
길이·해상도는 **Wan22ImageToVideoLatent** 노드에서 조절 (49프레임≈2초 테스트 기준
RTX 5080에서 약 2분 소요, VRAM 여유 충분).

## repo 구조

```
scripts/     설치·다운로드 스크립트
workflows/   ComfyUI 워크플로우 JSON
docs/        모델 목록·경로 메모
```

## repo 규칙

- **커밋하는 것**: 스크립트, 워크플로우 JSON, 모델 목록·경로 메모, README
- **커밋 금지**: ComfyUI 본체, 모델 가중치, 생성된 영상·이미지 (`.gitignore` 등록됨)
