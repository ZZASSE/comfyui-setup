# Wan 2.2 TI2V 5B 모델 다운로드 스크립트 (Comfy-Org 공식 리패키지, Hugging Face)
# 사용법:  powershell -ExecutionPolicy Bypass -File scripts\download_models.ps1
# 파일 목록·역할은 docs\models.md 참조. 이미 받은 파일은 건너뛰고, 중단된 다운로드는 이어받는다.

param(
    [string]$InstallDir = "C:\comfyui"
)

$ErrorActionPreference = "Stop"
$ModelsDir = Join-Path $InstallDir "ComfyUI\models"
if (-not (Test-Path $ModelsDir)) { throw "$ModelsDir 없음 — 먼저 scripts\install_comfyui.ps1 을 실행하세요." }

$HF = "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files"

# 대상 파일: 상대경로(= models\ 아래 저장 위치), URL, 예상 크기(bytes, 완결성 검사용)
$Files = @(
    @{ Path = "diffusion_models\wan2.2_ti2v_5B_fp16.safetensors";        Url = "$HF/diffusion_models/wan2.2_ti2v_5B_fp16.safetensors";        Size = 9999658848 }
    @{ Path = "vae\wan2.2_vae.safetensors";                              Url = "$HF/vae/wan2.2_vae.safetensors";                              Size = 1409400960 }
    @{ Path = "text_encoders\umt5_xxl_fp8_e4m3fn_scaled.safetensors";    Url = "$HF/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors";    Size = 6735906897 }
)

foreach ($f in $Files) {
    $dest = Join-Path $ModelsDir $f.Path
    New-Item -ItemType Directory -Force (Split-Path $dest) | Out-Null

    if ((Test-Path $dest) -and (Get-Item $dest).Length -eq $f.Size) {
        Write-Host "[skip] $($f.Path)" -ForegroundColor Yellow
        continue
    }
    Write-Host "[down] $($f.Path)  ($([math]::Round($f.Size/1GB,1)) GB)"
    # -C - : 중단된 다운로드 이어받기
    curl.exe -L --retry 3 -C - -o $dest $f.Url
    if ($LASTEXITCODE -ne 0) { throw "다운로드 실패: $($f.Url) (curl exit $LASTEXITCODE)" }
    $actual = (Get-Item $dest).Length
    if ($actual -ne $f.Size) { throw "크기 불일치: $($f.Path) — 예상 $($f.Size), 실제 $actual" }
}

Write-Host "완료: 모든 모델이 $ModelsDir 에 준비됨" -ForegroundColor Green
