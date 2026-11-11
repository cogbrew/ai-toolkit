# 컴포넌트와 스토어 작성

## defineProps
- 스크립트가 값을 쓰지 않으면 구조 분해하지 않고 `defineProps<{ ... }>()` 를 단독으로 호출함. 옵셔널이라도 기본값을 주려고 구조 분해하지 않음(템플릿은 undefined 를 falsy 로 다룸). 막는 실수: 쓰지 않는 구조 분해와 기본값이 쌓이는 일.
- 스크립트에서 값을 계산하거나 참조할 때만 구조 분해함(Vue 3.4 이상).

## script setup 배치 순서
1. import
2. 컴파일러 매크로(defineProps, defineEmits, defineOptions), 무조건 최상단
3. 상태(ref, reactive)
4. computed
5. 함수와 이벤트 핸들러
6. 연결(watch, watchEffect, onMounted, onUnmounted), 맨 아래

- watch 는 생명주기와 한 무리로 맨 아래에 둠. immediate 인 watch 가 아래쪽 const 함수를 부르면 TDZ 로 화면이 안 뜨는데, 맨 아래에 두면 그럴 자리가 없음. 컴포저블 안에서도 같음.
- 핸들러 순서는 이름이 정함. 조회(openDetail) 다음에 쓰기(openCreate, openEdit, confirmDelete). 템플릿에 나오는 순서로 잡지 않음. 막는 실수: 버튼 하나를 옮길 때 스크립트까지 따라 고치는 일.

### 컴포저블 선언 순서
1. 프레임워크와 UI(useRouter, useRoute, useToast)
2. 자체 컴포저블(useResultToast, useListQuery)
3. 스토어(useUiStore, useUserStore)

- 인스턴스를 선언한 직후의 구조 분해는 빈 줄 없이 붙여 씀.
- 스토어에서 꺼낸 것은 한 줄 띄우고 따로 모으며 상태가 먼저, 액션이 나중임(`const { profile } = storeToRefs(userStore);` 다음에 `const { updatePreference } = userStore;`).
- 컴포저블에 넘기는 값(스토어의 액션 등)은 그 호출보다 위에 선언함. 이 규칙이 위 순서보다 우선함. 기준은 컴포저블 호출 한 줄이고, 넘기는 것만 그 줄 위로 올리고 상태 다음에 액션 순서는 유지함. 막는 실수: TDZ 로 화면이 통째로 비고 UI 에는 표시가 없는 일.

## 임포트 순서
값 먼저 타입 나중, 각 묶음 안에서 먼 것에서 가까운 것으로, 컴포넌트는 맨 아래로 모음.

1. 값: 외부 패키지, 공용(`@/composables`, `@/definitions`, `@/utils`), 이 앱
2. 타입 전용: 외부 패키지, 공용(`@/types`), 이 앱
3. 컴포넌트: 공용(App*), 이 앱

- vue 는 외부 패키지 안에서 맨 위임. 그 파일이 vue 를 쓰지 않으면(스토어) pinia 가 첫 줄임.
- 타입 전용 임포트는 외부 패키지라도 아래로 내림. 예외를 두면 규칙이 늘고 기억하는 사람과 아닌 사람이 갈림.
- 컴포넌트를 아래로 몰면 위쪽 열 줄만 읽어도 이 화면이 무엇에 기대는지 보임.
- 임포트는 별칭 절대경로만 씀(`@/layouts/...`). 상대경로(`./`, `../`)는 쓰지 않음.

## 제네릭 컴포넌트의 타입
`<script setup generic="...">` 안에서 export interface 나 export type 을 선언하면 TS1044 가 남. 같은 디렉토리에 `<컴포넌트>.types.ts` 를 만들고 import type 으로 가져옴.

## 페이지 높이
앱 셸이 Dashboard 트랙(UDashboardGroup 이 fixed inset-0 으로 뷰포트를 점유)이면 본문이 스크롤 컨테이너이고 페이지는 그 안에서 그려짐.

| 클래스 | 동작 | 판정 |
|---|---|---|
| `min-h-screen` | 100vh 고정이라 헤더 높이만큼 넘쳐 스크롤이 생김 | 쓰지 않음 |
| `h-full` | 부모 높이에 고정되어 넘치면 place-content-center 가 상단을 잘라냄 | 쓰지 않음 |
| `min-h-full` | 부모 높이 이상을 확보하고 콘텐츠는 늘어남 | 씀 |

- 최소 높이는 두 종류이며 섞지 않음. 페이지 바닥은 앱 셸이 중앙에서 통제하고 페이지와 표에 하드코딩하지 않음. 컴포넌트 최소(표가 헤더와 4행과 빈 상태가 안 잘리는 높이)는 그 컴포넌트가 자기 것으로 가짐. 막는 실수: 전역 크기 방어가 페이지마다 흩어지는 일.

## Pinia 스토어

### 서버 호출은 스토어만
- 화면과 컴포저블이 HTTP 를 직접 부르지 않고, HTTP 는 스토어만 부르며 URL 은 앱의 api/ 가 만듦.
- 액션은 `{ data, errors }` 를 그대로 올림. 토스트를 띄우더라도 반환은 그대로임. 막는 실수: 실패를 삼켜 호출부가 알 수 없는 일. 예외(로그아웃처럼 실패해도 진행해야 하는 경우)를 늘릴 때는 그 자리에 이유를 적음.
- 응답 계약은 `apiCall<T>` 의 제네릭에 걸고 반환 타입은 따로 적지 않음. 응답을 읽는 곳이 없으면 제네릭도 적지 않고 읽을 곳이 생길 때 붙임. 응답을 읽을 때 타입에는 서버가 주는 칸을 다 적음. 화면이 만든 모양(표 한 줄)은 해당하지 않음.
- 상태는 그것을 쓰는 컴포넌트들의 가장 가까운 공통 부모가 갖고, 페이지를 넘어 살아야 할 때만 스토어에 둠. 막는 실수: 형제에게 알릴 신호를 스토어에 따로 만드는 일.

### 만드는 방식
- Setup Store 로만 만듦(`defineStore('id', () => { ... })`). Option Store 를 쓰지 않음. 다른 컴포저블(useRouter, useResultToast)을 그대로 주입할 수 있기 때문임.
- Setup Store 는 $reset() 을 기본으로 주지 않고 부르면 던짐. plugins/pinia.ts 가 모든 스토어에 설치 시점 스냅샷으로 되돌리는 $reset 을 심고, 리셋 액션을 손으로 만들지 않음.
- 페이지를 떠날 때 그 페이지의 스토어를 `onUnmounted(() => { useMemberStore().$reset(); })` 로 되돌림. 상태가 없어도 붙임(나중에 상태가 생겼을 때 빠뜨리지 않기 위함). 위치는 script setup 의 맨 아래 연결 자리임.
- 한 스토어는 한 자원(백엔드 엔드포인트)임. 페이지가 아니라 자원으로 나눔(deployUser, deployReport, deployHistory). 액션이 늘어나기 전에 나눔. 막는 실수: 한 자원을 두 화면이 쓸 때 깨지고, 한 파일에 쌓인 액션이 어느 자원 것인지 안 보이는 일.

### 파일의 모양
- 순서: import, 컴포저블(useResultToast), 상태, 함수, return. 상태는 함수 위에 모음.
- 임포트는 값 먼저 타입 나중이고 각각 먼 것에서 가까운 것으로 내려옴(위 임포트 순서와 같음).
- 함수 순서: 조회(fetchXList, fetchXDetail), 쓰기(createX, updateX, deleteX), 옵션(내부 헬퍼 fetchOptions, fetchFilterOptions, fetchFormOptions).
- return 은 정의 순서 그대로이며 내부 헬퍼는 뺌. 막는 실수: 이 스토어가 무엇을 하는지 두 번 읽게 되는 일.
- 같은 요청을 타입만 달리 부를 때는 함수를 나누지 않고 제네릭만 가름. 내부 헬퍼 `fetchOptions<TOptions>(option, params)` 를 내보내지 않고, `fetchFilterOptions()` 와 `fetchFormOptions(field)` 가 각자 제네릭과 키를 고정해 부름. 막는 실수: 호출부가 문자열 키와 제네릭을 틀리게 짝지어도 아무도 막지 못하는 일.

### 컴포넌트 밖에서 쓰기
router/index.ts 와 guard.ts 처럼 컴포넌트 밖에서는 그 시점에 앱 인스턴스가 없을 수 있음. 파일 최상단이 아니라 콜백 안에서 `useUserStore()` 를 부름(`router.beforeEach(async (to) => { const userStore = useUserStore(); ... })`).

### 상태를 꺼내는 방법
| 언제 | 대상 | 방법 |
|---|---|---|
| 라우터 가드, 한 번 검사 | 상태와 getter | 직접 접근(`store.isAuthenticated`) |
| 템플릿 바인딩, 스크립트에서 여러 번 | 루트 스토어의 상태와 getter | `storeToRefs(store)` |
| 템플릿 바인딩, 스크립트에서 여러 번 | 중첩된 reactive 객체 | Vue 의 `toRefs(store.sidebar)` |
| 액션 | 함수 | 그냥 구조 분해(`const { fetchProfile } = store`) |

- storeToRefs 는 루트 스토어용이라 중첩 객체에는 안 통함.
- 값을 넣을 때도 같은 표를 따름(`const { isOpen } = toRefs(uiStore.sidebar); isOpen.value = false;`). 한 파일 안에서 읽기와 쓰기가 다른 모양이면 줄마다 확인하게 됨.

### 상태를 바꾸는 법
- 단순 UI 상태는 직접 대입하거나 v-model 로 묶고 래퍼 함수를 만들지 않음.
- 비즈니스 로직은 액션으로 만듦. 부수효과(API, 라우팅)가 있거나 여러 상태를 함께 바꿀 때임.
- 여러 값을 한 번에 바꿀 때는 $patch 로 묶어 갱신이 한 번만 돌게 함.
