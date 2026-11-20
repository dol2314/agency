#Requires -Version 5.1
<#
.SYNOPSIS
  agency-agents 를 윈도우의 Claude Code 에이전트 폴더에 설치하거나 갱신합니다.

.DESCRIPTION
  기본값은 전역 설치입니다 — %USERPROFILE%\.claude\agents 에 넣으므로
  모든 프로젝트(복지카드·dogmap·소식지 등)의 Claude Code 세션에서 보입니다.

  다시 실행하면 저장소를 최신으로 받아 갱신합니다. 여러 번 실행해도 안전합니다.

.PARAMETER ProjectOnly
  전역이 아니라 현재 폴더의 .claude\agents 에만 설치합니다.

.PARAMETER Branch
  받을 브랜치. 비워 두면 저장소 기본 브랜치를 씁니다.

.EXAMPLE
  .\install-windows.ps1
  전역(%USERPROFILE%\.claude\agents)에 설치·갱신합니다.

.EXAMPLE
  .\install-windows.ps1 -ProjectOnly
  현재 폴더에만 설치합니다.

.NOTES
  설치 후에는 새 Claude Code 세션을 열어야 적용됩니다.
  에이전트 목록은 세션이 시작할 때 한 번 읽습니다.
#>
[CmdletBinding()]
param(
    [string] $Repo   = 'https://github.com/dol2314/agency.git',
    [string] $Branch = '',
    [string] $SrcDir = (Join-Path $env:LOCALAPPDATA 'agency-agents-src'),
    [switch] $ProjectOnly
)

$ErrorActionPreference = 'Stop'

function Write-Step { param([string] $Text) Write-Host "`n==> $Text" -ForegroundColor Cyan }

# --- 사전 확인 -------------------------------------------------------------
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'git 을 찾을 수 없습니다. https://git-scm.com/download/win 에서 설치한 뒤 다시 실행하세요.'
}

# --- 설치 위치 -------------------------------------------------------------
if ($ProjectOnly) {
    $dest = Join-Path (Get-Location).Path '.claude\agents'
    $scopeLabel = "이 폴더 전용  ($dest)"
} else {
    $dest = Join-Path $env:USERPROFILE '.claude\agents'
    $scopeLabel = "전역 — 모든 프로젝트  ($dest)"
}

Write-Step "설치 위치: $scopeLabel"
New-Item -ItemType Directory -Force -Path $dest | Out-Null

# --- 저장소 받기 / 갱신 -----------------------------------------------------
$gitDir = Join-Path $SrcDir '.git'

if (Test-Path -LiteralPath $gitDir) {
    $current = (git -C $SrcDir rev-parse --abbrev-ref HEAD).Trim()
    $target  = if ($Branch) { $Branch } else { $current }
    Write-Step "기존 사본 갱신: $SrcDir  (브랜치 $target)"
    git -C $SrcDir fetch --depth 1 origin $target
    if ($LASTEXITCODE -ne 0) { throw "git fetch 실패 (브랜치 $target)" }
    git -C $SrcDir checkout -B $target FETCH_HEAD --quiet
    if ($LASTEXITCODE -ne 0) { throw "git checkout 실패 (브랜치 $target)" }
} else {
    Write-Step "저장소 복제: $Repo"
    if ($Branch) {
        git clone --depth 1 --branch $Branch $Repo $SrcDir
    } else {
        git clone --depth 1 $Repo $SrcDir
    }
    if ($LASTEXITCODE -ne 0) { throw 'git clone 실패. 저장소 주소와 접근 권한을 확인하세요.' }
}

# --- 복사 ------------------------------------------------------------------
$src = Join-Path $SrcDir '.claude\agents'
if (-not (Test-Path -LiteralPath $src)) {
    throw "에이전트 폴더가 없습니다: $src  (브랜치를 잘못 받았을 수 있습니다)"
}

$files = @(Get-ChildItem -LiteralPath $src -Filter '*.md' -File)
if ($files.Count -eq 0) { throw "복사할 .md 파일이 없습니다: $src" }

Write-Step "$($files.Count) 개 복사 중..."
foreach ($f in $files) {
    Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $dest $f.Name) -Force
}

# --- 결과 ------------------------------------------------------------------
$total = @(Get-ChildItem -LiteralPath $dest -Filter '*.md' -File).Count

Write-Host ''
Write-Host '────────────────────────────────────────────────' -ForegroundColor DarkGray
Write-Host "  복사 완료 : $($files.Count) 개" -ForegroundColor Green
Write-Host "  설치 위치 : $dest"
Write-Host "  현재 총계 : $total 개"
Write-Host '────────────────────────────────────────────────' -ForegroundColor DarkGray
Write-Host ''
Write-Host '새 Claude Code 세션을 열면 적용됩니다.' -ForegroundColor Yellow
Write-Host '실행 중인 세션에는 보이지 않습니다 — 에이전트 목록은 세션 시작 시 한 번 읽습니다.'
Write-Host ''
Write-Host '부를 때는 자연어가 가장 확실합니다:'
Write-Host '  "SEO Specialist 서브에이전트로 이 사이트 진단해줘"'
Write-Host '  "Naver Search Specialist 불러서 서치어드바이저 점검해줘"'
Write-Host ''
