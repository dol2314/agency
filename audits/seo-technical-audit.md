# 기술 SEO 감사 — bokjicard.co.kr / dogmap.co.kr

- 작성일: 2026-11-01
- 범위: 크롤링·인덱싱, 렌더링·성능, 구조화 데이터, 메타/OG, 내부 링크·정보구조, 얇은/중복 콘텐츠, 네이버 대응, AI 검색 노출, 프로그래매틱 확장 전략, 키워드 클러스터
- 목표: 사이트별 하루 1,000 방문(주로 자연검색)

## 0. 읽는 법과 한계

| 표기 | 뜻 |
|---|---|
| **[확인]** | `audits/raw/FACTS.md`에 적힌 측정값, 또는 이번 감사에서 raw 파일·라이브 페이지(WebFetch)로 직접 확인한 사실 |
| **[추정]** | 업계 지식, 일반 동작 방식, 표본 1~2개에서 넓힌 추론. 수치가 붙으면 근거 없는 정확한 값이 아니라 범위·등급임 |

데이터 한계([확인]):
- **Google Search Console·네이버 서치어드바이저 데이터가 없습니다.** 노출·클릭·색인 현황과 실제 순위를 모르기 때문에 이 문서의 잠식(cannibalization) 분석은 "GSC 이전 방식"(사이트맵 + title/H1 + 검색 의도 비교)으로 했습니다. GSC 접근이 생기면 `page + query` 기준으로 다시 검증해야 합니다.
- **Core Web Vitals 실측값이 없습니다.** PageSpeed Insights API가 429를 반환했습니다. 성능 항목은 헤더·JS 크기·마크업에서 유추한 것이며 LCP/INP/CLS 수치는 쓰지 않았습니다.
- `www.` 호스트는 프록시가 막아 확인하지 못했습니다.
- 검색량: 키워드 도구 데이터가 없어 모든 수요 등급(상/중/하)은 **[추정]**입니다.

한국 검색 시장 맥락([추정], 언론 보도 기준): 2026년 상반기 인터넷트렌드 집계를 인용한 보도에 따르면 네이버 점유율은 56~64%, 구글은 약 35%입니다(출처마다 기준이 다름). 두 사이트 모두 네이버를 먼저 챙겨야 합니다. 다만 네이버 SERP는 플레이스·블로그·카페·지식iN이 위쪽을 차지하고 '웹문서' 영역은 아래에 있는 경우가 많습니다. 그래서 신생 독립 사이트에는 **구글 자연검색이 더 빨리 열리는 채널**일 가능성이 큽니다(추정).

---

## 1. 요약

### 1.1 bokjicard.co.kr Top 5 수정

| # | 이슈 | 심각도 | 핵심 조치 |
|---|---|---|---|
| 1 | /center/의 3,556곳 데이터가 크롤 불가(클라이언트 선택 UI) | **Critical** | 시도·시군구(·읍면동) 정적 페이지 생성, 사이트맵 포함 |
| 2 | 기준중위소득 계산기가 2026년 값 + "다음 해 기준은 보통 8월에 정해진다"는 문구(2027년 값은 2026-07-28 이미 의결) | **High** (YMYL 정확성) | 2027 값 반영, 연도 키워드 선점 |
| 3 | http→https 리다이렉트 없음(200), 트레일링 슬래시 307 | **High** | Cloudflare Always Use HTTPS + 301/308 리다이렉트 규칙 |
| 4 | 카드(필러) ↔ 꿀팁(위성) 내부 링크 단절, 계산기·꿀팁 주제 중복(잠식 위험) | **High** | 소유 페이지 지정, 상호 링크, title/H1 겹침 제거 |
| 5 | 저자·검수·수정일 표기 부족, 수치 불일치(3,556 vs 3,533), OG 메타 얕은 병합 버그 | **Medium** | E-E-A-T 블록, 수치 단일 출처화, metadata 공통 객체 |

### 1.2 dogmap.co.kr Top 5 수정

| # | 이슈 | 심각도 | 핵심 조치 |
|---|---|---|---|
| 1 | 장소 22,088곳에 개별 URL 없음 → 업체명 롱테일 유입 0 | **Critical** | 품질 기준을 통과한 장소만 상세 페이지 생성 |
| 2 | 문화정보원 자료가 2022-11-30 기준(약 4년 전)으로 노출, 폐업 미반영 위험 | **High** | 인허가 영업상태 대조, 출처별 기준일, 확인일 표기 |
| 3 | robots.txt: Cloudflare 관리형 블록이 사용자 요청형 AI 에이전트까지 차단, `*` 그룹 중복 | **High** | 관리형 robots 끄고 `app/robots.ts`로 정책 직접 관리 |
| 4 | HTML 엣지 캐시 미적용(DYNAMIC) + 404가 Next 기본 영문 페이지(title 2개, robots 충돌) | **High** | ISR/캐시 규칙, 한국어 `not-found.tsx`, 루트 robots 메타 제거 |
| 5 | 사이트 전체 og:image 없음(카톡·밴드 공유, 네이버 썸네일) | **Medium** | `opengraph-image.tsx`로 동적 OG 이미지 |

### 1.3 가장 큰 트래픽 레버 3개

1. **bokjicard /center/ → 크롤 가능한 지역 페이지**: 3,556곳의 이름·주소·전화를 HTML로 노출합니다. "[동 이름] 주민센터/행정복지센터 전화번호" 롱테일은 페이지당 수요는 작지만 합치면 큽니다(추정).
2. **dogmap 장소 상세 페이지 + 데이터 갱신 파이프라인**: 22,088곳 중 품질 기준을 통과한 곳만 색인합니다. "[업체명] 애견동반", "[동네] 애견동반 카페" 롱테일이 대상입니다.
3. **bokjicard 2027 연도 키워드 선점**: 기준중위소득·생계급여·기초연금·문화누리카드 신청 시즌(1~2월)에 앞서 지금 업데이트합니다. 계산기는 경쟁 블로그 대비 차별 자산입니다.

차순위 레버: dogmap `/vet-24h/`를 지역별로 분리("[지역] 24시 동물병원"), 산책코스를 노선 단위 허브로 묶기.

---

## 2. bokjicard.co.kr 상세 감사

### 2.1 크롤링·인덱싱

#### B-1. http가 https로 리다이렉트되지 않음 — **High**
- 근거 [확인]: `http://bokjicard.co.kr/` → 200(FACTS). canonical은 https.
- 영향: 같은 문서가 두 프로토콜로 열립니다. canonical이 있어 구글은 대체로 https를 고르지만 네이버 Yeti의 정규화 동작은 공개 근거가 약합니다(추정). 외부 링크가 http로 걸리면 신호가 나뉩니다.
- 수정(Cloudflare): SSL/TLS → Edge Certificates → **Always Use HTTPS = On**. 안정되면 HSTS(max-age부터 짧게)를 켭니다.
- 예상 효과: 중복 URL 제거, 링크 신호 통합. 순위 영향은 작지만 비용이 거의 없습니다.

#### B-2. 트레일링 슬래시 리다이렉트가 307(임시) — **Medium**
- 근거 [확인]: `/cards/disabled` → 307 → `/cards/disabled/`. dogmap은 308.
- 원인 [추정]: 응답 헤더 `content-type: text/html`(charset 없음)과 HTML `cf-cache-status: HIT`로 보아 Next 정적 export를 Cloudflare 정적 자산(Workers/Pages)으로 서빙하는 구성 같습니다. 그 계층의 html_handling 리다이렉트가 307을 내는 것으로 보입니다.
- 수정(Cloudflare Rules → Redirect Rules, 맨 앞 순서):
  ```
  조건(Expression):
  (http.host eq "bokjicard.co.kr"
   and not ends_with(http.request.uri.path, "/")
   and not http.request.uri.path contains "."
   and not starts_with(http.request.uri.path, "/opengraph-image")
   and not starts_with(http.request.uri.path, "/_next/"))
  동작: Dynamic → concat("https://bokjicard.co.kr", http.request.uri.path, "/")
  상태코드: 301 (또는 308), Preserve query string: On
  ```
  `next.config`에는 `trailingSlash: true`를 유지합니다. 내부 링크는 이미 슬래시로 끝납니다([확인]).
- 예상 효과: 영구 리다이렉트로 신호를 확실히 넘깁니다. 외부에서 슬래시 없이 링크해도 손실이 없습니다.

#### B-3. 사이트맵 lastmod가 빌드 시각으로 일괄 표기 — **Low**
- 근거 [확인]: `sitemap.xml`에서 고정 페이지 22개(/, /check/, /calc/*, /cards/* 등)의 lastmod가 모두 `2026-11-01T03:33:24.716Z`입니다. 글 49편만 실제 작성일(10-20, 10-22, 10-28)입니다.
- 영향: 구글은 lastmod가 "일관되게 정확할 때만" 활용합니다. 매 빌드마다 바뀌는 값은 신뢰를 잃습니다.
- 수정: 콘텐츠 원본(MDX frontmatter/데이터 파일)의 `updatedAt`을 `app/sitemap.ts`에 넣습니다. `changefreq`·`priority`는 구글이 무시하므로 빼도 됩니다.
  ```ts
  // app/sitemap.ts
  export default async function sitemap() {
    const cards = await getCards();
    return cards.map(c => ({ url: `https://bokjicard.co.kr/cards/${c.slug}/`, lastModified: c.updatedAt }));
  }
  ```

#### B-4. 404 페이지 robots 메타 2개 — **Low**
- 근거 [확인]: `404.html`에 `<meta name="robots" content="noindex"/>`(Next 자동 삽입)와 `noindex, follow`(not-found metadata)가 함께 있습니다. 둘 다 noindex여서 충돌은 아닙니다. 한국어 커스텀 404는 정상입니다.
- 수정: `app/not-found.tsx` metadata에서 `robots`를 빼면 자동 삽입분만 남습니다. 404 상태코드 반환 여부는 raw에 헤더 파일이 없어 이 문서에서는 다시 확인하지 못했습니다(FACTS는 "정상"으로 기록). `curl -I https://bokjicard.co.kr/없는주소/`로 404인지 한 번 더 보세요.

#### B-5. /search/ 페이지 색인 정책 미확인 — **Low**
- 근거 [확인]: 모든 페이지 헤더와 푸터에서 `/search/`로 링크합니다. 사이트맵에는 없습니다.
- 수정 [추정 필요]: 사이트 내 검색 결과 페이지는 `robots: { index: false, follow: true }`로 둡니다(`?q=` 변형이 무한히 생기는 것을 막기 위함).

### 2.2 렌더링·성능 (CWV 실측 없음)

#### B-6. `_next/static` 청크가 `max-age=0, must-revalidate` — **Medium**
- 근거 [확인]: FACTS. dogmap은 `max-age=31536000, immutable`입니다. HTML도 `public, max-age=0, must-revalidate`입니다(`home.headers`).
- 영향: 재방문·페이지 이동 때마다 청크 약 10개를 재검증 요청(304)합니다. 모바일 왕복 지연이 쌓입니다. 색인 자체에는 영향이 없고 체감 속도와 INP·LCP에 영향이 있습니다(추정).
- 수정(둘 중 하나):
  ```
  # public/_headers  (Cloudflare Pages/Workers 정적 자산)
  /_next/static/*
    Cache-Control: public, max-age=31536000, immutable
  ```
  또는 Cloudflare Cache Rules: `starts_with(http.request.uri.path, "/_next/static/")` → Eligible for cache, Edge TTL 1년, Browser TTL "Override origin" 1년.
- 예상 효과: 재방문 JS 요청이 0이 됩니다. 이 사이트는 2페이지 이상 보는 세션 비중이 높을 것이라 체감이 큽니다(추정).

#### B-7. Pretendard 웹폰트를 jsDelivr CDN CSS로 로드 — **Low~Medium**
- 근거 [확인]: `<link rel="preload" … pretendardvariable-dynamic-subset.min.css>`와 같은 파일의 `<link rel="stylesheet">`가 모두 `<head>`에 있습니다. 제3자 도메인의 렌더 차단 CSS입니다.
- 수정: `next/font/local`로 자체 호스팅하고 `display: 'swap'`을 씁니다. 필요한 굵기만 서브셋합니다. 제3자 연결(DNS+TLS)이 사라집니다.
- 예상 효과: 첫 텍스트 표시가 빨라집니다(추정). 실측 후 우선순위를 다시 정하세요.

#### B-8. JS 크기와 광고 슬롯 — **Low (측정 필요)**
- 근거 [확인]: 첫 화면 1st-party JS 약 183KB(압축) + adsbygoogle + gtag. 글 본문에 광고 슬롯 `inArticle`, `articleEnd`가 있습니다(`page_tips_munhwanuri-where-to-use_.html` RSC 페이로드).
- 권장: 광고 컨테이너에 `min-height`를 예약해 CLS를 막습니다. `/center/` 전용 청크(`1uk-f2haeoakv.js`)가 3,556곳 데이터를 통째로 싣고 있는지 번들 분석기로 확인하세요(추정). 그렇다면 2.6의 정적 지역 페이지로 옮길 때 JS도 줄어듭니다.
- 이미지 0개([확인])는 LCP 측면에서 유리합니다(LCP 요소가 텍스트).

### 2.3 메타·OG

#### B-9. Next.js metadata 얕은 병합으로 OG가 깨짐 — **Medium**
- 근거 [확인]:
  - `/center/`: `og:title`이 홈 제목이고 **`og:url`이 `https://bokjicard.co.kr/`**입니다(`page_center_.html`). 루트 layout의 openGraph가 그대로 상속된 것입니다.
  - `/tips/munhwanuri-where-to-use/`: 글 페이지가 `openGraph`를 새로 정의하면서 `og:image`·`og:url`·`og:site_name`·`og:locale`이 **사라졌습니다**. `twitter:title/description`은 홈 기본값 그대로입니다.
  - 49편이 같은 템플릿이므로 모든 글이 같을 가능성이 큽니다(추정).
- 영향: 카카오톡 공유 미리보기가 홈 제목이나 이미지 없이 뜰 수 있습니다(카카오 공유 디버거로 확인 필요). 이 사이트 주제(복지)는 가족 단톡방 공유가 핵심 유입 채널일 가능성이 큽니다(추정). 네이버도 검색 결과 대표 이미지·제목에 OG를 참고한다고 안내하는 것으로 알려져 있습니다(추정).
- 수정:
  ```ts
  // lib/meta.ts
  export const baseOG = { siteName: '복지카드 안내소', locale: 'ko_KR', type: 'website' as const };
  // app/layout.tsx : metadataBase만 두고 openGraph.url은 넣지 않는다
  export const metadata = { metadataBase: new URL('https://bokjicard.co.kr'), openGraph: { ...baseOG } };
  // app/tips/[slug]/page.tsx
  export async function generateMetadata({ params }) {
    const { slug } = await params; const p = await getPost(slug); const url = `/tips/${slug}/`;
    return {
      title: p.title, description: p.desc, alternates: { canonical: url },
      openGraph: { ...baseOG, type: 'article', url, title: p.title, description: p.desc,
                   publishedTime: p.publishedAt, modifiedTime: p.updatedAt },
      twitter: { card: 'summary_large_image', title: p.title, description: p.desc },
    };
  }
  ```
  `app/tips/[slug]/opengraph-image.tsx`(ImageResponse)로 글 제목이 들어간 이미지를 자동 생성하면 파일 기반 메타가 우선 적용되어 이미지 누락이 사라집니다.
- 예상 효과: 공유 CTR 상승. 직접적 순위 영향은 작습니다.

### 2.4 구조화 데이터

#### B-10. Article에 author·image 없음, 카드 페이지는 날짜 없음 — **Medium (E-E-A-T와 묶음)**
- 근거 [확인]: 글 JSON-LD는 `Article` + `BreadcrumbList`이고 publisher(Organization)만 있습니다. `author`·`image`가 없습니다. `/cards/disabled/`에는 작성일·수정일 표기가 없고 "2026-10-20 기준" 확인일만 있습니다(WebFetch). `/check/`·`/center/`에는 JSON-LD가 없습니다(FACTS).
- 수정:
  - Article에 `author`(실명 또는 운영자 Person + `/about/` URL), `image`(OG 이미지 URL), 실제 `dateModified`를 넣습니다.
  - 홈에 `Organization`(name, url, logo, email)을 추가합니다.
  - `/center/` 지역 페이지에 `BreadcrumbList`를, 개별 센터에는 `GovernmentOffice`(address, telephone)를 넣습니다. 구글 리치 결과 대상은 아니지만 엔티티 이해에 도움이 됩니다(추정).
  - FAQPage·HowTo는 **우선순위가 낮습니다**. 구글은 2023년부터 FAQ 리치 결과를 정부·의료 권위 사이트로 제한했고 HowTo 리치 결과는 중단했습니다.

### 2.5 E-E-A-T와 콘텐츠 정확성 (YMYL)

#### B-11. 기준중위소득 계산기가 이미 지난 정보를 보여줌 — **High**
- 근거 [확인]: `/calc/median-income/` 제목이 "기준중위소득 몇 % 계산기 2026"이고 4인 100%가 6,494,738원입니다. 본문에는 "다음 해 기준은 보통 8월에 정해진다"고 적혀 있고 **확인 기준일은 2026-11-01**입니다. 하지만 2027년 기준중위소득은 **2026-07-28 중앙생활보장위원회에서 의결**됐고(4인 기준 6.7% 인상, 언론 보도) 2027-01-01부터 적용됩니다.
- 영향: 복지·금전 정보(YMYL)에서 "확인일은 최신인데 내용은 지난 것"은 신뢰 신호에 가장 나쁜 조합입니다. 1월에 수요가 몰리는 "2027 기준중위소득" 검색을 놓칩니다.
- 수정: 계산기에 2026/2027 연도 토글을 넣습니다(1월 1일 자동 전환). `/tips/median-income-2026/`은 2027 내용을 추가하거나, 연도 없는 URL(`/tips/median-income/`)로 옮기고 연도는 title에만 둡니다. 연도 URL을 계속 쓰면 매년 새 URL이 생겨 신호가 리셋됩니다. 사이트가 생긴 지 2주라 지금 바꾸는 비용이 가장 낮습니다. 기초연금·생계급여·주거급여 계산기도 2027 값을 같이 점검하세요.

#### B-12. 저자·검수 정보 부족, 수치 불일치 — **Medium**
- 근거 [확인]:
  - `/about/`에 운영 원칙(공식 안내 2곳 이상 교차 확인, 확인일 표기, 오류 제보)은 잘 적혀 있습니다. 하지만 운영자 이름·경력·검수자가 없습니다.
  - 센터 수가 홈·메타 설명에서는 **3,556곳**, 글 하단 카드에서는 **"전국 3,533곳 번호"**입니다(`page_tips_munhwanuri-where-to-use_.html`). 센터 설명도 "주소와 우편번호, 지도"와 "주소와 전화번호"가 섞여 있습니다.
- 수정: 숫자는 데이터 파일 하나에서 계산해 모든 곳에 주입합니다(하드코딩 금지). 전화번호가 있는 센터 수를 따로 셀 거라면 "3,556곳(전화번호 3,533곳)"처럼 명시합니다. `/about/`에 운영자 소개(실명이 어렵다면 최소한 운영 경력·관련 경험), 검수 절차, 갱신 주기("매년 1월·7월 제도 개정 반영")를 넣습니다.
- 잘 된 점 [확인]: 글마다 "세 줄 요약", 공식 출처 링크(mnuri.kr 등), 확인 기준일, "공공기관 아님" 고지가 있습니다. 이 형식은 유지하세요.

#### B-13. 49편이 9일 안에 발행됨 — **Medium (위험 관리)**
- 근거 [확인]: 사이트맵 lastmod 기준 10-20(35편), 10-22(6편), 10-28(5편) 등 49편이 2026-10-20~10-28에 나왔습니다.
- 위험 [추정]: 구글 스팸 정책의 "대규모 콘텐츠 남용(scaled content abuse)"은 생산 방식(AI·사람)과 상관없이 "검색 순위용 대량 생산 + 낮은 가치"를 대상으로 합니다. 표본 글은 구체적이고 출처가 있어 질이 낮지 않습니다. 다만 앞으로 늘릴 때는 속도보다 "공식 출처 대조 + 사람 검수 + 수정일 관리"를 유지하는 쪽이 안전합니다.

### 2.6 내부 링크·정보구조와 잠식 점검 (GSC 이전 방식)

#### B-14. 카드(필러) ↔ 꿀팁(위성) 링크 단절 — **High**
- 근거 [확인]: `/cards/disabled/` 본문에는 개별 꿀팁 링크가 0개입니다(내비 `/tips/`만 있음, WebFetch). `/tips/munhwanuri-where-to-use/`는 다른 문화누리 글 2개, 보조금24, /center/로 링크하지만 **`/cards/culture/`로는 링크하지 않습니다**. 브레드크럼은 `꿀팁 › 문화누리카드`인데 "문화누리카드"가 링크가 아닙니다.
- 수정: 카드 페이지마다 "관련 꿀팁" 블록(같은 카드 태그 글 자동 나열)을 넣습니다. 글 브레드크럼의 카드명은 해당 `/cards/{slug}/`로 링크합니다. 꿀팁 본문 첫 언급에 카드 페이지 앵커 링크를 겁니다.
- 예상 효과: 필러 페이지로 권위를 모으고, 구글·네이버에 "이 주제의 대표 문서"를 알려 잠식을 예방합니다.

#### B-15. 주제 중복 쌍 — 소유 페이지 지정 필요 — **High (잠식 예방)**

GSC가 없으므로 사이트맵 URL과 확인한 title 기준으로 의도 겹침을 점검했습니다. **GSC 연결 후 4~8주 데이터로 `page+query` 재검증이 필수**입니다.

| 겹치는 검색어(추정) | 페이지 A | 페이지 B | 지정 소유자 | 다른 쪽 조치 |
|---|---|---|---|---|
| 기준중위소득 (2027) / 기준중위소득 계산 | /calc/median-income/ | /tips/median-income-2026/ | "계산·몇 %" = calc / "표·금액·변경점" = tips | title 겹침 제거: calc는 "계산기", tips는 "2027 기준중위소득표·인상률" |
| 기초연금 금액·모의계산 | /calc/basic-pension/ | /tips/basic-pension-2026/ | 계산 = calc / 수급 조건·신청 = tips | 상호 링크, 연도 URL 정리 |
| 장애인연금 | /calc/disability-pension/ | /tips/disability-pension/ | 같은 원칙 | 같은 원칙 |
| 주거급여 | /calc/housing-benefit/ | /tips/housing-benefit/ | 같은 원칙 | 같은 원칙 |
| 장기요양 본인부담 | /calc/long-term-care/ | /tips/long-term-care/ | 같은 원칙 | 같은 원칙 |
| 활동지원 | /calc/activity-support/ | /tips/activity-support/ | 같은 원칙 | 같은 원칙 |
| 장애인복지카드 신청·혜택 | /cards/disabled/ ("장애인복지카드 신청 방법" [확인]) | /apply/, /tips/disabled-card-discounts/, /tips/after-disability-registration/ | 신청 = cards/disabled / 할인 혜택 목록 = tips/disabled-card-discounts | /apply/는 "복지카드 신청 방법 총정리(카드별 비교)"로 범용화하고 카드별 신청은 cards로 링크 |
| 국민행복카드 | /cards/happy/ | /tips/happy-card-compare/ | 개요·신청 = cards / "카드사별 비교" = tips | |
| 복지카드 종류 | /cards/ | /tips/two-kinds-of-welfare-card/, /tips/integrated-welfare-card/, /tips/confusing-names/ | 종류 = /cards/ | 세 글은 각자 좁은 의도("통합복지카드란", "이름 헷갈림")로 title 고정 |
| 잔액조회 | /tips/check-balance/ | /tips/munhwanuri-balance/ | 범용 = check-balance / 문화누리 = munhwanuri-balance | 범용 글은 카드별 잔액조회 글로 링크 |
| 행정복지센터 | /center/ | /tips/before-you-visit-center/, /tips/where-to-ask/ | 찾기·연락처 = center | 글은 "방문 전 준비물", "어디에 물어야 하나" 의도 유지 |

**확인 필요**: 각 카드/계산기/꿀팁 페이지의 실제 title·H1. 이번 감사에서 직접 확인한 것은 `/cards/disabled/`, `/calc/median-income/`, `/tips/munhwanuri-where-to-use/`, `/center/`뿐입니다.

### 2.7 [최대 레버] /center/ 3,556곳 → 크롤 가능한 지역 페이지 — **Critical**

- 근거 [확인]: `/center/` HTML에는 H1, 안내문, 빈 `<select>` 세 개("선택하세요"), "지역을 고르면… 여기에 나와요"뿐입니다. 센터명·주소·전화가 HTML에 **하나도 없습니다**. 개별 센터·지역 링크도 0개입니다. 메타 설명은 "전국 3,556곳"이라고 약속합니다.
- 영향: 검색엔진 입장에서 이 페이지는 520자짜리 빈 도구 페이지입니다. "역삼1동 주민센터 전화번호" 같은 질의에 답할 문서가 사이트에 없습니다.

**설계안**

| 계층 | URL 예시 | 개수 | 색인 |
|---|---|---|---|
| 시도 | `/center/seoul/` | 17 | index |
| 시군구 | `/center/seoul/gangnam-gu/` | 약 250(추정, 행정구 포함) | index. **해당 구의 모든 센터 이름·주소·전화를 HTML 표로** |
| 읍면동 | `/center/seoul/gangnam-gu/yeoksam1-dong/` | 3,556 | **품질 기준 통과 시에만** index |

- URL 표기: 영문 로마자와 한글 모두 가능합니다. 한글 URL은 검색 결과에서 읽기 좋지만 카톡 공유 시 퍼센트 인코딩으로 길어집니다. 하나를 고르고 바꾸지 마세요. dogmap은 "영문 시도 + 한글 시군구"를 섞어 씁니다([확인], `/places/cafe/seoul/마포구/`). bokjicard는 처음부터 한 가지로 통일할 것을 권합니다.
- 구현(App Router, 빌드 시 정적 생성):
  ```ts
  // app/center/[sido]/[sigungu]/page.tsx
  import { notFound } from 'next/navigation';
  export const dynamicParams = false;
  export async function generateStaticParams() {
    return (await listSigungu()).map(s => ({ sido: s.sidoSlug, sigungu: s.slug }));
  }
  export async function generateMetadata({ params }) {
    const { sido, sigungu } = await params; const g = await getSigungu(sido, sigungu);
    return {
      title: `${g.name} 행정복지센터(주민센터) ${g.centers.length}곳 주소·전화번호`,
      description: `${g.fullName} 읍·면·동 행정복지센터 ${g.centers.length}곳의 주소, 전화번호, 관할 동을 정리했습니다. 자료 기준 ${g.dataDate}.`,
      alternates: { canonical: `/center/${sido}/${sigungu}/` },
    };
  }
  export default async function Page({ params }) {
    const { sido, sigungu } = await params; const g = await getSigungu(sido, sigungu);
    if (!g) notFound();
    return (/* H1 + 표(센터명 | 주소 | tel: 전화 | 관할 법정동) + 이 구에서 쓰는 지역 복지카드 + 인접 구 링크 */);
  }
  ```
  `/center/` 본 페이지에는 선택 UI를 유지하되 그 아래 **시도 17개 링크 목록을 SSR로** 깔아 크롤 경로를 만듭니다. `app/sitemap.ts`에서 `generateSitemaps()`로 지역 사이트맵을 분리합니다(예: `sitemap/center.xml`).

**얇은 콘텐츠·스팸 정책을 피하는 조건** (구글 스팸 정책의 scaled content abuse·doorway에 대응, 네이버 저품질 판정에도 같은 원칙 적용 [추정])
1. **페이지마다 고유 사실 데이터**: 최소 센터명+도로명주소+전화(tel: 링크)는 있어야 합니다. 읍면동 페이지는 여기에 아래 중 2개 이상이 더 있을 때만 index합니다: 관할 법정동·리 목록(행정동-법정동 매핑, "우리 동네가 어느 센터 관할인지"라는 실제 문제를 풂), 팩스, 무인민원발급기 위치(공공데이터), 인근 센터, 해당 시군구 자체 바우처·복지카드(예: 지역 아동급식카드 명칭). 이 조건을 못 채우면 `noindex, follow`로 두고 시군구 페이지 안의 앵커로 대신합니다.
2. **템플릿 문구 최소화**: "복지카드는 주소지 읍·면·동에서 신청" 같은 공통 안내는 한두 줄로 줄이고 나머지는 꿀팁 링크로 넘깁니다. 같은 문단을 3,556번 반복하지 마세요.
3. **출처·기준일·갱신 주기 표시**: "행정안전부 공공데이터, 2026-xx 기준" 같은 형식입니다. 행정동은 수시로 분동·통폐합되므로 갱신 주기(분기 1회 등)를 정하고 바뀐 페이지는 301로 처리합니다.
4. **검색 수요가 있는 계층부터 점진 공개**: 1단계는 시도+시군구(약 270페이지)로, 이것만으로 3,556곳 정보가 모두 HTML에 실립니다. GSC·서치어드바이저에서 색인과 노출을 4~6주 확인한 뒤 2단계로 읍면동을 엽니다.
5. **사이트맵에는 index 대상만**: noindex 페이지를 사이트맵에 넣지 않습니다.
6. **광고 밀도**: 데이터 표보다 광고가 먼저 보이지 않게 합니다(AdSense '가치가 낮은 콘텐츠' 거절 위험도 같이 낮아짐 [추정]).
7. **공공데이터 이용 조건 확인**: 공공누리 유형(출처 표시 의무 등)을 확인하세요.

- 경쟁·기대치(추정): "○○동 주민센터" 질의는 네이버 플레이스, 구글 지도 팩, 각 구청 홈페이지가 위를 차지합니다. 페이지당 클릭은 작지만 3,000여 개가 합쳐지면 이 사이트에서 가장 큰 롱테일 풀입니다. 차별점은 "관할 법정동 → 센터"와 "복지카드 신청 준비물 연결"입니다.

### 2.8 네이버 대응
- [확인] `naver-site-verification` 메타가 있고 `rss.xml`은 robots에 등록돼 있습니다. `User-Agent: *` 허용이므로 Yeti도 허용됩니다.
- [미확인] 서치어드바이저에 사이트맵·RSS를 제출했는지, 수집 현황이 어떤지.
- 할 일:
  1. 서치어드바이저 → 요청 → 사이트맵 제출(`/sitemap.xml`, 지역 사이트맵 분리 시 각각), RSS 제출(`/rss.xml`).
  2. **IndexNow**: 네이버는 2023-07부터 IndexNow를 지원합니다(보도·커뮤니티 기준이며 공식 공지로 재확인 권장). 같은 키로 Bing에도 전파됩니다. 빌드 후 변경 URL을 `https://searchadvisor.naver.com/indexnow` 또는 `api.indexnow.org`로 POST합니다.
  3. 웹페이지 수집 요청: 새 핵심 페이지(지역 허브, 2027 기준중위소득)는 수동 수집 요청을 넣습니다.
  4. Yeti의 JS 실행 능력은 제한적인 것으로 알려져 있습니다(추정). 지금처럼 SSR을 유지하고 /center/ 데이터는 반드시 HTML로 냅니다.
  5. 다음 웹마스터도구, Bing Webmaster Tools 등록(점유율은 작지만 비용이 거의 없음).

### 2.9 AI 검색 노출
- [확인] robots가 전체 허용이고 llms.txt는 없습니다.
- 평가: AI 검색 인용에 불리한 설정은 없습니다. 구글 AI Overviews는 Googlebot 색인을 쓰므로 일반 SEO가 곧 AI 노출입니다. "세 줄 요약"처럼 답을 앞에 두는 형식은 인용에 유리합니다(추정).
- llms.txt — **Low**: 주요 검색엔진이 쓴다고 확인된 바가 없어 효과가 불확실합니다. 만드는 비용이 작으니 핵심 URL 20개 정도의 목록만 두는 정도로 충분합니다.
- dogmap과 정책을 일부러 다르게 할 이유가 없다면 두 사이트의 AI 크롤러 정책을 통일하세요(3.6 참고).

---

## 3. dogmap.co.kr 상세 감사

### 3.1 크롤링·인덱싱

#### D-1. 404 페이지가 Next 기본 영문 페이지, title 2개, robots 충돌 — **High**
- 근거 [확인]: `404.html`에 `<title>들어가개 — 애견동반 카페·식당·동물병원 지도</title>`와 `<title>404: This page could not be found.</title>`가 **둘 다** 있습니다. `<meta name="robots" content="noindex"/>`와 `content="index, follow"`도 함께 있습니다. 본문은 "This page could not be found."(영문)입니다.
- 영향: 구글은 더 제한적인 noindex를 따르지만 다른 크롤러가 충돌을 어떻게 해석하는지는 보장되지 않습니다(추정). 사용자 경험도 나쁩니다(이탈). 루트 layout이 모든 페이지에 `index, follow`를 박고 있다는 뜻이기도 해서, 나중에 noindex가 필요한 페이지(얇은 목록, /saved/)에서도 같은 충돌이 납니다.
- 수정:
  ```ts
  // app/layout.tsx — robots 필드 삭제(기본값이 index,follow), title 템플릿 사용
  export const metadata = { metadataBase: new URL('https://dogmap.co.kr'),
    title: { default: '들어가개 — 애견동반 카페·식당·동물병원 지도', template: '%s | 들어가개' } };
  // app/not-found.tsx
  export const metadata = { title: '페이지를 찾을 수 없습니다' };
  export default function NotFound() { /* 한국어 안내 + 업종·지역 허브 링크 + /find/ */ }
  ```
  배포 후 `curl -I`로 404 상태코드를 확인하세요.

#### D-2. HTML 엣지 캐시 미적용(DYNAMIC) — **High**
- 근거 [확인]: `home.headers`에 `cf-cache-status: DYNAMIC`, `cache-control: public, max-age=0, must-revalidate`가 있습니다. TTFB 0.3~0.8s입니다.
- 영향: 매 요청이 오리진(Next SSR)까지 갑니다. 상세 페이지 수만 개를 추가하면 크롤 부하와 TTFB가 커집니다. 크롤러가 서버 응답 속도에 맞춰 크롤 속도를 조절하므로 대규모 색인 속도에 직접 영향을 줍니다(추정).
- 수정(권장 순서):
  1. Next 쪽: 목록·코스·가이드·상세 페이지를 `generateStaticParams` + `export const revalidate = 86400`(ISR)로 정적 생성합니다. 데이터가 하루 단위로 바뀌지 않으면 충분합니다.
  2. Cloudflare Cache Rules:
     ```
     조건: http.host eq "dogmap.co.kr" and (
       starts_with(http.request.uri.path, "/places/") or starts_with(http.request.uri.path, "/courses/")
       or starts_with(http.request.uri.path, "/guide/") or http.request.uri.path eq "/vet-24h/")
     동작: Eligible for cache, Edge TTL = 1일(Ignore origin), Browser TTL = Respect origin
     캐시 키: Query string 포함(기본값 유지)
     ```
     `/api/`, `/find/?q=`, `/saved/`는 제외합니다. **주의**: Next 클라이언트 내비게이션의 RSC 요청은 `_rsc` 쿼리와 `RSC` 헤더로 구분됩니다. Cloudflare는 `Vary`를 따르지 않으므로 쿼리스트링을 캐시 키에서 빼면 RSC 페이로드가 HTML 요청에 섞일 수 있습니다. 적용 후 브라우저 직접 접속과 내부 링크 이동을 모두 테스트하세요.
- 예상 효과: TTFB 단축(엣지 HIT), 크롤 처리량 증가.

#### D-3. robots.txt — **High** (AI 노출) / **Low** (형식)
- 근거 [확인] `robots.txt`:
  - Cloudflare 관리형 블록이 학습 크롤러(GPTBot, ClaudeBot, Google-Extended, CCBot 등) **외에** 사용자 요청형 에이전트까지 차단합니다: `ChatGPT-User`, `Claude-User`, `Perplexity-User`, `Google-Agent`, `meta-externalfetcher`, `MistralAI-User` 등. `GoogleOther`, `Baiduspider`, `PetalBot`도 막혀 있습니다.
  - 차단되지 **않은** 것: `Yeti`(네이버), `Googlebot`, `Bingbot`, `Daum`, `OAI-SearchBot`, `PerplexityBot`, `Claude-SearchBot`. 일반 검색과 AI 검색 색인용 봇은 열려 있습니다.
  - `User-agent: *` 그룹이 2개이고(두 번째에 `Disallow: /api/`), `Host:` 지시어(구글은 무시)가 있습니다. `rss.xml`은 미등록입니다.
- 영향:
  - 사용자가 ChatGPT·Claude·Perplexity에서 "이 링크 열어서 확인해줘"라고 하거나 답변 생성 중 실시간 조회할 때 페이지를 가져오지 못합니다. **AI 답변 속 인용·방문 유입이 줄어듭니다**(추정). Google-Extended 차단은 구글 검색과 AI Overviews 노출에 영향이 없습니다(구글 공식 설명).
  - `*` 그룹 중복: RFC 9309와 구글은 같은 UA 그룹을 합쳐 읽습니다. 다른 크롤러는 첫 그룹만 읽을 수도 있습니다(추정). 첫 그룹에는 `/api/` 차단이 없습니다.
- 수정:
  1. Cloudflare 대시보드에서 관리형 robots.txt(AI Crawl Control / Bots 메뉴의 "robots.txt 관리" 계열 설정, 메뉴명은 시기에 따라 다름)를 **끕니다**. 같은 화면의 "AI 봇 차단(WAF 수준)" 토글도 확인하세요. 그 토글은 robots와 무관하게 요청 자체를 403 처리합니다.
  2. Next에서 직접 관리합니다:
     ```ts
     // app/robots.ts
     import type { MetadataRoute } from 'next';
     export default function robots(): MetadataRoute.Robots {
       return {
         rules: [
           { userAgent: '*', allow: '/', disallow: ['/api/'] },
           // 학습용만 차단(사업 판단). 사용자 요청형·AI 검색 봇은 허용
           { userAgent: ['GPTBot', 'ClaudeBot', 'Google-Extended', 'CCBot', 'Bytespider', 'Applebot-Extended', 'meta-externalagent'], disallow: '/' },
         ],
         sitemap: ['https://dogmap.co.kr/sitemap.xml', 'https://dogmap.co.kr/rss.xml'],
       };
     }
     ```
  3. `/saved/`(개인 저장 목록)는 robots로 막지 말고 페이지 metadata에서 `robots: { index: false }`로 처리합니다. robots로 막으면 noindex를 읽지 못합니다.
- 예상 효과: AI 어시스턴트 경유 방문 회복, 정책 명확화.

#### D-4. 사이트맵 — **Medium**
- 근거 [확인]: URL 3,322개. `/find/`(검색 페이지)가 포함돼 있습니다. 1지점짜리 얇은 목록 페이지도 포함됐을 가능성이 있습니다(FACTS: "천안시 동남구 반려견 놀이터 1곳"). 상위 페이지 lastmod는 빌드 시각입니다.
- 수정: `/find/`는 사이트맵에서 빼고 `?q=` 변형은 noindex 처리합니다. `WebSite` SearchAction은 구글이 사이트링크 검색창을 종료(2024)해 효과가 없으므로 유지해도 되고 빼도 됩니다. 3.3의 얇은 페이지 규칙에 따라 noindex 대상은 사이트맵에서 제외합니다. 상세 페이지를 추가하면 `generateSitemaps()`로 업종별·지역별로 분할합니다(파일당 5만 URL 이하).

#### D-5. Cloudflare 이메일 난독화와 RSC 평문 노출 — **Low**
- 근거 [확인]: 푸터 이메일은 `/cdn-cgi/l/email-protection`으로 난독화됐지만, 같은 HTML의 RSC 페이로드(`self.__next_f.push`)에 `mailto:` 주소가 평문으로 들어 있습니다. 난독화가 무력화된 상태에서 `email-decode.min.js`만 추가로 로드됩니다.
- 수정: 스팸 방지가 목적이면 문의 폼으로 바꿉니다. 아니면 Cloudflare Scrape Shield의 Email Obfuscation을 꺼서 스크립트 하나를 줄입니다.

### 3.2 렌더링·성능 (CWV 실측 없음)

#### D-6. 홈 히어로 동영상 `preload="auto"` — **Medium (측정 필요)**
- 근거 [확인]: 홈에 `<video … preload="auto">`(poster 없음)와 `<video poster="/hero/walk-poster.webp" preload="none">` 두 개가 있습니다.
- 영향(추정): 모바일에서 첫 화면에 동영상 바이트를 미리 받아 대역폭을 다투고, LCP 후보(포스터 이미지) 표시가 늦어질 수 있습니다.
- 수정: 첫 번째 video를 `preload="none"`으로 바꾸고 포스터를 `<link rel="preload" as="image" fetchpriority="high">`로 올립니다. 재생은 `requestIdleCallback` 이후, `prefers-reduced-motion`·`saveData`일 때는 재생하지 않습니다.

#### D-7. 대형 단일 페이지 — **Low**
- 근거 [확인]: `/vet-24h/` 한 페이지가 265KB입니다. 3.5에서 지역 분리를 하면 자연히 해결됩니다.

### 3.3 얇은 콘텐츠·중복

#### D-8. 1곳짜리 목록 페이지와 템플릿 비중 — **High**
- 근거 [확인]: "천안시 동남구 반려견 놀이터 1곳" 같은 페이지가 본문 약 1,700자이고 대부분 공통 템플릿입니다(FACTS). 마포구 카페 페이지 표본은 고유 텍스트가 대략 25~35%로 보입니다(WebFetch 판단, 추정).
- 위험: 업종(9) × 시군구 조합 1,824페이지 중 결과가 1~2곳인 조합이 상당수면 doorway/얇은 페이지 신호가 됩니다(추정). 정확한 분포는 데이터에서 직접 세야 합니다.
- 수정 규칙(예시, 기준값은 데이터 분포를 보고 조정):
  ```ts
  const indexable = list.places.length >= 3 || list.places.some(p => p.richFields >= 3);
  export async function generateMetadata(...) {
    return { robots: indexable ? undefined : { index: false, follow: true } };
  }
  ```
  noindex 페이지는 사이트맵에서 빼고, 상위(시도 업종 페이지)나 같은 시군구의 "모든 반려 장소" 통합 페이지로 사용자를 안내합니다. 공통 안내(목줄 2m, 색 범례, 출처)는 접기(`<details>`)로 줄입니다.

#### D-9. 산책코스 — 구간 단위 고유명, 내부 링크 부족 — **Medium**
- 근거 [확인]: 코스 1,431구간. 상세 title은 "서울둘레길 7코스 4구간 — 2.5km 급경사 7곳 | 들어가개" 형식입니다. 상세 페이지에는 주변 카페·병원·공원으로 가는 **지역 링크가 없고** `/places/cafe/` 같은 전국 허브 링크만 있습니다(WebFetch). 출처는 두루누비 GPX입니다.
- 영향(추정): 실제 검색은 "서울둘레길 7코스", "서울둘레길 강아지", "둘레길 반려견 동반" 같은 **노선·코스 단위**로 일어나고 "4구간"까지 치는 경우는 드뭅니다.
- 수정: 노선·코스 허브(`/courses/seoul/seoul-dulle-7/`)를 만들어 구간을 묶습니다. 허브에 코스 전체 거리, 경사 요약, 반려견 동반 규정, 화장실·주차, 주변 애견동반 카페를 넣습니다. 구간 페이지는 허브와 상호 링크하고 같은 시군구의 카페·동물병원·공원 목록으로 링크합니다. 구간 페이지 title은 지금처럼 고유하게 두되 허브가 "서울둘레길 7코스 강아지"를 소유하게 합니다.

### 3.4 [최대 레버] 개별 장소 상세 페이지 — **Critical**
- 근거 [확인]: `/find/`에 "애견동반 장소 22,088곳"이 나옵니다. 마포구 카페 목록 96곳의 업체명은 모두 링크 없는 평문입니다(tel:·외부 홈페이지 링크만 있음). 96곳 중 25곳은 한국문화정보원 자료(2022-11-30 기준)로 전화·운영시간·이용료·동반 조건 등이 풍부합니다. 나머지는 식약처 출처로 이름과 주소 위주입니다.
- 영향: "[업체명] 강아지 동반", "[업체명] 애견동반 가능" 같은 업체명 질의에 대응할 URL이 없습니다. 목록 페이지는 한 URL이 수십 곳을 대표해 개별 업체 의도와 맞지 않습니다.

**설계안**
- URL: `/place/{id}/`처럼 안정적인 ID를 씁니다(업종·지역이 바뀌어도 URL 유지). 이름은 title·H1에 넣고, 브레드크럼으로 `/places/{업종}/{시도}/{시군구}/` 계층을 표현합니다.
- 내용: 업체명, 주소, 전화(tel:), 운영시간, **동반 조건(견종·크기·실내/실외·추가 요금)**, 주차, 출처·기준일, **최근 확인일**, 지도·길찾기 링크(네이버지도·카카오맵 딥링크), 주변 산책코스·공원·24시 동물병원, 같은 동 다른 애견동반 장소, 정보 수정 제보 버튼.
- 구조화 데이터: `CafeOrRestaurant`/`LocalBusiness`(name, address, telephone, geo, openingHoursSpecification) + `amenityFeature`(반려동물 동반) + `BreadcrumbList`. 이후 목록 페이지 `ItemList`에 상세 URL을 넣습니다.
- 구현:
  ```ts
  // app/place/[id]/page.tsx
  export const revalidate = 86400;           // ISR
  export const dynamicParams = true;          // 미리 생성하지 않은 ID도 첫 요청에 생성
  export async function generateStaticParams() { return (await topPlaces(2000)).map(p => ({ id: p.id })); }
  export async function generateMetadata({ params }) {
    const p = await getPlace((await params).id); if (!p) notFound();
    return {
      title: `${p.name} 애견동반 정보 — ${p.sigungu} ${p.typeLabel}`,
      alternates: { canonical: `/place/${p.id}/` },
      robots: isQualityPlace(p) ? undefined : { index: false, follow: true },
    };
  }
  ```

**얇은 콘텐츠·스팸 위험을 피하는 조건**
1. **품질 게이트**: `영업 중 확인` + (`전화` 또는 `운영시간`) + `동반 조건 1개 이상` + `확인일 2년 이내`일 때만 index와 사이트맵 포함. 이름·주소만 있는 곳은 상세 페이지를 만들지 않거나 noindex로 두고 목록에만 남깁니다. 마포 표본 비율(96곳 중 25곳이 풍부 데이터)로 보면 처음 색인 대상은 전체의 일부에 그칠 수 있습니다(추정, 전체 분포는 직접 계산).
2. **사실 데이터 중심**: AI로 업체 소개문을 지어내 채우지 않습니다. 확인되지 않은 동반 가능 여부를 단정하지 않습니다(지금처럼 "확인된 것만 색으로"라는 원칙을 상세 페이지에도 유지).
3. **점진 공개**: 서울·경기·부산·제주 등 수요가 큰 지역의 풍부 데이터 장소 수백 곳부터 시작합니다. 색인율·노출을 확인한 뒤 확대합니다.
4. **오래된 정보 표시**: 기준일이 오래된 장소는 "방문 전 전화 확인"을 상단에 두고, 폐업 확인 시 410 또는 목록 페이지로 301합니다.
5. **내부 링크 도달성**: 모든 색인 상세 페이지가 목록 → 상세로 2~3클릭 안에 닿아야 합니다(고아 페이지 금지).

- 기대치(추정): 업체명 질의는 네이버 플레이스·지도가 압도하므로 페이지당 클릭은 작습니다. 반면 "○○카페 강아지 동반 되나요" 같은 확인형 질의는 플레이스에 답이 없는 경우가 많아 틈새가 있습니다.

### 3.5 데이터 신선도 (2022-11-30 기준) — **High**
- 근거 [확인]: 목록 상단에 "이 목록의 자료는 2022-11-30 기준입니다 (약 4년 전 · 96곳 중 25곳)", 각 항목에 "자료 기준 2022-11-30 (약 4년 전)"이 나옵니다. `/vet-24h/` 출처는 "문화정보원 전국 동물병원 정보 (최종작성 2025-03-24)"입니다.
- 영향: 폐업·이전한 업체 안내는 사용자 피해로 이어지고(헛걸음), 신뢰 신호와 재방문을 깎습니다. 또 상단 문구가 목록 **전체**가 4년 묵은 것처럼 보이게 합니다. 실제로는 일부(25/96)만 해당합니다.
- 수정:
  1. **출처별 기준일 분리 표기**: "식약처 자료 ○○○○-○○ 기준 71곳 · 문화정보원 2022-11-30 기준 25곳"처럼 나눕니다. 최신 출처 날짜를 앞에 둡니다.
  2. **영업상태 대조**: 지방행정 인허가 데이터(LOCALDATA. 공공데이터포털 이관 여부와 제공 형태는 확인 필요)의 일반·휴게음식점, 동물병원, 동물미용업 등 영업상태(영업/폐업)를 사업장명+주소로 매칭해 폐업 업체를 내리거나 표시합니다(추정: 매칭률은 직접 검증 필요).
  3. 공공데이터포털에서 문화정보원 반려동물 동반 데이터의 더 최신 버전이 있는지 확인합니다(추정).
  4. 장소별 "최근 확인일"과 사용자 제보로 갱신하는 흐름을 만들고, 사이트맵 lastmod에 실제 갱신일을 반영합니다.
  5. 2025년 식품위생법 개정으로 반려견 동반 음식점 제도가 생긴 뒤 식약처 쪽 데이터가 계속 늘 수 있습니다(추정). 수집 주기를 월 1회 등으로 자동화합니다.

### 3.6 24시 동물병원 지역 분리 — **Medium (레버)**
- 근거 [확인]: `/vet-24h/` 한 페이지에 206곳이 H2(서울 64, 경기 67…)로 나뉘어 있습니다. 각 H2에 `/places/vet/{시도}/` "전체 보기" 링크가 있습니다. 병원 상세 링크는 없습니다.
- 수정: `/vet-24h/{시도}/`(17개)를 만들고, 2곳 이상인 시군구만 `/vet-24h/{시도}/{시군구}/`로 둡니다. "강남 24시 동물병원", "분당 24시 동물병원" 같은 지역 질의를 겨냥합니다.
- 잠식 방지: `/places/vet/{시도}/{시군구}/`는 "[지역] 동물병원"을, `/vet-24h/...`는 "[지역] 24시 동물병원 / 야간 동물병원"을 소유합니다. 두 페이지의 title·H1에 같은 주요 키워드를 쓰지 않습니다. 일반 동물병원 목록 상단에 24시 페이지 링크를 고정합니다. 마포 카페 페이지의 "밤에 급할 때" 섹션([확인])은 좋은 패턴입니다.

### 3.7 메타·OG·구조화 데이터
- **og:image 사이트 전체 없음 — Medium** [확인]: `twitter:card=summary_large_image`인데 이미지가 없습니다. `app/opengraph-image.tsx`(기본)와 `app/places/[type]/[sido]/[sgg]/opengraph-image.tsx`("마포구 애견동반 카페 96곳" 텍스트 렌더)를 추가하세요. 반려동물 장소는 카톡·밴드·인스타 공유가 많은 주제입니다(추정).
- **홈 title — Low** [확인]: "애견동반 카페·식당·동물병원 찾기"(브랜드 없음). H1은 "강아지랑 같이 갈 수 있는 곳"입니다. 권장: "애견동반 카페·식당·펜션 지도 | 들어가개". 홈은 "애견동반 장소"(범용)를 소유하고 지역·업종 키워드는 하위 페이지에 넘깁니다.
- **수치 불일치 — Low** [확인]: 서울 카페 페이지 H1은 "692곳", 지도 주석은 "전체 691곳 기준"입니다. 단일 데이터 소스에서 계산하세요.
- 구조화 데이터 [확인]: 홈 Organization+WebSite(SearchAction), 목록 BreadcrumbList+ItemList, 코스 Place+BreadcrumbList. 상세 페이지 도입 후 ItemList 항목에 `url`을 넣습니다. 가이드 46편에 Article이 있는지는 미확인입니다.

### 3.8 네이버 대응
- [확인] `naver-site-verification` 메타가 있고 `rss.xml`은 200입니다. 일부 페이지(404 등)에 `<link rel="alternate" type="application/rss+xml">`가 있지만 **홈 `<head>`에는 없습니다**. robots에는 RSS가 없습니다. Yeti는 차단되지 않았습니다.
- 할 일: 서치어드바이저에서 사이트맵·RSS 제출, IndexNow 연동(상세 페이지 추가 시 대량 신규 URL 알림), 수집 현황에서 Cloudflare 보안 기능(Bot Fight Mode 등)이 Yeti를 막지 않는지 확인합니다(Cloudflare Security Events에서 Yeti UA 필터, 추정 점검 항목). RSS에는 가이드 신규 글과 갱신된 지역 페이지를 넣습니다.

### 3.9 AI 검색 노출
- D-3 참고. 요약: 일반 검색봇과 AI 검색 색인봇(OAI-SearchBot, PerplexityBot, Claude-SearchBot)은 열려 있습니다. 하지만 **사용자 요청형 fetcher가 막혀** AI 답변에서 실시간 인용·링크 열람이 어렵습니다. llms.txt는 없고 **Low**입니다(효과 불확실).
- 차별 데이터(구간별 경사, 노견·단두종 주의, 자연공원 경계 판정)는 AI 답변이 인용하기 좋은 고유 사실입니다. 상세·허브 페이지 상단에 한 문장 요약("총 2.5km, 급경사 7곳, 국립공원 밖")으로 두세요(추정).

---

## 4. 두 사이트 공통 권장
1. **측정 기반 먼저**: 두 사이트 모두 GSC 도메인 속성(Cloudflare DNS TXT)과 서치어드바이저 사이트맵·RSS 제출 상태를 확인합니다. 4~8주 뒤 `page+query`로 잠식을 다시 검증합니다(2.6 표 기준).
2. **루트 layout metadata 정리**: `robots`·`openGraph.url`을 루트에서 빼고, 공통 OG 객체는 스프레드로 병합하고, title 템플릿을 씁니다. 두 사이트 모두 같은 빌드 계열이라 한 번 고치면 둘 다 적용됩니다.
3. **www 처리 확인**: `www.` 호스트가 www 없는 도메인(apex)으로 301되는지 확인합니다(이번에 확인 불가).
4. **같은 운영자 신호**: 같은 AdSense pub·같은 빌드는 문제가 아닙니다. 다만 두 사이트를 서로 링크로 엮는다면 사용자에게 의미 있는 곳(예: "반려동물 관련 복지" 같은 주제)에만 거세요.
5. **현실적인 기대치**: 두 사이트 모두 신생(bokjicard 글은 2026-10-20 이후)이고 기준 트래픽 데이터가 없습니다. 하루 1,000 자연 방문은 위 레버를 실행한 뒤에도 수개월 단위로 봐야 합니다(추정). 구체적인 일정 예측은 GSC 노출 데이터가 쌓인 뒤에 하세요.

---

## 5. 키워드 클러스터 (수요 등급은 모두 [추정])

### 5.1 bokjicard.co.kr

| 클러스터 | 대표 검색어 | 의도 | 수요 | 소유 페이지(현재/신규) | 비고 |
|---|---|---|---|---|---|
| 행정복지센터 | "[동명] 주민센터 전화번호", "[동명] 행정복지센터", "주민센터 운영시간", "주민센터 점심시간" | 내비게이션·로컬 | 개별 하 / 합계 상 | /center/{시도}/{시군구}/(신규) | 플레이스·지도 팩과 경쟁 |
| 기준중위소득 | "2027 기준중위소득", "기준중위소득 계산기", "기준중위소득 몇 퍼센트" | 정보·도구 | 상(1월 정점) | tips(표), calc(계산) | 지금 업데이트 |
| 생계·주거·의료급여 | "생계급여 수급자격", "생계급여 금액 2027", "주거급여 신청 조건" | 정보·도구 | 상 | calc/livelihood·housing-benefit / tips | |
| 기초연금 | "기초연금 수급자격", "기초연금 금액 2027", "기초연금 모의계산" | 정보·도구 | 상 | calc/basic-pension / tips | |
| 장애인복지카드 | "장애인복지카드 신청", "장애인복지카드 혜택", "장애인 할인 혜택", "모바일 장애인등록증" | 정보·거래 | 중~상 | cards/disabled, tips/disabled-card-discounts, tips/mobile-disability-id | |
| 문화누리카드 | "문화누리카드 사용처", "문화누리카드 잔액조회", "문화누리카드 신청 기간", "문화누리카드 온라인 사용처" | 정보 | 상(2~3월 신청, 연말 소진) | cards/culture + tips 4편 | 시즌 대비 |
| 국민행복카드·임신출산 | "국민행복카드 사용처", "국민행복카드 카드사 비교", "첫만남이용권", "임신 바우처" | 정보·상업 | 상 | cards/happy, tips/happy-card-compare 등 | |
| 에너지바우처 | "에너지바우처 신청", "에너지바우처 잔액조회", "에너지바우처 사용법" | 정보 | 중(겨울 정점) | cards/energy, tips 2편 | 11월 지금이 시즌 초입 |
| 아동급식카드 | "아동급식카드 사용처", "꿈나무카드"(서울), 지역별 명칭 | 정보 | 중 | cards/child-meal, tips/child-meal-card-name | 지역 명칭별 섹션 |
| 교통 복지 | "어르신 교통카드 발급", "지하철 무임승차 나이", "장애인 버스 요금" | 정보 | 중 | cards/senior·transit, tips 3편 | |
| 모두의카드 | "모두의카드 환급률", "모두의카드 신청" | 정보 | 중~상(신규 제도라 변동 큼) | tips/modu-card-refund-rate | 제도명·내용은 공식 자료로 재확인 |
| 차상위·긴급복지 | "차상위계층 조건", "긴급복지지원 신청" | 정보 | 중~상 | tips/near-poor, tips/emergency-welfare | |

### 5.2 dogmap.co.kr

| 클러스터 | 대표 검색어 | 의도 | 수요 | 소유 페이지(현재/신규) | 비고 |
|---|---|---|---|---|---|
| 지역 애견동반 카페 | "애견동반 카페 서울", "강남 애견동반 카페", "부산 애견동반 카페", "제주 애견동반 카페" | 상업·로컬 | 상 | /places/cafe/{시도}/{시군구}/ | 블로그·플레이스 경쟁 심함 |
| 애견동반 식당 | "애견동반 식당 [지역]", "강아지 동반 식당" | 상업 | 중~상 | /places/cafe/... (카페·식당 통합) | "식당" 단독 의도는 카페 페이지 title에서 함께 다룰지, 분리할지 데이터 보고 결정 |
| 애견동반 숙소·여행 | "애견동반 펜션 가평", "애견동반 숙소 강원도", "애견동반 여행지", "강아지랑 가볼만한곳" | 상업 | 상 | /places/stay/..., /places/travel/... | OTA·블로그 경쟁 |
| 애견동반 캠핑 | "애견동반 캠핑장 [지역]" | 상업 | 중 | /places/camp/... | |
| 24시 동물병원 | "24시 동물병원 [지역]", "야간 동물병원", "강남 24시 동물병원" | 긴급·로컬 | 중~상 | /vet-24h/{시도}/(신규) | 3.6 잠식 규칙 |
| 동물병원 | "[지역] 동물병원" | 로컬 | 상(플레이스 압도) | /places/vet/... | 기대치 낮게 |
| 반려견 놀이터 | "반려견 놀이터 [지역]", "애견운동장 무료" | 정보·로컬 | 중 | /places/dogrun/... | 공원 페이지와 title 구분 |
| 산책코스 | "강아지 산책코스 [지역]", "서울둘레길 강아지", "둘레길 반려견 동반" | 정보 | 중 | /courses/{시도}/, 노선 허브(신규) | 경사 데이터가 차별점 |
| 업체명 롱테일 | "[업체명] 애견동반", "[업체명] 강아지 동반 가능" | 확인형 | 개별 하 / 합계 중 | /place/{id}/(신규) | 품질 게이트 |
| 산책 가이드 | "강아지 산책 온도", "아스팔트 온도 강아지", "국립공원 강아지 출입", "목줄 길이 법" | 정보 | 중(여름 정점) | /guide/... | 산책 지수 도구와 연결 |

---

## 6. 실행 순서 제안

| 주차 | bokjicard | dogmap |
|---|---|---|
| 1 | Always Use HTTPS, 301 슬래시 규칙, `_next/static` 캐시, 2027 기준중위소득 업데이트, 수치 단일화 | 관리형 robots 끄고 `app/robots.ts`, 한국어 404, 루트 robots 메타 제거, og:image |
| 2 | OG 메타 수정, 카드↔꿀팁 내부 링크, title 겹침 정리(2.6 표) | HTML 엣지 캐시/ISR, 얇은 목록 noindex 규칙, `/find/` 사이트맵 제외 |
| 3~4 | /center/ 1단계(시도+시군구) 배포, 사이트맵 분리, 서치어드바이저 제출, IndexNow | 데이터 신선도 파이프라인(영업상태 대조, 출처별 기준일) |
| 5~8 | GSC `page+query` 잠식 재검증, 읍면동 2단계 판단 | 상세 페이지 1차(풍부 데이터 장소 수백 곳), `/vet-24h/` 지역 분리, 코스 허브 |

---

## 7. 근거 파일·출처

로컬 원본([확인]):
- `/home/user/agency/audits/raw/FACTS.md`
- `/home/user/agency/audits/raw/bokjicard.co.kr/` — `robots.txt`, `sitemap.xml`, `home.headers`, `404.html`, `page_center_.html`, `page_tips_munhwanuri-where-to-use_.html`
- `/home/user/agency/audits/raw/dogmap.co.kr/` — `robots.txt`, `sitemap.xml`(일부), `home.html`, `home.headers`, `404.html`

라이브 확인(WebFetch, 2026-11-01): bokjicard `/cards/disabled/`, `/about/`, `/calc/median-income/`; dogmap `/places/cafe/seoul/`, `/places/cafe/seoul/마포구/`, `/vet-24h/`, `/courses/`, `/courses/seoul/`, `/courses/seoul/f01-44/`, `/find/`

외부 출처(맥락, [추정] 등급):
- [디지털데일리 — 상반기 검색 점유율 64.28%, 네이버 1위 격차 확대 (2026-07)](https://www.ddaily.co.kr/page/view/2026071214223169501)
- [인사이트 — 네이버 56.0%, 구글 35.55%, 빙 3.59% (2026-07)](https://www.insight.co.kr/news/474140)
- [GeekNews — 네이버 서치어드바이저 IndexNow 지원](https://news.hada.io/topic?id=19225)
- [경향신문 — 2027년 기준중위소득 의결 (2026-07-28)](https://www.khan.co.kr/article/202607281741011/)
- [파이낸셜뉴스 — 2027년 기준중위소득 관련 보도](https://www.fnnews.com/news/202607281804264729)
