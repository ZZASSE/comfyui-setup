# 모델 목록·경로 메모

## 선정 결과

- **Wan 2.2 TI2V 5B** (2026-08-20 확정) — T2V+I2V 겸용 경량 모델. 16GB VRAM에서 여유롭게 동작.
  1280×704 / 24fps / 최대 121프레임. 빠른 실험용.
- **Wan 2.2 I2V 14B fp8** (2026-08-20 추가) — 동작 품질·프롬프트 준수 상위 모델.
  high/low noise 2-모델 구조, 16fps, 81프레임(5초). 16GB VRAM에서는 자동 RAM 오프로딩 +
  lightx2v 4-step LoRA(스텝 20→4)로 속도를 방어하는 구성이 기본.

출처는 모두 [Comfy-Org/Wan_2.2_ComfyUI_Repackaged](https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged) (Hugging Face).
다운로드: `scripts\download_models.ps1` (이어받기·크기 검증 포함, 총 약 48GB)

## 사용 모델

| 역할 | 파일 | 크기 | 설치 경로 |
| --- | --- | --- | --- |
| 5B 본체 | `wan2.2_ti2v_5B_fp16.safetensors` | 9.3GB | `C:\comfyui\ComfyUI\models\diffusion_models\` |
| 5B VAE | `wan2.2_vae.safetensors` | 1.3GB | `C:\comfyui\ComfyUI\models\vae\` |
| 14B 본체 (high noise) | `wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors` | 13.3GB | `C:\comfyui\ComfyUI\models\diffusion_models\` |
| 14B 본체 (low noise) | `wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors` | 13.3GB | `C:\comfyui\ComfyUI\models\diffusion_models\` |
| 14B VAE | `wan_2.1_vae.safetensors` | 0.2GB | `C:\comfyui\ComfyUI\models\vae\` |
| 14B 4-step LoRA (high) | `wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors` | 1.2GB | `C:\comfyui\ComfyUI\models\loras\` |
| 14B 4-step LoRA (low) | `wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors` | 1.2GB | `C:\comfyui\ComfyUI\models\loras\` |
| 텍스트 인코더 (공통) | `umt5_xxl_fp8_e4m3fn_scaled.safetensors` | 6.3GB | `C:\comfyui\ComfyUI\models\text_encoders\` |

## Mage Flow edit (2026-08-21 추가)

I2V 2단계 파이프라인용 이미지 편집 모델 (Microsoft, 4B급 int8).
원본 사진에 인물 추가·배경 교체 등을 먼저 편집한 뒤, 그 결과를 Wan I2V의 시작 이미지로 쓴다.
출처: [Comfy-Org/Mage-Flow](https://huggingface.co/Comfy-Org/Mage-Flow)

| 역할 | 파일 | 크기 | 설치 경로 |
| --- | --- | --- | --- |
| 편집 본체 (int8) | `mage_flow_edit_int8_convrot.safetensors` | 3.9GB | `...\models\diffusion_models\` |
| 텍스트 인코더 | `qwen3vl_4b_bf16.safetensors` | 8.3GB | `...\models\text_encoders\` |
| VAE | `mage_flow_vae_bf16.safetensors` | 0.3GB | `...\models\vae\` |

## 커스텀 노드 (scripts\install_custom_nodes.ps1)

- **ComfyUI-Frame-Interpolation** — RIFE 보간 (16→32fps). 가중치 ~50MB 첫 사용 시 자동 다운로드
- **ComfyUI-Florence2** — 업로드 사진 자동 캡셔닝 (Florence-2-large ~1.5GB 첫 사용 시 자동 다운로드)

## 워크플로우 대응

| 워크플로우 | 모델 | 용도 |
| --- | --- | --- |
| `workflows/wan2.2_5b_i2v.json` | 5B | 빠른 실험, 24fps·최대 121프레임 |
| `workflows/wan2.2_14b_i2v.json` | 14B fp8 + 4-step LoRA | 고품질 5초, 32fps 보간 |
| `workflows/wan2.2_14b_i2v_10s.json` | 14B + Florence-2 | 10초(2구간), 자동 캡션 + 구간별 정밀 모드 |
| `workflows/wan2.2_14b_i2v_20s.json` | 14B + Florence-2 | 20초(4구간), 자동 캡션 + 구간별 정밀 모드 |
| `workflows/mage_edit.json` | Mage Flow edit | I2V 시작 이미지 편집 (인물 추가 등) |
