# agency

Claude Code 서브에이전트 모음. [The Agency (`msitarzewski/agency-agents`)](https://github.com/msitarzewski/agency-agents)
의 에이전트 전체를 이 저장소의 `.claude/agents/` 에 설치해 두었습니다.

## 설치 내용

| 항목 | 값 |
| --- | --- |
| 출처 | https://github.com/msitarzewski/agency-agents (MIT) |
| 설치 시점의 upstream 커밋 | `b37b5bb33b78f2c1d6567d98e25ca818e3259219` (2026-10-24) |
| 설치 위치 | `.claude/agents/` |
| 에이전트 수 | 268개 (18개 부서) |

부서별 에이전트 수:

| 부서 | 개수 | 부서 | 개수 |
| --- | --- | --- | --- |
| engineering | 66 | sales | 9 |
| specialized | 59 | testing | 9 |
| marketing | 37 | paid-media | 7 |
| gis | 13 | project-management | 7 |
| security | 12 | academic | 6 |
| design | 10 | game-development | 6 |
| finance | 5 | product | 6 |
| healthcare | 3 | spatial-computing | 6 |
| research | 1 | support | 6 |

## 사용법

이 저장소를 작업 디렉터리로 열면 `.claude/agents/` 의 에이전트가 자동으로 서브에이전트로
등록됩니다. 에이전트 이름은 프론트매터의 `name` 값(예: `AI Engineer`, `Frontend Developer`)
이며, 파일명은 `<부서>-<에이전트>.md` 형식입니다.

```bash
# 설치된 에이전트 목록
ls .claude/agents/

# 이름으로 찾기
grep -l '^name: Frontend Developer' .claude/agents/*.md

# 부서별로 보기
ls .claude/agents/ | grep '^security-'
```

전역(`~/.claude/agents/`)에 설치하고 싶으면 upstream 저장소에서:

```bash
git clone https://github.com/msitarzewski/agency-agents.git
cd agency-agents
./scripts/install.sh --tool claude-code                     # 전체
./scripts/install.sh --tool claude-code --division engineering,security   # 일부
```

## 업데이트

```bash
git clone --depth 1 https://github.com/msitarzewski/agency-agents.git /tmp/agency-agents
cd /tmp/agency-agents
./scripts/install.sh --tool claude-code --no-interactive --path <이 저장소>/.claude/agents
```

## 라이선스

`.claude/agents/` 의 에이전트 파일은 upstream 저장소의 MIT 라이선스를 따릅니다.
