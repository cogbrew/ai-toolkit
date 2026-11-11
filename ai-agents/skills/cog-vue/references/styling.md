# 스타일과 Nuxt UI

Nuxt UI v4 와 Tailwind v4 기준. 어느 역할에 어느 값을 쓰는지(표, 상세, 페이지 헤더)는 이 스킬 범위 밖이고, 여기는 값의 스케일과 토큰만 다룸. 예시 값의 일부(예: 선택 배경이 bg-elevated)는 예시 프로젝트의 테마에서 확인한 것이며 테마를 바꾼 프로젝트에서는 다시 확인함.

## Nuxt UI 를 Vue + Vite 에서 쓸 때
- 공식 문서와 레퍼런스는 Nuxt 기준임. NuxtPage 는 RouterView 로, NuxtLayout 은 라우트 component 로 레이아웃을 분기, 파일 기반 라우팅은 router/routes.ts 로 대응함.
- 레이아웃 트랙은 둘이며 혼용하지 않음. Page 트랙(UHeader, UMain, UFooter)은 랜딩과 문서용이고, Dashboard 트랙(UDashboardGroup, UDashboardPanel)은 SPA 용임. UDashboardGroup 은 fixed inset-0 으로 뷰포트를 점유함. 전형적인 위반은 UDashboardPanel 의 헤더에 UHeader 를 넣는 것이며 UDashboardNavbar 를 씀(사이드바가 없으면 `:toggle="false"`).
- @nuxt/ui/vite 는 src/components 만 자동 등록함. 앱 안의 컴포넌트는 임포트하지 않으면 에러 없이 안 그려짐. 전역 컴포넌트도 자동 등록에 기대지 않고 임포트함. 임포트 줄이 없으면 이 화면이 무엇에 기대는지 위쪽만 읽어서는 안 보임. 임포트하지 않는 것은 Nuxt UI 가 주는 컴포넌트와 컴포저블(UButton, useOverlay, useToast)뿐임.
- UColorModeButton 은 쓸 수 있음. @vueuse/core 가 Vue 빌드의 실질 필수 의존성임(확인한 @nuxt/ui 4.11 기준).
- 서버에 저장하는 테마는 두 방향으로 묶음. 서버에서 화면으로는 watch(theme, ..., { immediate: true }) 로 colorMode.value 에 넣고, 화면에서 서버로는 해석된 값이 아니라 colorMode.store(원본)를 감시하며 auto 를 건너뜀. 막는 실수: store 가 auto 로 돌아갈 때 OS 설정이 서버로 밀려 사용자가 고른 테마가 덮어써지는 일. localStorage 는 출처가 아니라 첫 페인트 깜빡임을 막는 캐시이고 서버 값이 이김.
- 트리 데이터는 flat 표로 그림. UTable 의 확장 행은 상세 행 전용이라 트리로 쓰면 펼친 행마다 빈 행이 렌더됨. 행 순서는 서버가 보낸 전위 순회 그대로 두고, 계층은 상위 경로 텍스트 컬럼으로 보여 줌.

## 타이포
- 앱의 기본 글꼴을 상속하고 Tailwind 규격을 따름. text-app-* 같은 임의 클래스를 만들지 않음. 글꼴은 하나이며 JSON 이나 코드처럼 보이는 값에도 font-mono 를 주지 않음(구분이 필요하면 색 토큰이나 배경을 제안하고 먼저 물음).
- 루트는 16px 로 둠. Tailwind 크기는 rem 이라 이름 값이 그대로 픽셀임.

| 클래스 | 크기 | 용도 |
|---|---|---|
| `text-xs` | 12 | 캡션, 인풋 에러, 보조 뱃지, 읽기 전용 상세의 dt |
| `text-sm` | 14 | 컴포넌트와 컨트롤 기본값, 폼 라벨, 데이터 |
| `text-base` | 16 | 페이지 본문, h4 섹션 제목, 카드와 모달 타이틀 |
| `text-lg` | 18 | h3 중형 섹션과 패널 타이틀 |
| `text-xl` | 20 | h2 주요 페이지 타이틀 |
| `text-2xl` | 24 | h1 최상위 타이틀, 라우트당 1개 |

- 제목은 이름이 아니라 담는 그릇의 층으로 고름. 담는 그릇의 제목보다 한 단계 아래를 씀(페이지 text-2xl, 패널 text-lg, 섹션 text-base, 본문과 데이터 text-sm). 제목이 text-base 인 모달 안에서는 섹션이 text-sm 임. 막는 실수: 섹션 제목과 본문이 같은 크기가 되어 굵기로만 갈리는 일.
- 컨트롤이 작다고 size 프리셋을 올리지 않음. size 는 글자와 아이콘을 함께 바꾸고(lg 는 높이만, xl 은 글자와 높이와 아이콘 모두), 크게 하려면 루트 하나를 올림. UInput, USelect, UFormField, UButton 은 호출부가 size 를 넘기지 않음. 막는 실수: 한 컨트롤만 올려 같은 줄의 다른 컨트롤과 높이가 어긋나는 일. 예외는 폼이 하나뿐인 로그인 화면임.
- UInput 의 text-base/5 md:text-sm 은 iOS 가 16px 미만 인풋을 확대하는 것을 막는 의도된 예외이므로 위반으로 오진하지 않음.
- 숫자로 넘기는 값(가상 목록의 itemHeight, USplitter 의 px 크기)은 rem 을 타지 않아 루트를 바꿔도 남으므로 따로 잼.

## 색은 시맨틱 토큰만
- 배경은 bg-default, bg-muted, bg-elevated, bg-accented, bg-inverted. 글자는 text-default, text-highlighted, text-toned, text-muted, text-dimmed, text-inverted. 테두리는 border-default, border-muted, border-accented, border-inverted.
- dark: 변형을 손으로 적지 않음. 위 토큰이 라이트와 다크 CSS 변수로 자동 전환되고 Nuxt UI 내부 컴포넌트와 같은 변수를 공유함.
- text-neutral-500 같은 숫자 스케일은 모드 전환이 되지 않는 고정값이라 앱 셸 안에서 쓰지 않음. 예외는 다크 단일 톤으로 의도적으로 고정한 화면(로그인)임.
- 선택 배경은 bg-elevated 이고 bg-accented 는 눌린 컨트롤 쪽임. bg-elevated 위에는 text-muted 가 아니라 text-toned 를 씀(라이트 모드 대비가 AA 4.5 에 못 미침, 예시 테마에서 계산한 값).
- 한 색은 한 뜻임. 뱃지와 막대와 버튼이 같은 뜻에 같은 색을 씀(켜짐은 success 와 꺼짐은 neutral, 생성과 수정과 삭제는 success 와 warning 과 error 등). primary 는 데이터 값의 표식에 쓰지 않고 강조는 text-highlighted 를 씀. 기본 팔레트에서 primary 가 활성(success)과 같은 초록이라 뜻이 겹치기 때문임.

## 여백과 크기
- 한 단위는 4px 임(--spacing 이 0.25rem). 필요한 px 를 4 로 나눔(144px 는 w-36). 대괄호 임의값(w-[380px], min-h-[300px], p-[20px])을 쓰지 않음. 정수로 안 맞을 때만 .5 단위(pl-4.5 는 18px)를 쓰며 이것은 스케일 안임.
- 없는 클래스는 조용히 0 이 됨. Tailwind v4 는 소스에 쓰인 것만 만들므로 브라우저 콘솔에서 시험한 클래스는 CSS 가 없어 투명하게 나옴. 화면에서 값을 재려면 소스에 넣고 잼.
- v4 에서 이름이 바뀐 유틸리티(break-words 는 wrap-break-word, overflow-ellipsis 는 text-ellipsis, order-none 은 order-0)는 옛 이름도 동작해 화면과 린트에 안 드러남. 목록을 외우지 않고 설치된 버전의 tailwindcss 안 대응표에서 확인함.

## 패널과 카드, 캡슐화
- 화면을 가른 패널(USplitter 의 칸)은 UCard 로 감싸지 않음. 패널은 border 로 테두리를 긋고 자기 레이아웃(flex-col, min-h-0, overflow-hidden)을 갖고, 카드는 ring 으로 그리는 떠 있는 상자임. 막는 실수: ring 은 box-shadow 라 박스 바깥에 그려져 칸의 overflow hidden 에 좌우 1px 이 잘리는 일.
- 바깥 여백을 컴포넌트 안에 하드코딩하지 않고 컴포넌트 간 간격은 부모가 flex gap-* 로 통제함. 자기 레이아웃은 자기가 가지며 부모가 크기를 주려고 div 로 한 번 더 감싸지 않음(자식 루트가 w-16 shrink-0 sm:w-56 을 가짐). 크기가 가변이어야 하는 범용 컴포넌트만 부모에게서 상속받음.

## CSS
- SFC 의 style scoped 에서 @apply 와 @reference 를 쓰지 않음. 컴포넌트마다 @reference 상대 경로가 강제되고 에디터가 Unknown at rule 을 띄움. 표준 CSS 로 쓰고 테마 변수(var(--ui-primary), var(--spacing))를 씀.
- truncate 는 부모 min-w-0 과 대상 w-full 이 있어야 동작함.
- scoped CSS 의 :global(html.dark) 는 컴파일되지 않음. 다크 변형이 필요하면 `:class="{ dark: isDark }"` 로 바인딩하고 그 클래스에 규칙을 검.

## 아이콘
- 동적으로 굵기를 바꾸려면 1대1 매핑이 보장되는 한 컬렉션을 표준으로 잡음. 예시는 Phosphor(i-ph-*)임. 다른 팩에는 -light 같은 꼬리표 이름이 없어 런타임에 아이콘이 조용히 안 그려짐. 컬렉션은 프로젝트마다 하나로 고정하고 바꾸려면 사용자에게 물음.
- @nuxt/ui 가 기본으로 그리는 아이콘(셀렉트 화살표 등)은 건드리지 않음.
- 굵기는 그 자리에서 꼬리표를 붙임(`:icon="isActive ? icon : `${icon}-light`"`). 이것을 함수로 감싸지 않음.
- DB, JSON, 라우트 메타에 저장하는 아이콘 이름에는 꼬리표를 붙이지 않음(i-ph-briefcase). 꼬리표를 떼는 코드가 없어 붙어 들어오면 없는 이름이 됨. 저장하는 서버 쪽과의 약속이기도 함.
