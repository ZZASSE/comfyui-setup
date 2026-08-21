# 커스텀 노드 설치 스크립트 — ComfyUI-Frame-Interpolation (RIFE 프레임 보간, 16fps→32fps)
# 사용법:  powershell -ExecutionPolicy Bypass -File scripts\install_custom_nodes.ps1
# 설치 후 ComfyUI 재시작 필요. RIFE 모델 가중치(~50MB)는 첫 사용 시 자동 다운로드된다.

param(
    [string]$InstallDir = "C:\comfyui"
)

$ErrorActionPreference = "Stop"
$CustomNodes = Join-Path $InstallDir "ComfyUI\custom_nodes"
$Python = Join-Path $InstallDir "python_embeded\python.exe"
if (-not (Test-Path $CustomNodes)) { throw "$CustomNodes 없음 — 먼저 scripts\install_comfyui.ps1 을 실행하세요." }

$Nodes = @(
    @{ Name = "ComfyUI-Frame-Interpolation"; Zip = "https://github.com/Fannovel16/ComfyUI-Frame-Interpolation/archive/refs/heads/main.zip" }
    # 이미지 자동 캡셔닝 (업로드 사진 → 배경 묘사 자동 생성. 모델 ~1GB는 첫 사용 시 자동 다운로드)
    @{ Name = "ComfyUI-Florence2"; Zip = "https://github.com/kijai/ComfyUI-Florence2/archive/refs/heads/main.zip" }
)

foreach ($n in $Nodes) {
    $dest = Join-Path $CustomNodes $n.Name
    if (Test-Path $dest) {
        Write-Host "[skip] $($n.Name)" -ForegroundColor Yellow
        continue
    }
    Write-Host "[down] $($n.Name)"
    $zip = Join-Path $env:TEMP "$($n.Name).zip"
    curl.exe -L --retry 3 -o $zip $n.Zip
    if ($LASTEXITCODE -ne 0) { throw "다운로드 실패: $($n.Zip)" }
    # 임시 폴더에 풀고 zip 루트 폴더(…-main)를 정식 이름으로 이동
    $tmp = Join-Path $env:TEMP "extract_$($n.Name)"
    if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force }
    Expand-Archive -Path $zip -DestinationPath $tmp -Force
    $extracted = Get-ChildItem $tmp -Directory | Select-Object -First 1
    if (-not $extracted) { throw "압축 해제 실패: $($n.Name)" }
    Move-Item $extracted.FullName $dest
    Remove-Item $tmp, $zip -Recurse -Force -ErrorAction SilentlyContinue
    if (-not (Test-Path $dest)) { throw "설치 확인 실패: $dest 없음" }

    $installer = Join-Path $dest "install.py"
    if (Test-Path $installer) {
        Write-Host "[deps] $($n.Name) 의존성 설치"
        & $Python $installer
        if ($LASTEXITCODE -ne 0) { throw "의존성 설치 실패: $($n.Name)" }
    }
}

Write-Host "완료: 커스텀 노드 설치됨. ComfyUI를 재시작하세요." -ForegroundColor Green
