# MiddlePoint — 중고거래 AI 어시스턴트

사진 한 장 → AI가 제목/설명/가격을 생성해주는 중고거래 판매글 도우미. 상세 기획은 대화 히스토리 참고.

## 저장소 구조

- `mobile/` — Expo (React Native + TypeScript) 클라이언트. Expo Router 사용.
- `server/` — Vercel Functions. Claude Vision API 프록시 (AI 키를 클라이언트에 노출하지 않기 위한 서버리스 계층).
- `legacy/` — 이 저장소의 이전(무관한) Xcode/Kakao지도 iOS 네이티브 프로젝트. 참고용으로만 보존, 새 개발은 여기 손대지 않음.

## mobile/ (Expo 클라이언트)

- 진입점: `expo-router/entry` → 라우트는 `app/` 폴더 (`app/index.tsx` 온보딩, `app/capture.tsx` 촬영→AI생성→복사 플로우)
- `src/services/` — photoService(카메라/앨범), aiService(서버 프록시 호출), clipboardService(복사)
- `src/schemas/listing.ts` — AI 응답 zod 스키마. **`server/lib/schema.ts`와 필드가 반드시 일치해야 함** (모노레포 공유 패키지 없이 수동 동기화 — MVP 단계라 의도적으로 단순하게 유지)
- import 별칭 `@/*` → `src/*`
- 명령어: `npm start` / `npm run ios` / `npm run android` / `npm run lint` / `npm run typecheck` / `npm run format` / `npm test` (vitest, 순수 로직만 — 컴포넌트 렌더링 테스트 아님)
- 환경변수: `.env.example` 참고 (`EXPO_PUBLIC_API_BASE_URL`)

## server/ (Vercel Functions)

- `api/generate.ts` — POST `/api/generate`, body `{ photoBase64 }` → `{ listing }`
- `lib/anthropic.ts` — Claude Vision 호출, tool-use로 구조화된 JSON 강제 추출 (자유형 JSON 파싱보다 안정적)
- 모델은 `ANTHROPIC_MODEL` 환경변수로 교체 가능 (기본값 `claude-sonnet-5`) — 비용 튜닝 시 Haiku 등으로 전환 고려
- 명령어: `npm run dev` (vercel dev) / `npm run lint` / `npm run typecheck` / `npm test` (vitest, 실제 API 호출 없음)
- 환경변수: `.env.example` 참고 (`ANTHROPIC_API_KEY`)
- Vercel 프로젝트 연결 시 Root Directory를 `server`로 설정

## 개발 환경 참고사항

- `expo install`, `expo export` 등 Expo CLI가 내부적으로 호출하는 원격 호환성 체크(React Native Directory API)가 이 환경 프록시에서 차단될 수 있음 → 이 경우 `npm install <pkg>`로 직접 설치하거나 `EXPO_OFFLINE=1` 환경변수를 붙여서 실행
- 커밋 전 최소 게이트: `mobile`과 `server` 양쪽에서 `npm run typecheck && npm run lint` 통과 확인

## 아직 없는 것 (다음 단계)

- Supabase Auth/등록이력 저장 (2주차 예정)
- 공유카드 이미지 생성 (3주차 예정)
- 실제 Claude Vision 프롬프트 튜닝 및 가격 정확도 검증 (아직 실기기/실API 테스트 안 됨)

## 다음 작업 목록

`BACKLOG.md` 참고. 자동/반복 세션은 이 파일을 위에서부터 순서대로 처리하고,
"🛑 사람 확인 필요" 항목에 도달하면 임의로 진행하지 않고 멈춰서 보고한다.
API 비용 방지를 위해 자동 루프의 테스트는 fixture 목킹만 사용하고, 실제
Anthropic API를 반복 호출하지 않는다 (`MOCK_AI=true` 참고, BACKLOG.md M1).
