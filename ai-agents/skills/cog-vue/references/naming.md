# 이름 짓기

## 케이스
| 대상 | 케이스 | 예시 |
|---|---|---|
| 변수, 함수 | camelCase | `isLoading`, `fetchProfile` |
| interface, type, class | PascalCase | `ApiError`, `UserProfile` |
| Vue 컴포넌트 파일 | PascalCase | `MemberTable.vue` |
| 유틸과 훅 파일 | camelCase | `useListQuery.ts`, `axios.ts` |
| 상수와 선언(사전, 컬럼, 탭, 폼 스키마) | UPPER_SNAKE_CASE | `USER_FIELD_LABELS`, `MEMBER_COLUMNS` |

- 상수 파일 이름은 camelCase 그대로이고 내보내는 이름만 대문자임.
- definitions/ 의 파일은 `<가족><종류>.ts` 로 지음(memberConstants.ts, memberFormSchema.ts). 폴더를 나누지 않으므로 파일 이름이 무엇인지 말해야 함.
- 앞자리는 가족 이름을 씀. 한 앱의 페이지와 스토어와 컬럼과 모달이 같은 이름으로 시작해야 한 덩어리로 보임(MemberPage, useMemberStore, memberColumns, MemberDetailModal). 타입은 예외로 백엔드 모델 이름을 따름.

## 사전 상수는 내용물을 접미사로 밝힘
| 접미사 | 담는 것 | 예시 |
|---|---|---|
| `_LABELS` | 화면에 나갈 말 | `USER_FLAG_LABELS` |
| `_COLORS` | 뱃지 색(success, neutral) | `ACTION_COLORS` |
| `_BAR_COLORS` | 배경 클래스(bg-success) | `SYNC_STATUS_BAR_COLORS` |
| `_TEXT_COLORS` | 글자색 클래스(text-error) | `CONFIRM_TEXT_COLORS` |
| `_ICONS` | 아이콘 이름 | `CONFIRM_ICONS` |

- 앞머리는 대상임(USER_FLAG_, ISSUE_LEVEL_). BOOLEAN_LABELS 처럼 성격으로 부르면 범위가 실제보다 넓어 보임.
- 말과 색을 한 객체에 묶지 않음. 묶으면 쓰는 쪽이 한 겹을 더 열고 하나만 필요한 화면도 통째로 가져감. 두 곳 이상에서 함께 필요할 때만 사전 둘은 앱 definitions/ 에, 꺼내는 함수는 utils/ 에 둠.
- 막는 실수: 열어 보기 전에는 말인지 색인지 알 수 없는 이름.

## 함수 인자
- payload, data, params, args 같은 범용 이름을 쓰지 않고 내용을 말하는 이름(ids, email)을 씀. 구조가 정해지지 않은 제네릭 유틸만 예외임. 막는 실수: 타입을 열어 봐야 내용물을 아는 일.

## 선언 키워드
| 구분 | 대상 | 키워드 |
|---|---|---|
| 상태와 값 | ref, reactive, computed | const |
| 순수 함수 | 인자로 계산해 값만 돌려주는 유틸과 getter | const |
| 액션과 로직 | 이벤트 핸들러, API 호출, 상태 변경 | function |

- 순수 변환은 돌려주는 것으로 `to<결과>` 라 부름(toTableColumn). 동사를 붙이면 build, make, create 중 사람마다 갈림. 함수를 돌려주면 to무엇Renderer 처럼 그렇다고 적음. 표시용 문자열은 `format<대상>` 임.
- 이 이름은 함수를 만들어야 할 때의 규칙임. 한 곳에서만 쓰는 변환은 함수로 만들지 않고 쓰는 자리에 둠.
- API 를 부르는 래퍼는 function 임. const 화살표는 호이스팅이 안 돼 선언 순서에 묶임.

## 스토어 액션 접두어
| 접두어 | 의미 | 예시 |
|---|---|---|
| `fetch` | 서버 조회(비동기) | `fetchProfile()` |
| `create` | 새로 생성(비동기) | `createMember()` |
| `update` | 수정(비동기) | `updateMember()` |
| `delete` | 삭제(비동기) | `deleteMembers()` |
| `reset` | 서버가 값을 새로 정해 바꿈(비동기) | `resetMemberPassword()` |
| `set` | 로컬 상태 직접 설정(동기) | `setPageLoading(loading)` |
| `clear` | 상태 초기화(동기) | `clearSidebar()` |
| `toggle` | 로컬 불리언 반전(동기) | |

- 로컬 데이터를 돌려주는 get 은 함수 대신 computed 를 씀.
- 접두어는 HTTP 메서드가 아니라 서버에 남기느냐로 고름. POST 지만 아무것도 남기지 않는 조회는 fetch 임.
- 목록과 상세는 List, Detail 접미사로 가름(fetchMemberList, fetchMemberDetail). 복수와 단수 한 글자로 가르면 구조분해 줄에서 안 보임.

## 컴포넌트 안 함수
- on이벤트 는 DOM 이나 자식이 준 이벤트를 그 자리에서 받을 때만 씀(onSubmit, onClick). 폼을 여는 함수를 onCreate 라 부르면 생성이 일어난 것처럼 읽힘.
- 그 밖의 액션은 하는 일의 동사로 시작함. 관례 동사: open(오버레이를 엶), confirm(확인 모달을 거쳐 실행), goTo(이동), check(상태 검사), format(표시용 가공), validate(검증). 목록에 없는 일은 그 일의 동사를 씀.

## 모달 파일 이름은 하는 일을 적음
| 이름 | 하는 일 |
|---|---|
| `XDetailModal` | 보여줌(읽기) |
| `XFormModal` | 받음, 생성과 수정 겸용 |
| `XCreateModal` | 받음, 생성만 |
| `XEditModal` | 받음, 수정만 |
| `X동작Modal` | 받음, 생성과 수정이 아닌 동작 하나(MemberPasswordResetModal) |

- Config 처럼 다루는 대상으로 짓지 않음. Detail, Create, Edit 가 모두 행위인데 하나만 명사라 축이 어긋나고, 같은 규칙을 다른 대상에 쓰면 무너짐.
- 대상이 하나뿐이라 겹칠 일이 없으면 접미사가 없어도 됨(AppConfirmModal).
- 같은 행위를 대상의 갈래마다 나누면 갈래를 행위 앞에 붙이고 짝을 맞춤(MemberLocalEditModal, MemberIdpEditModal). 한쪽만 붙이면 붙지 않은 쪽이 둘 다 맡는 줄로 읽힘.
- 모달을 여는 함수와 핸들 이름은 모달 파일 이름을 따름(MemberCreateModal 을 createModal 로 받아 openCreate() 로 엶).
