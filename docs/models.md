# 모델 목록·경로 메모

## 선정 결과 (2026-08-20 확정)

**Wan 2.2 TI2V 5B** — 16GB VRAM(RTX 5080)에서 여유롭게 도는 T2V+I2V 겸용 경량 모델.
1280×704 / 24fps / 최대 121프레임. ComfyUI 공식 템플릿 워크플로우 지원, LoRA 학습(musubi-tuner 등) 가능.
출처는 모두 [Comfy-Org/Wan_2.2_ComfyUI_Repackaged](https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged) (Hugging Face).

다운로드: `scripts\download_models.ps1` (이어받기·크기 검증 포함)

## 사용 모델

| 역할 | 파일 | 크기 | 설치 경로 |
| --- | --- | --- | --- |
| Diffusion 본체 | `wan2.2_ti2v_5B_fp16.safetensors` | 9.3GB | `C:\comfyui\ComfyUI\models\diffusion_models\` |
| VAE | `wan2.2_vae.safetensors` | 1.3GB | `C:\comfyui\ComfyUI\models\vae\` |
| 텍스트 인코더 | `umt5_xxl_fp8_e4m3fn_scaled.safetensors` | 6.3GB | `C:\comfyui\ComfyUI\models\text_encoders\` |

## 이후 확장: Wan 2.2 I2V 14B (fp8)

품질을 올릴 때 같은 저장소에서 아래만 추가하면 된다 (텍스트 인코더는 공통 재사용, VAE는 `wan_2.1_vae.safetensors` 추가 필요):

- `diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors` (13.3GB)
- `diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors` (13.3GB)
- `vae/wan_2.1_vae.safetensors` (0.2GB)
- (선택) 4-step 고속화 LoRA: `loras/wan2.2_i2v_lightx2v_4steps_lora_v1_{high,low}_noise.safetensors`

16GB VRAM에서는 fp8 + 오프로딩(block swap) 전제.
