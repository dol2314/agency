# 작업 지시서: bokjicard.co.kr (복지카드 안내소)

> 다른 Claude 세션에 이 파일 내용을 그대로 붙여 넣어 일을 시키는 용도입니다.
> 기준일: 2026-11-01. 근거: 2026-11-01 curl 수집 + SEO Specialist 감사 + Growth Hacker 계획.
> 원본: `dol2314/agency` 저장소, 브랜치 `claude/hopeful-goldberg-xuk9k3`, `audits/` 폴더.

## 0. 이 세션에게

너는 bokjicard.co.kr(Next.js App Router, Cloudflare 서빙, AdSense 수익, 1인 운영)의 SEO·성장 작업을 맡는다. 목표는 **하루 1,000 방문(GA4 세션)**이고, 기준 시나리오상 약 12개월이 걸린다. 아래 작업을 **우선순위 순서대로** 하나씩 처리하라.

규칙:
- 각 작업은 "완료 조건"을 만족해야 끝난 것이다. 확인 방법(`curl -I`, 빌드, 렌더된 HTML 확인)을 실제로 실행하고 결과를 보고하라.
- 코드를 바꾸기 전에 저장소 구조를 먼저 읽고, 기존 패턴을 따른다.
- 복지·금액 정보(YMYL)는 **공식 출처(보건복지부, 복지로, 문화누리, 한국에너지공단)로 확인한 값만** 쓴다. 블로그는 출처로 쓰지 않는다. 확인 못 하면 "확인 필요"로 남기고 사람에게 묻는다.
- Cloudflare 대시보드 설정처럼 코드 밖의 일은 직접 하지 말고, 운영자가 할 수 있게 정확한 단계를 적어 보고한다.
- 커밋·푸시는 운영자가 요청한 브랜치에만 한다.

## 1. 현재 상태 (확인된 사실)

- Next.js(turbopack) + Cloudflare. HTML은 서버 렌더링, `html lang="ko"`, 페이지마다 canonical(https 절대 URL), robots `index, follow`.
- 사이트맵 75 URL: `/`, `/check/`, `/calc/`(계산기 8종), `/center/`, `/cards/`(카드 8종), `/apply/`, `/use/`, `/tips/`(글 49편), `/about/`, `/privacy/`. `rss.xml` 있음(robots에 등록됨).
- robots.txt: `User-Agent: * Allow: /` + sitemap, rss. llms.txt 없음.
- GA4 `G-WS1B4R2HFR`, `naver-site-verification` 메타 있음. AdSense `ca-pub-5978949128100777`(dogmap.co.kr과 같은 계정).
- 글 49편이 2026-10-20~10-28에 발행됨(개설 약 2주, 아직 거의 미색인으로 추정).
- 서치콘솔·네이버 서치어드바이저·Core Web Vitals 실측 데이터 없음.

## 2. 작업 목록 (우선순위 순)

### P0 — 1주차 안에

**T1. http → https 영구 리다이렉트** (High)
- 문제: `http://bokjicard.co.kr/` 가 200을 반환한다(리다이렉트 없음).
- 할 일: 운영자에게 Cloudflare → SSL/TLS → Edge Certificates → **Always Use HTTPS = On** 안내. 안정되면 HSTS(짧은 max-age부터).
- 완료 조건: `curl -sI http://bokjicard.co.kr/` → `301` + `location: https://bokjicard.co.kr/`.

**T2. 트레일링 슬래시 리다이렉트 307 → 301/308** (Medium)
- 문제: `/cards/disabled` → 307(임시) → `/cards/disabled/`.
- 할 일: `next.config`의 `trailingSlash: true`는 유지. Cloudflare Redirect Rule(맨 앞 순서) 안내:
  ```
  (http.host eq "bokjicard.co.kr"
   and not ends_with(http.request.uri.path, "/")
   and not http.request.uri.path contains "."
   and not starts_with(http.request.uri.path, "/opengraph-image")
   and not starts_with(http.request.uri.path, "/_next/"))
  → Dynamic: concat("https://bokjicard.co.kr", http.request.uri.path, "/"), 301, Preserve query string
  ```
- 완료 조건: `curl -sI https://bokjicard.co.kr/cards/disabled` → 301 또는 308.

**T3. `_next/static` 캐시 1년** (Medium)
- 문제: 정적 JS 청크가 `cache-control: public, max-age=0, must-revalidate`.
- 할 일: `public/_headers`에 추가(또는 Cloudflare Cache Rule):
  ```
  /_next/static/*
    Cache-Control: public, max-age=31536000, immutable
  ```
- 완료 조건: `curl -sI https://bokjicard.co.kr/_next/static/chunks/<아무 청크>.js` → `max-age=31536000, immutable`.

**T4. 2027 기준 반영 (YMYL, 날짜 고정)** (High)
- 문제: `/calc/median-income/`이 2026 값(4인 6,494,738원)을 쓰면서 "다음 해 기준은 보통 8월에 정해진다"고 적혀 있다. 2027 기준중위소득은 2026-07-28 중앙생활보장위원회에서 의결됐다(보도: 4인 6.7% 인상, 6,929,885원 — **공식 고시로 재확인 필수**).
- 할 일:
  1. 계산기에 2026/2027 연도 토글, 2027-01-01 자동 전환.
  2. 기초연금·생계급여·주거급여·의료급여·장애인연금 계산기의 2027 값 점검(정부안/확정 구분 표기).
  3. 연도 URL(`/tips/median-income-2026/`, `/tips/basic-pension-2026/`)을 연도 없는 URL로 옮기고 301 — **운영자 승인 후**.
- 완료 조건: 2027 값과 출처 링크·기준일이 페이지에 보이고, 1/1 이전엔 2026이 기본, 이후엔 2027이 기본.

**T5. 수치 단일화** (Medium)
- 문제: 센터 수가 3,556(홈·메타)과 3,533(글 하단)으로 다르다.
- 할 일: 숫자는 데이터 파일 하나에서 계산해 주입. 전화번호 있는 수를 따로 쓰면 "3,556곳(전화번호 3,533곳)"처럼 명시.
- 완료 조건: 사이트 전체 grep에서 하드코딩 숫자 없음.

**T6. 검색엔진 등록 + 측정** (운영자 작업, 안내만)
- 네이버 서치어드바이저: `/sitemap.xml`, `/rss.xml` 제출, 새 핵심 페이지 수집 요청. Bing·Daum 웹마스터 등록. 서치콘솔 도메인 속성(Cloudflare DNS TXT) 확인.
- IndexNow(네이버·Bing 지원): 빌드 후 변경 URL POST 스크립트를 만들어 둔다.
- GA4 이벤트 구현: `calc_start`, `calc_complete`(calc_id), `check_complete`, `center_search`, `print_checklist`, `share_click`(method, content_type), `calendar_add`, `pwa_install`. **소득·재산 입력값은 절대 보내지 않는다**(계산기 ID와 결과 구간만).

### P1 — 2~4주차

**T7. OG 메타 얕은 병합 버그** (Medium)
- 문제: `/center/`의 `og:url`이 홈 주소, 글 페이지에서 `og:image`·`og:url`·`og:site_name`·`og:locale`이 빠짐(Next metadata 얕은 병합).
- 할 일: 공통 `baseOG` 객체를 스프레드로 병합, 루트 layout에서 `openGraph.url` 제거(`metadataBase`만), 글별 `generateMetadata`에 `openGraph`·`twitter` 명시. `app/tips/[slug]/opengraph-image.tsx`, 계산기별 og 이미지 8종.
- 완료 조건: 표본 페이지 5개 HTML에서 og:url이 자기 URL, og:image 존재.

**T8. 카드↔꿀팁 내부 링크 + 검색어 담당 분리** (High)
- 문제: `/cards/disabled/`에서 꿀팁 링크 0개, 문화누리 글에서 `/cards/culture/` 링크 없음, 브레드크럼 카드명이 링크 아님. 계산기·꿀팁이 같은 주제 6쌍.
- 할 일: 카드 페이지마다 "관련 꿀팁" 블록(같은 카드 태그 글 자동 나열), 글 브레드크럼 카드명 링크, 본문 첫 언급 링크. title/H1을 아래처럼 분리:

  | 주제 | 계산기(calc)가 맡는 검색어 | 꿀팁(tips)이 맡는 검색어 |
  |---|---|---|
  | 기준중위소득 | 계산기, 몇 % | 기준표·인상률·변경점 |
  | 기초연금 | 모의계산 | 수급 조건·신청 |
  | 장애인연금·주거급여·장기요양·활동지원 | 계산 | 조건·신청 |
  | 장애인복지카드 | — | 신청 = /cards/disabled/, 할인 목록 = tips/disabled-card-discounts. /apply/는 카드별 비교로 범용화 |
- 완료 조건: 모든 카드 페이지에 관련 꿀팁 3개 이상 링크, title 중복 없음.

**T9. /center/ 지역 페이지 1단계** (Critical, 최대 레버)
- 문제: `/center/` HTML에 빈 `<select>` 3개뿐, 3,556곳 이름·주소·전화가 HTML에 없음.
- 할 일:
  - URL 표기는 **운영자에게 먼저 확인**(영문 로마자 `/center/seoul/gangnam-gu/` 권장, 한 번 정하면 변경 금지).
  - `app/center/[sido]/page.tsx`(17개), `app/center/[sido]/[sigungu]/page.tsx`(약 250개) 정적 생성(`generateStaticParams`, `dynamicParams = false`).
  - 시군구 페이지: H1 "OO구 행정복지센터(주민센터) N곳 주소·전화번호", 표(센터명 | 도로명주소 | tel: 전화 | 관할 법정동), 이 지역의 복지카드 명칭, 인접 구 링크, 출처·기준일.
  - `/center/` 본 페이지 아래에 시도 17개 링크를 서버 렌더링으로. `generateSitemaps()`로 `sitemap/center.xml` 분리.
  - JSON-LD: BreadcrumbList, 센터별 `GovernmentOffice`(address, telephone).
- 지킬 것: 공통 안내는 한두 줄, 데이터 표보다 광고가 먼저 보이지 않게, 공공누리 이용 조건 확인. **읍면동 3,556개 페이지는 이번에 만들지 않는다**(2단계, 색인 확인 후).
- 완료 조건: 빌드 후 시군구 페이지 HTML에 센터 데이터가 들어 있고, 사이트맵에 포함.

**T10. 시즌 콘텐츠 (날짜 고정)**
- 11/16까지: "12월 문화누리 잔액 소멸" 허브(신청 마감 11/30, 잔액 12/31 소멸·이월 없음, 사용처). 에너지바우처 신청 마감 12/31 갱신.
- 12/20 전후: "2027 바뀌는 복지" 허브(정부안/확정 구분).
- 1/10까지: 연말정산 장애인공제·장애인증명서 발급 글.
- 1월 셋째 주까지: 2027 문화누리 신청·자동 재충전 글.
- 모든 일정·금액은 공식 공고로 재확인.

**T11. 카톡 공유 "부모님께 보내기"** (실험 B3)
- 계산기·자가진단 결과 아래 Kakao JS SDK 공유 + Web Share API 링크 복사.
- 공유 카드에는 결과 요약만("기초연금 대상 가능성 높음 · 예상 월 최대 OO만원 · 기준일"). **입력값을 URL에 넣지 않는다.** 공유 링크에 UTM(`utm_source=kakao&utm_medium=share&utm_campaign=calc_result`).
- 받는 쪽 랜딩은 큰 글씨 모드, "가까운 행정복지센터 찾기"·"준비물 체크리스트 인쇄" 버튼.
- 성공 기준: 공유율 3% 이상, 공유당 유입 1.5 이상.

### P2 — 5~12주차

- **T12. E-E-A-T**: Article JSON-LD에 `author`(운영자 Person + /about/), `image`, 실제 `dateModified`. 홈에 `Organization`. /about/에 운영자 소개·검수 절차·갱신 주기(매년 1월·7월).
- **T13. 계산기 광고 위치**: 계산 버튼·결과 주변 광고 제거, 광고 컨테이너 `min-height` 예약(CLS).
- **T14. 재방문 장치**: 마감일 `.ics` 캘린더 버튼 5종, PWA manifest + "홈 화면에 추가" 안내.
- **T15. Pretendard 자체 호스팅**: jsDelivr CSS 대신 `next/font/local`, `display: 'swap'`.
- **T16. 사이트맵 lastmod**: 빌드 시각 대신 콘텐츠 `updatedAt`. `/search/`는 `noindex, follow`.
- **T17. 인쇄용 A4 체크리스트**(큰 글씨, QR+UTM) — 복지관 아웃리치용.
- **T18. 계산 예시 글**: "월 소득 150만원·집 2억이면 기초연금은?" 형식 10편.

## 3. 성공 판단

| 시점 | 관문 |
|---|---|
| 6주차 | 색인 70페이지 이상, 일 노출 500 이상 |
| 12주차 | 일 세션 80 이상(1월 시즌 포함), 일 클릭 50 이상 |
| 6개월 | 일 세션 300 이상 |
| 12개월 | 일 세션 1,000(기준 시나리오) |

- /center/ 1단계: 6주 안에 색인 60% 이상이고 10주차 페이지당 일 0.3클릭 이상이면 읍면동 2단계 검토. 50% 미만이면 확대 중단.
- 8주차에 서치콘솔 "클릭 ÷ 색인 페이지"로 트래픽 모델 재계산.

## 4. 하지 말 것

- 정부안을 확정처럼 쓰기, 정부 로고·"공식" 표현, "지금 받으세요" 식 과장.
- 계산 결과를 수급 판정처럼 표현(→ "대상 가능성 높음 · 정확한 판정은 행정복지센터").
- 소득·재산 입력값을 URL·공유 카드·GA4에 넣기.
- 읍면동 3,556개 일괄 공개, AI 대량 생산 글.
- 커뮤니티 링크 홍보·자작 질문, 블로그 복붙, 백링크·트래픽 구매.
- dogmap.co.kr과 사이트 전체 상호 링크(같은 AdSense 계정 — 한쪽 정책 문제가 둘 다 막음).
