# 작업 지시서: dogmap.co.kr (들어가개)

> 다른 Claude 세션에 이 파일 내용을 그대로 붙여 넣어 일을 시키는 용도입니다.
> 기준일: 2026-11-01. 근거: 2026-11-01 curl 수집 + SEO Specialist 감사 + Growth Hacker 계획.
> 원본: `dol2314/agency` 저장소, 브랜치 `claude/hopeful-goldberg-xuk9k3`, `audits/` 폴더.

## 0. 이 세션에게

너는 dogmap.co.kr(애견동반 장소·산책코스·24시 동물병원, Next.js App Router, Cloudflare, AdSense 수익, 1인 운영)의 SEO·성장 작업을 맡는다. 목표는 **하루 1,000 방문(GA4 세션)**이고, 기준 시나리오상 9~12개월이 걸린다. 2027년 4~5월 봄 성수기 전에 색인을 쌓는 것이 핵심이다. 아래 작업을 **우선순위 순서대로** 처리하라.

규칙:
- 각 작업은 "완료 조건"을 만족해야 끝난 것이다. 확인(`curl -I`, 빌드, 렌더된 HTML)을 실제로 실행하고 결과를 보고하라.
- 코드를 바꾸기 전에 저장소 구조와 데이터 파이프라인을 먼저 읽는다.
- 확인되지 않은 동반 가능 여부를 단정하지 않는다. AI로 업체 소개문을 지어내지 않는다.
- Cloudflare 대시보드 설정은 직접 하지 말고, 운영자가 할 수 있게 정확한 단계를 보고한다.
- robots.txt AI 정책은 **운영자 결정이 필요**하다(T3). 결정 전에는 바꾸지 않는다.
- 커밋·푸시는 운영자가 요청한 브랜치에만 한다.

## 1. 현재 상태 (확인된 사실)

- Next.js(turbopack) + Cloudflare. 서버 렌더링, `html lang="ko"`, canonical, http→https 301, 트레일링 슬래시 308.
- 사이트맵 3,322 URL: `/places/{업종}/{시도}/{시군구}/` 1,824, `/courses/{시도}/{id}/` 1,443, `/guide/` 46편, `/vet-24h/`, `/popular/`, `/find/`. `rss.xml` 200(robots에는 미등록).
- `/find/` 기준 장소 22,088곳. **개별 장소 URL 없음** — 목록에 업체명이 링크 없는 평문, tel:·외부 링크만.
- 목록에 "이 목록의 자료는 2022-11-30 기준(약 4년 전)" 문구. 마포 카페 표본은 96곳 중 25곳만 문화정보원(2022) 자료, 나머지는 식약처 출처.
- HTML `cf-cache-status: DYNAMIC`(엣지 캐시 안 됨). 정적 청크는 1년 immutable(정상).
- og:image 사이트 전체 없음(`twitter:card=summary_large_image`인데 이미지 없음). manifest.webmanifest 있음.
- JSON-LD: 홈 Organization+WebSite, 목록 BreadcrumbList+ItemList, 코스 Place+BreadcrumbList.
- GA4 `G-ML5XE5BCZV`, `naver-site-verification` 있음. AdSense `ca-pub-5978949128100777`(bokjicard.co.kr과 같은 계정).
- 개설 약 2주(sitemap lastmod 2026-10-21), 아직 거의 미색인으로 추정. 서치콘솔·CWV 실측 없음.

## 2. 작업 목록 (우선순위 순)

### P0 — 1주차 안에

**T1. 한국어 404 + 루트 robots 메타 제거** (High)
- 문제: 404가 Next 기본 영문 페이지("This page could not be found."), `<title>` 2개, robots 메타 `noindex`와 `index, follow` 동시 존재(루트 layout이 모든 페이지에 index,follow를 박고 있음).
- 할 일:
  ```ts
  // app/layout.tsx — robots 필드 삭제, title 템플릿
  export const metadata = { metadataBase: new URL('https://dogmap.co.kr'),
    title: { default: '애견동반 카페·식당·펜션 지도 | 들어가개', template: '%s | 들어가개' } };
  // app/not-found.tsx — 한국어 안내 + 업종·지역 허브 링크 + /find/
  ```
- 완료 조건: 없는 URL이 404 상태코드, title 1개, robots 메타 1개(noindex), 한국어 본문.

**T2. 사이트 전체 og:image** (Medium, 공유·SNS의 전제)
- 할 일: `app/opengraph-image.tsx`(기본), `app/places/[type]/[sido]/[sgg]/opengraph-image.tsx`("마포구 애견동반 카페 96곳"), 코스 상세용(거리·누적 상승·급경사 수·경사 그래프 썸네일).
- 완료 조건: 홈·목록·코스·가이드 표본 HTML에 og:image, 카카오 공유 디버거에서 썸네일 확인(운영자).

**T3. robots.txt 정리** (High, 운영자 결정 필요)
- 문제: Cloudflare 관리형 블록이 학습 크롤러 외에 **사용자 요청형 에이전트**(ChatGPT-User, Claude-User, Perplexity-User, Google-Agent, meta-externalfetcher 등)와 GoogleOther도 차단. `User-agent: *` 그룹 2개(두 번째에만 `Disallow: /api/`), `Host:` 지시어, rss 미등록. Googlebot·Yeti·OAI-SearchBot·PerplexityBot·Claude-SearchBot은 허용 상태.
- 운영자에게 물을 것: "학습용 크롤러 차단은 유지하고 사용자 요청형 에이전트는 허용할까요?"
- 허용으로 결정되면: Cloudflare의 관리형 robots.txt 끄기(+ WAF 수준 "AI 봇 차단" 토글 확인) 안내, 그리고
  ```ts
  // app/robots.ts
  export default function robots() {
    return {
      rules: [
        { userAgent: '*', allow: '/', disallow: ['/api/'] },
        { userAgent: ['GPTBot','ClaudeBot','Google-Extended','CCBot','Bytespider','Applebot-Extended','meta-externalagent'], disallow: '/' },
      ],
      sitemap: ['https://dogmap.co.kr/sitemap.xml', 'https://dogmap.co.kr/rss.xml'],
    };
  }
  ```
- `/saved/`는 robots가 아니라 페이지 metadata `robots: { index: false }`로.
- 완료 조건: `curl https://dogmap.co.kr/robots.txt`가 의도한 정책과 일치, `*` 그룹 1개.

**T4. 검색엔진 등록 + 측정** (운영자 작업, 안내만)
- 네이버 서치어드바이저(사이트맵·RSS 제출), Bing·Daum 등록, 서치콘솔 도메인 속성. Cloudflare Security Events에서 Yeti UA가 막히지 않는지 확인. 홈 `<head>`에 `<link rel="alternate" type="application/rss+xml">` 추가.
- IndexNow 연동 스크립트(상세 페이지 대량 추가 대비).
- GA4 이벤트 구현: `tel_click`(업종, 지역), `save_place`, `list_share`, `report_submit`, `locate_me`, `course_view`, `share_click`, `pwa_install`.

### P1 — 2~4주차

**T5. HTML 엣지 캐시 / ISR** (High)
- 할 일: 목록·코스·가이드를 `generateStaticParams` + `export const revalidate = 86400`. Cloudflare Cache Rule 안내:
  ```
  http.host eq "dogmap.co.kr" and (starts_with(path,"/places/") or starts_with(path,"/courses/")
    or starts_with(path,"/guide/") or path eq "/vet-24h/")
  → Eligible for cache, Edge TTL 1일, Browser TTL Respect origin, 쿼리스트링은 캐시 키에 포함
  ```
  `/api/`, `/find/?q=`, `/saved/` 제외. **RSC `_rsc` 쿼리를 캐시 키에서 빼지 말 것**(RSC 페이로드가 HTML 요청에 섞임). 직접 접속·내부 링크 이동 모두 테스트.
- 완료 조건: 두 번째 요청에서 `cf-cache-status: HIT`, 클라이언트 내비게이션 정상.

**T6. 24시 동물병원 시도별 분리 + PWA 안내** (실험 D2, ICE 최고)
- 문제: `/vet-24h/` 한 페이지 265KB에 206곳.
- 할 일: `/vet-24h/{시도}/` 17개(2곳 이상인 시군구만 하위 페이지). 각 페이지 상단에 "운영시간이 바뀔 수 있으니 전화 먼저". `/places/vet/...`는 "[지역] 동물병원", `/vet-24h/...`는 "[지역] 24시·야간 동물병원"을 맡도록 title·H1 분리. "응급 시 바로 찾도록 홈 화면에 추가" 안내.
- 완료 조건: 17개 페이지 사이트맵 포함. 성공 기준: 12주차 합계 일 30 이상, 설치 100 이상.

**T7. 얇은 목록 noindex·통합** (High, 실험 D3)
- 할 일: 먼저 업종×시군구별 업체 수 분포를 계산해 운영자에게 보고. 기준(예시) 확정 후:
  ```ts
  const indexable = list.places.length >= 3 || list.places.some(p => p.richFields >= 3);
  // generateMetadata: robots: indexable ? undefined : { index: false, follow: true }
  ```
  noindex 페이지는 사이트맵에서 제외, `/find/`도 사이트맵에서 제외. 공통 안내(목줄 2m, 색 범례, 출처)는 `<details>`로 접기. 남는 페이지에 인접 시군구·근처 산책코스·24시 병원 링크.
- 성공 기준: 8주 뒤 색인 대상 중 50% 이상 색인.

**T8. 데이터 신선도 표시** (High)
- 할 일: 목록 상단 기준일을 출처별로 분리("식약처 ○○○○-○○ 기준 71곳 · 문화정보원 2022-11-30 기준 25곳", 최신 출처 먼저). 장소별 "최근 확인일".
- 이어서(조사 필요): 지방행정 인허가 데이터의 영업상태(영업/폐업)를 사업장명+주소로 매칭해 폐업 업체 표시·제외 — 매칭률을 먼저 측정해 보고. 공공데이터포털에서 문화정보원 반려동물 동반 데이터 최신판 확인.

**T9. 공유 버튼** (실험 D1)
- 코스·목록·가이드에 카카오/링크 공유. 체중 필터 상태를 URL에 담아 공유("15kg 대형견 OK — 마포구 카페 7곳"). 공유 링크 UTM.
- 성공 기준: 공유율 2% 이상, 공유당 유입 2 이상.

**T10. 시즌 가이드 (날짜 고정)** (실험 D9)
- 실내 대형견 가능 카페(11월), 연말 애견동반 펜션 체중 제한(12월 초), 제설제·겨울 산책(12월 말), **설 연휴 24시 병원·애견호텔 + 병원 데이터 갱신(1월 셋째 주까지)**. 의료 판단은 쓰지 않고 "수의사와 상담할 항목" 수준.

### P2 — 5~12주차

- **T11. 1클릭 제보 버튼**(아직 영업 / 조건 변경 / 폐업) + "2026-11 이용자 확인" 날짜 표시. 성공 기준 월 30건.
- **T12. 평지 산책코스 랜딩**: 시군구별 "OO시 강아지 산책 평지 코스" 10개 시범(경사 데이터 재조합).
- **T13. 코스 노선 허브**: `/courses/{시도}/{노선-코스}/`로 구간 묶기(전체 거리·경사 요약·동반 규정·화장실·주차·주변 카페). 구간↔허브↔같은 시군구 장소 상호 링크. 상단에 한 문장 요약("총 2.5km, 급경사 7곳, 국립공원 밖").
- **T14. 2026 동반출입 음식점 등록 목록 수집 + 배지**(2026-03-01 시행 제도, 지자체 공개 목록). 수집 지자체 10곳 이상.
- **T15. 장소 상세 페이지 시범 300곳**(서울·경기·제주, 최대 레버):
  - URL `/place/{id}/`(안정 ID), 업종·지역은 브레드크럼.
  - 내용: 업체명, 주소, 전화, 영업시간, 동반 조건(견종·크기·실내외·추가 요금), 주차, 출처·기준일·최근 확인일, 네이버지도·카카오맵 길찾기, 주변 산책코스·공원·24시 병원, 제보 버튼.
  - JSON-LD: `LocalBusiness`/`CafeOrRestaurant` + `amenityFeature`(반려동물 동반) + `BreadcrumbList`. 목록 ItemList에 상세 URL.
  - **품질 게이트**: 영업 중 + (전화 또는 영업시간) + 동반 조건 1개 이상 + 확인일 2년 이내일 때만 index·사이트맵. 나머지는 상세를 만들지 않거나 noindex. 폐업은 410 또는 목록으로 301. 목록에서 2~3클릭 안.
  - ISR(`revalidate = 86400`, `dynamicParams = true`).
  - 성공 기준: 8주 안에 50% 색인, 페이지당 일 0.05클릭 이상이면 전국으로 2배씩 확대.
- **T16. 홈 동영상**: 첫 `<video>`를 `preload="none"`, 포스터 이미지 `fetchpriority="high"` preload, `prefers-reduced-motion`·`saveData`면 재생 안 함.
- **T17. 기타**: 수치 불일치(서울 카페 692 vs 691) 단일 출처화, RSC 페이로드의 평문 이메일 → 문의 폼 또는 Cloudflare 이메일 난독화 끄기.

## 3. 성공 판단

| 시점 | 관문 |
|---|---|
| 6주차 | 색인 800페이지 이상, 일 노출 2,000 이상 |
| 12주차 | 일 세션 80 이상, 색인 1,500 이상 |
| 6개월(2027-04) | 일 세션 500 이상(봄 성수기) |
| 9~12개월 | 일 세션 1,000(기준 시나리오) |

- 프로그래매틱 페이지(장소 상세·랜딩): 8주 색인률 50% 미만이면 확대 중단하고 기존 묶음을 줄인다. 60% 이상이고 클릭이 생기면 2배씩 확대.
- 8주차에 서치콘솔 색인 보고서로 색인률 가정(70%)을 실측값으로 바꾼다.

## 4. 하지 말 것

- 기준일 숨기기, 오래된 데이터를 최신처럼 보이게 하기.
- 증상별 의료 조언. 24시 병원은 "전화 먼저"를 크게.
- 근거 없는 규정 정보(국립공원 출입, 목줄 2m, 동반출입 음식점 기준은 법령·고시 링크와 시행일 필수).
- 대가를 받고 업체 순위 변경, 배지를 유료 인증처럼 보이게 하기.
- 업체 수만 개 페이지 일괄 공개, AI로 지어낸 업체 소개문.
- 반려견 카페·당근 링크 홍보, 보호자 사칭 댓글, 트래픽 구매.
- bokjicard.co.kr과 사이트 전체 상호 링크(같은 AdSense 계정 — 한쪽 정책 문제가 둘 다 막음).
