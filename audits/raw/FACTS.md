# 수집된 사실 (2026-11-01, curl로 직접 측정)

원본 파일: `audits/raw/<도메인>/` (home.html, robots.txt, sitemap.xml, page_*.html, *.headers, 404.html)

## 공통
- 두 사이트 모두 Next.js (turbopack 빌드, 같은 청크 이름 공유) + Cloudflare. 같은 AdSense 퍼블리셔(ca-pub-5978949128100777) → 같은 운영자.
- GA4: bokjicard G-WS1B4R2HFR, dogmap G-ML5XE5BCZV. 둘 다 naver-site-verification 메타 있음.
- SSR 정상: 본문 텍스트가 HTML에 들어 있음. html lang="ko". 페이지마다 canonical(절대 URL) + robots index,follow.
- 이미지(<img>) 0개 — 홈/샘플 페이지 모두.
- 첫 화면 1st-party JS(압축) 약 183KB(bokji) / 192KB(dogmap) + adsbygoogle + gtag.
- llms.txt 없음, manifest.json 없음(dogmap은 manifest.webmanifest 있음), ads.txt 있음.
- www.<도메인>은 이 환경 프록시에서 막혀 확인 불가(리다이렉트 여부 미확인).
- PageSpeed Insights API는 429로 측정 불가 → Core Web Vitals 실측 없음.

## bokjicard.co.kr (복지카드 안내소)
- sitemap.xml 75 URL: / , /check/, /calc/(8 계산기), /center/, /cards/(8 카드), /apply/, /use/, /tips/(49 글), /about/, /privacy/. rss.xml 있음(robots에 등록).
- robots.txt: `User-Agent: * Allow: /` + sitemap, rss.
- **http://bokjicard.co.kr/ → 200 (https로 리다이렉트 안 함)**. canonical은 https.
- **트레일링 슬래시 리다이렉트가 307(임시)**: /cards/disabled → /cards/disabled/ . (dogmap은 308)
- **_next/static JS 청크 cache-control: max-age=0, must-revalidate** (dogmap은 max-age=31536000, immutable).
- HTML cf-cache-status HIT (엣지 캐시됨). TTFB 0.26~0.85s.
- 홈 title "복지카드 안내소 — 복지카드 신청·사용처·꿀팁을 한 화면에"(32자). JSON-LD: 홈 WebSite만, /cards/·/tips/ Article+BreadcrumbList, /calc/ BreadcrumbList, /check/·/center/ 없음.
- **/center/ (행정복지센터 찾기): meta description은 "전국 3,556곳"이라 하는데 HTML 본문 520자, 개별 센터/지역 링크 0개** → 3,556곳 데이터가 클라이언트 측 선택 UI로만 노출, 크롤 가능한 지역 페이지 없음.
- /tips/munhwanuri-where-to-use/ 에 og:image 없음 (다른 샘플 페이지는 동일한 사이트 공통 og 이미지 1장).
- 콘텐츠 볼륨: 글 49 + 카드 8 + 계산기 8. 글 1편 본문 약 2,000자. 모두 2026-10-20 이후 작성(사이트 신생으로 추정).
- 404: noindex 메타가 2개(noindex / noindex,follow) 중복, 한국어 커스텀 404 정상.

## dogmap.co.kr (들어가개 — 애견동반 장소·산책코스)
- sitemap.xml 3,322 URL: /places/{업종}/{시도}/{시군구}/ 1,824개, /courses/{시도}/{id}/ 1,443개, /guide/ 46편, /vet-24h/, /popular/, /find/.
- http → https 301 정상. 슬래시 308.
- **robots.txt: Cloudflare 관리형 AI 차단 블록 포함** — GPTBot, ClaudeBot, Google-Extended 외에 **ChatGPT-User, Perplexity-User, Claude-User, Google-Agent, meta-externalfetcher, Baiduspider, GoogleOther** 등도 Disallow. Content-Signal: search=yes, ai-train=no. `User-agent: *` 그룹이 2개(두 번째에 Disallow: /api/), Host 지시어. rss.xml 200이지만 robots에 미등록.
- HTML cf-cache-status DYNAMIC (엣지 캐시 안 됨). TTFB 0.3~0.8s.
- **og:image 없음(사이트 전체)** — twitter:card=summary_large_image인데 이미지 없음. 카톡/밴드 공유 썸네일 없음.
- 홈 title "애견동반 카페·식당·동물병원 찾기"(18자, 브랜드명 없음). JSON-LD: 홈 Organization+WebSite, 목록 BreadcrumbList+ItemList, 코스 Place+BreadcrumbList.
- **개별 장소 상세 페이지 없음**: 목록 페이지(지역×업종)에 업체 이름·전화(tel:)·주소만 나열, 업체별 URL 없음 → "[업체명] 애견동반" 롱테일 검색 유입 불가.
- 목록 페이지에 "이 목록의 자료는 2022-11-30 기준(약 4년 전)" 문구 노출 — 데이터 신선도 이슈.
- 1지점짜리 얇은 페이지 다수 가능성(예: "천안시 동남구 반려견 놀이터 1곳", 본문 약 1,700자 대부분 공통 템플릿).
- 코스 상세 title 예: "서해랑길 12코스 6구간 — 2.5km 급경사 1곳 | 들어가개" — 검색량 낮은 고유명 위주.
- /vet-24h/ "24시 동물병원 206곳" 한 페이지 265KB, 강한 콘텐츠(지역별 h2). 지역별 분리 페이지 없음.
- **404 페이지: Next.js 기본 영문 404 ("This page could not be found."), title 깨짐("…지도404: This page could not be found."), robots 메타 noindex와 index,follow 동시 존재.**
- /guide/ 46편, 본문 약 6,000자 목록.
