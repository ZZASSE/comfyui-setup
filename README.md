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

_(예정 — `scripts/` 의 설치 스크립트 실행)_

### 2. Wan 모델 다운로드

_(예정 — 모델 선정 후 `scripts/` 의 다운로드 스크립트 실행. 모델 목록은 [docs/models.md](docs/models.md))_

### 3. 워크플로우 로드 및 생성

_(예정 — `workflows/` 의 JSON을 ComfyUI에 로드)_

## repo 구조

```
scripts/     설치·다운로드 스크립트
workflows/   ComfyUI 워크플로우 JSON
docs/        모델 목록·경로 메모
```

## repo 규칙

- **커밋하는 것**: 스크립트, 워크플로우 JSON, 모델 목록·경로 메모, README
- **커밋 금지**: ComfyUI 본체, 모델 가중치, 생성된 영상·이미지 (`.gitignore` 등록됨)
