# ComfyUI Windows Portable 설치 스크립트
# 사용법:  powershell -ExecutionPolicy Bypass -File scripts\install_comfyui.ps1
# 결과 구조:
#   C:\comfyui\ComfyUI\          (본체, models\ 포함)
#   C:\comfyui\python_embeded\   (내장 Python + PyTorch CUDA)

param(
    [string]$InstallDir = "C:\comfyui",
    # 재현성을 위해 버전 고정. 업그레이드 시 이 값만 갱신.
    [string]$Version = "v0.33.1"
)

$ErrorActionPreference = "Stop"
$AssetName = "ComfyUI_windows_portable_nvidia.7z"
$Url = "https://github.com/Comfy-Org/ComfyUI/releases/download/$Version/$AssetName"
$Archive = Join-Path $env:TEMP $AssetName

if (Test-Path (Join-Path $InstallDir "ComfyUI\main.py")) {
    Write-Host "[skip] 이미 설치되어 있습니다: $InstallDir" -ForegroundColor Yellow
    exit 0
}

# 1. 다운로드 (~2GB)
if (-not (Test-Path $Archive)) {
    Write-Host "[1/3] 다운로드: $Url"
    curl.exe -L --retry 3 -o "$Archive.part" $Url
    if ($LASTEXITCODE -ne 0) { throw "다운로드 실패 (curl exit $LASTEXITCODE)" }
    Move-Item "$Archive.part" $Archive
} else {
    Write-Host "[1/3] 다운로드 생략 (이미 존재): $Archive"
}

# 2. 압축 해제 — 7z.exe가 있으면 사용, 없으면 Windows 내장 tar(bsdtar)로 시도
Write-Host "[2/3] 압축 해제 → $InstallDir"
New-Item -ItemType Directory -Force $InstallDir | Out-Null
$SevenZip = Get-Command 7z.exe -ErrorAction SilentlyContinue
if (-not $SevenZip -and (Test-Path "$env:ProgramFiles\7-Zip\7z.exe")) {
    $SevenZip = @{ Source = "$env:ProgramFiles\7-Zip\7z.exe" }
}
if ($SevenZip) {
    & $SevenZip.Source x $Archive "-o$InstallDir" -y | Select-Object -Last 3
    if ($LASTEXITCODE -ne 0) { throw "7z 압축 해제 실패" }
} else {
    tar.exe -xf $Archive -C $InstallDir
    if ($LASTEXITCODE -ne 0) { throw "tar 압축 해제 실패 — 7-Zip(https://www.7-zip.org) 설치 후 재실행하세요" }
}

# 3. 구조 정리: ComfyUI_windows_portable\* 를 $InstallDir 바로 아래로 이동
$Inner = Join-Path $InstallDir "ComfyUI_windows_portable"
if (Test-Path $Inner) {
    Get-ChildItem $Inner | Move-Item -Destination $InstallDir
    Remove-Item $Inner
}
if (-not (Test-Path (Join-Path $InstallDir "ComfyUI\main.py"))) { throw "설치 확인 실패: ComfyUI\main.py 없음" }
Remove-Item $Archive -ErrorAction SilentlyContinue

Write-Host "[3/3] 설치 완료: $InstallDir" -ForegroundColor Green
Write-Host "실행:  powershell -ExecutionPolicy Bypass -File scripts\run_comfyui.ps1"
