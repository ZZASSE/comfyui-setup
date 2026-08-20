# ComfyUI 실행 (NVIDIA GPU 모드)
# 사용법:  powershell -ExecutionPolicy Bypass -File scripts\run_comfyui.ps1
# 접속:    http://127.0.0.1:8188

param(
    [string]$InstallDir = "C:\comfyui"
)

$Python = Join-Path $InstallDir "python_embeded\python.exe"
$Main = Join-Path $InstallDir "ComfyUI\main.py"
if (-not (Test-Path $Python) -or -not (Test-Path $Main)) {
    throw "ComfyUI가 $InstallDir 에 없습니다. 먼저 scripts\install_comfyui.ps1 을 실행하세요."
}

Set-Location $InstallDir
& $Python -s $Main --windows-standalone-build
