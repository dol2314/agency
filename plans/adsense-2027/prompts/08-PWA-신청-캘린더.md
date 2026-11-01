# 프롬프트 08 — PWA + 신청 캘린더 (앱의 데이터 소스)

## 목표
(1) 웹을 홈 화면에 설치할 수 있게 하고, (2) 복지 신청 일정 데이터를 한곳에서 관리해 웹 캘린더·.ics·앱 알림이 같은 데이터를 쓰게 한다.

## Claude Code에게
```
1. 신청 일정 데이터: lib/calc/data/calendar-2027.json
   항목: id, title, target(대상 요약), category(어르신/장애인/아이/저소득/회사/공통), apply_start, apply_end(없으면 null=상시), amount_hint, official_url, source_name, checked_at, verified
   - 문화누리카드, 에너지바우처, 근로·자녀장려금 정기신청, 장애인 고용부담금 신고·납부, 기초연금(상시), 연말정산 등. 날짜는 공식 공고로 확인한 것만 verified:true. 매년 비슷하지만 확정 전이면 "예정"으로 표시.
   - 빌드 시 public/data/calendar-2027.json 으로 그대로 공개(앱이 받아 감). 스키마 버전 필드 포함.
2. /calendar/ 페이지: 월별 목록, 카테고리 필터, 각 항목에 "캘린더에 추가(.ics)" 버튼과 관련 계산기 링크. 지난 일정은 접어서 표시.
3. .ics 생성: 항목별·카테고리별 파일(public/ics/*.ics)을 빌드 시 생성. 알림(VALARM) 시작 7일 전·마감 3일 전. 설명에 공식 링크와 사이트 링크.
4. PWA: manifest(이름, 짧은 이름, 아이콘 192/512/maskable, theme_color, start_url "/?source=pwa", display standalone), 서비스 워커는 계산기 페이지와 data JSON을 오프라인 캐시(네트워크 우선, 실패 시 캐시). 광고 스크립트는 캐시하지 않는다.
5. 설치 안내: 안드로이드 크롬 beforeinstallprompt 버튼, iOS는 "공유 → 홈 화면에 추가" 안내 문구. 계산 결과 아래에만 작게.
6. GA4 이벤트 calendar_add{item_id}, pwa_install.
7. Lighthouse(설치된 크롬 사용)로 PWA·성능 점수를 측정해 보고하라.
```

## 완료 조건
- /calendar/ 공개, .ics가 휴대폰 캘린더에 정상 등록됨(운영자 확인)
- public/data/calendar-2027.json 스키마 검증 테스트 통과
