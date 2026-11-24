#Requires -Version 5.1
<#
.SYNOPSIS
  agency-agents 의 에이전트와 스킬을 윈도우의 Claude Code 폴더에 설치하거나 갱신합니다.

.DESCRIPTION
  기본값은 전역 설치입니다.
    에이전트 → %USERPROFILE%\.claude\agents
    스킬     → %USERPROFILE%\.claude\skills
  모든 프로젝트(복지카드·dogmap·소식지·블로그 등)의 Claude Code 세션에서 보입니다.

  다시 실행하면 저장소를 최신으로 받아 갱신합니다. 여러 번 실행해도 안전합니다.

.PARAMETER ProjectOnly
  전역이 아니라 현재 폴더의 .claude\ 아래에만 설치합니다.

.PARAMETER SkipSkills
  에이전트만 설치하고 스킬은 건너뜁니다.

.PARAMETER SkipAgents
  스킬만 설치하고 에이전트는 건너뜁니다.

.PARAMETER Branch
  받을 브랜치. 비워 두면 저장소 기본 브랜치를 씁니다.

.EXAMPLE
  .\install-windows.ps1
  에이전트와 스킬을 전역에 설치·갱신합니다.

.EXAMPLE
  .\install-windows.ps1 -ProjectOnly
  현재 폴더에만 설치합니다.

.NOTES
  설치 후에는 새 Claude Code 세션을 열어야 적용됩니다.
  에이전트·스킬 목록은 세션이 시작할 때 한 번 읽습니다.
#>
[CmdletBinding()]
param(
    [string] $Repo   = 'https://github.com/dol2314/agency.git',
    [string] $Branch = '',
    [string] $SrcDir = (Join-Path $env:LOCALAPPDATA 'agency-agents-src'),
    [switch] $ProjectOnly,
    [switch] $SkipSkills,
    [switch] $SkipAgents
)

$ErrorActionPreference = 'Stop'

function Write-Step { param([string] $Text) Write-Host "`n==> $Text" -ForegroundColor Cyan }

# --- 사전 확인 -------------------------------------------------------------
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'git 을 찾을 수 없습니다. https://git-scm.com/download/win 에서 설치한 뒤 다시 실행하세요.'
}
if ($SkipAgents -and $SkipSkills) {
    throw '-SkipAgents 와 -SkipSkills 를 같이 주면 설치할 것이 없습니다.'
}

# --- 설치 위치 -------------------------------------------------------------
if ($ProjectOnly) {
    $baseDest = Join-Path (Get-Location).Path '.claude'
    $scopeLabel = "이 폴더 전용  ($baseDest)"
} else {
    $baseDest = Join-Path $env:USERPROFILE '.claude'
    $scopeLabel = "전역 — 모든 프로젝트  ($baseDest)"
}

Write-Step "설치 위치: $scopeLabel"

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

$agentCount = 0
$skillCount = 0

# --- 에이전트 복사 (.md 파일) -----------------------------------------------
if (-not $SkipAgents) {
    $src  = Join-Path $SrcDir '.claude\agents'
    $dest = Join-Path $baseDest 'agents'

    if (-not (Test-Path -LiteralPath $src)) {
        throw "에이전트 폴더가 없습니다: $src  (브랜치를 잘못 받았을 수 있습니다)"
    }

    $files = @(Get-ChildItem -LiteralPath $src -Filter '*.md' -File)
    if ($files.Count -eq 0) { throw "복사할 에이전트가 없습니다: $src" }

    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    Write-Step "에이전트 $($files.Count) 개 복사 중..."
    foreach ($f in $files) {
        Copy-Item -LiteralPath $f.FullName -Destination (Join-Path $dest $f.Name) -Force
    }
    $agentCount = @(Get-ChildItem -LiteralPath $dest -Filter '*.md' -File).Count
}

# --- 스킬 복사 (폴더 단위: <이름>\SKILL.md) ----------------------------------
if (-not $SkipSkills) {
    $src  = Join-Path $SrcDir '.claude\skills'
    $dest = Join-Path $baseDest 'skills'

    if (-not (Test-Path -LiteralPath $src)) {
        Write-Warning "스킬 폴더가 없습니다: $src  — 스킬 설치를 건너뜁니다."
    } else {
        # SKILL.md 를 가진 폴더만 스킬이다. README.md 같은 낱개 파일은 건너뛴다.
        $dirs = @(Get-ChildItem -LiteralPath $src -Directory |
                  Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md') })

        if ($dirs.Count -eq 0) {
            Write-Warning "SKILL.md 를 가진 폴더가 없습니다: $src"
        } else {
            New-Item -ItemType Directory -Force -Path $dest | Out-Null
            Write-Step "스킬 $($dirs.Count) 개 복사 중..."
            foreach ($d in $dirs) {
                $target = Join-Path $dest $d.Name
                New-Item -ItemType Directory -Force -Path $target | Out-Null
                Copy-Item -LiteralPath (Join-Path $d.FullName '*') -Destination $target -Recurse -Force
                Write-Host "      $($d.Name)"
            }
            $skillCount = @(Get-ChildItem -LiteralPath $dest -Directory |
                            Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md') }).Count
        }
    }
}

# --- 결과 ------------------------------------------------------------------
Write-Host ''
Write-Host '────────────────────────────────────────────────' -ForegroundColor DarkGray
if (-not $SkipAgents) { Write-Host "  에이전트 : $agentCount 개" -ForegroundColor Green }
if (-not $SkipSkills) { Write-Host "  스킬     : $skillCount 개" -ForegroundColor Green }
Write-Host "  설치 위치 : $baseDest"
Write-Host '────────────────────────────────────────────────' -ForegroundColor DarkGray
Write-Host ''
Write-Host '새 Claude Code 세션을 열면 적용됩니다.' -ForegroundColor Yellow
Write-Host '실행 중인 세션에는 보이지 않습니다 — 목록은 세션 시작 시 한 번 읽습니다.'
Write-Host ''
Write-Host '에이전트는 자연어로 부르는 것이 가장 확실합니다:'
Write-Host '  "Naver Search Specialist 불러서 서치어드바이저 점검해줘"'
Write-Host '  "Naver Homepan Researcher 불러서 홈판 관찰 표본 설계해줘"'
Write-Host ''
Write-Host '스킬은 슬래시로 부릅니다:'
Write-Host '  /kr-competitors   /kr-marketing   /kr-brand'
Write-Host '  /kr-blog-income   /kr-youtube-growth'
Write-Host ''
