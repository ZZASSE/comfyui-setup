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

## 워크플로우 대응

| 워크플로우 | 모델 | 용도 |
| --- | --- | --- |
| `workflows/wan2.2_5b_i2v.json` | 5B | 빠른 실험, 24fps·최대 121프레임 |
| `workflows/wan2.2_14b_i2v.json` | 14B fp8 + 4-step LoRA | 고품질 동작, 16fps·81프레임 |

## 보류/후보

- **Mage Flow** (Microsoft, 이미지 생성·편집 4B급): I2V 시작 이미지 제작용으로 궁합 좋음.
  int8 약 12GB / bf16 약 16GB. 사용자 결정 보류 (2026-08-20).
