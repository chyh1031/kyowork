# 개발 백로그 (자동 루프용)

이 문서는 자동 개발 루프가 판단 없이 순서대로 처리하기 위한 작업 목록이다.
**규칙**: 위에서부터 순서대로 처리한다. 각 작업은 완료 기준을 통과해야 다음으로 넘어간다.
"🛑 사람 확인 필요" 항목은 자동 루프가 절대 임의로 진행하지 않고, 도달하면 멈추고 보고한다.

## 진행 규칙

1. 작업 하나 시작 전 `TaskList`/`TaskGet`으로 현재 상태 확인, 시작 시 `in_progress`로 표시
2. 구현 후 반드시: `mobile`과 `server` 양쪽에서 `npm run typecheck && npm run lint` 통과
3. 실행 가능한 검증(예: `expo export --platform ios`로 번들 확인, 서버 유닛 테스트)까지 통과해야 `completed`
4. 작업 하나당 커밋 하나. 커밋 메시지는 어떤 작업 항목을 완료했는지 명확히
5. 완료 후 이 파일에서 체크박스를 `[x]`로 표시하고 커밋에 포함
6. 실제 API 키, 실기기, 계정 생성처럼 이 환경에서 할 수 없는 항목은 건너뛰지 말고 멈춰서 보고
7. 이미 결정된 사항(스키마 필드명, 폴더 구조, 네이밍)을 임의로 바꾸지 않는다 — 바꿔야 할 이유를 발견하면 진행 대신 보고

---

## Must (v1 MVP) 잔여 작업

- [x] **M1. 서버 mock 모드** — `ANTHROPIC_API_KEY`가 없거나 `MOCK_AI=true`일 때 `server/lib/anthropic.ts`가 고정 fixture listing을 반환하도록 분기 추가. 실제 API 키 없이도 전체 플로우(모바일→서버→응답) 검증 가능해야 함. 완료 기준: 키 없이 `vercel dev` 또는 로컬 핸들러 호출 시 유효한 `Listing` JSON 반환.
- [x] **M2. 서버 유닛 테스트 도입** — `vitest` 설치, `api/generate.ts` 핸들러를 mock Anthropic 클라이언트로 테스트(성공/400/502 케이스, M1 mock 모드 포함). 완료 기준: `npm test` 통과, 실제 Anthropic API 호출 없음. (M3보다 먼저 처리 — M3가 이 테스트 인프라를 필요로 함)
- [x] **M3. 서버 입력 검증 강화** — `photoBase64` 크기 상한(예: 6MB, base64 기준) 초과 시 400 응답. 완료 기준: M2에서 도입한 vitest로 초과/정상 케이스 모두 검증.
- [x] **M4. 모바일 이미지 리사이즈** — `expo-image-manipulator`로 전송 전 장변 1024px, quality 0.6 리사이즈 후 base64 인코딩. `photoService.ts`에 적용. 완료 기준: typecheck/lint 통과 + 번들 검증.
- [ ] **M5. AI 생성 타임아웃/재시도 UI** — `aiService.ts`에 `AbortController` 15초 타임아웃 추가. `capture.tsx`에 실패 시 "다시 시도" 버튼 노출(현재는 Alert만 있음). 완료 기준: 타임아웃/네트워크 에러 시 result 화면이 아닌 재시도 UI로 이동하는 상태 분기 코드 확인.
- [ ] **M6. 권한 거부 처리** — `photoService.ts`에서 카메라/앨범 권한이 "다시 묻지 않음"으로 거부된 경우 `Linking.openSettings()`로 유도하는 Alert 분기 추가. 완료 기준: 권한 상태별(`granted`/`denied`/`undetermined`) 분기 로직 존재.
- [ ] **M7. 온보딩 1회만 표시** — `@react-native-async-storage/async-storage` 설치, 최초 실행 여부 저장. `app/_layout.tsx`에서 완료 여부에 따라 `index`(온보딩) 또는 `capture`로 초기 분기. 완료 기준: typecheck/lint 통과 + 로직에 대한 간단한 유닛 테스트(순수 함수로 분리해서 테스트 가능하게).
- [ ] **M8. 참고 가격 문구 노출** — `capture.tsx` 결과 화면에 "AI 추천 참고가이며 실제 거래가와 다를 수 있어요" 같은 문구를 가격 옆에 상시 노출(기획서 리스크 대응). 완료 기준: 화면 코드에 해당 문구 렌더링 확인.
- [ ] **M9. 🛑 사람 확인 필요 — 실기기 테스트** — 여기 도달하면 멈추고 보고만 한다. 물리 기기/EAS 빌드가 필요해 이 환경에서 수행 불가.

## Should (v1.5) — 미리 준비 가능한 것

- [ ] **S1. Supabase 스키마 설계 문서만 작성** — `server/` 또는 `docs/`에 `listings`, `users`, `feedback`(판매완료 피드백) 테이블 스키마안을 SQL DDL로 작성 (실제 Supabase 프로젝트 연결 없이 문서만). 완료 기준: DDL 파일 존재, 필드가 `mobile/src/schemas/listing.ts`와 호환.
- [ ] **S2. 마이페이지 정적 화면 스캐폴딩** — 데이터 연동 없이 더미 데이터로 "내가 등록한 물건 목록" UI만. `app/mypage.tsx`. 완료 기준: typecheck/lint/번들 통과.
- [ ] **S3. 🛑 사람 확인 필요 — Supabase 프로젝트 생성/키 발급** — 계정 소유가 필요해 자동 진행 불가.
- [ ] **S4. 🛑 사람 확인 필요 — 공유카드 이미지 실제 디자인 확정** — 브랜딩/톤 결정이 필요해 자동 진행 불가. 기술 스파이크(react-native-view-shot 등 후보 조사)까지는 자동 진행 가능.

---

## 자동 루프가 절대 임의로 정하면 안 되는 것 (항상 🛑)

- `ANTHROPIC_API_KEY`, Supabase URL/키 등 실제 크리덴셜 발급·등록
- 앱 이름/로고/색상 팔레트 등 최종 브랜딩
- 가격 추천 알고리즘의 실제 비즈니스 파라미터(마진율, 카테고리별 보정치 등)
- 스토어 제출·결제·과금이 발생하는 모든 행위
- 이미 커밋된 스키마 필드명/폴더 구조를 바꾸는 리팩터링 (필요하다고 판단되면 진행 대신 보고)
