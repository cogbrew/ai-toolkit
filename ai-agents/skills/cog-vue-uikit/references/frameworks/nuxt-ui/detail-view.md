# 읽기 전용 상세 (@nuxt/ui)

`../../common.md` 의 읽기 전용 상세 원칙을 구현하는 규칙. px 값은 예시 프로젝트에서 잰 것이므로 화면마다 다시 잼.

## 섹션과 칸
```vue
<AppDetailSection title="기본 정보" size="sm">
    <dl class="grid grid-cols-2 gap-x-4 gap-y-4 lg:grid-cols-4">
        <AppDetailItem :label="LABELS.company" :value="detail.company" />
        <AppDetailItem class="col-span-2" :label="LABELS.account" :value="detail.account" />
    </dl>
</AppDetailSection>
```

| 부품 | 맡는 것 |
|---|---|
| AppDetailSection | 제목(h4), 구분선(USeparator mt-2 mb-4), 내용을 px-4 로 들임. 제목 크기는 그릇에 따라 size(기본 base, 모달 안은 sm). 제목 줄 오른쪽에 둘 것은 #actions 슬롯 |
| AppDetailItem | dt(text-xs text-muted)와 dd(text-sm wrap-break-word). 값이 비면 -(text-dimmed). 배열이면 한 줄에 하나씩(긴 경로만 배열, 사람 이름 목록은 join 으로 이어 넘김). 글자가 아닌 모양은 기본 슬롯. class 는 바깥 div 로 넘어가 col-span-2 를 여기에 줌. changed 를 켜면 라벨 옆에 변경 뱃지 |

- dl 과 열 수는 쓰는 쪽이 씀. 화면마다 폭이 달라 재서 정해야 하기 때문임. 칸은 템플릿에 하나씩 적음.
- 이름은 Item 이고 Field 가 아님(입력 칸 UFormField 와 헷갈리지 않게 함).
- AppDetailSection 의 size 는 제목 글자만 바꾸는 이 부품의 prop 이며 Nuxt UI 의 size 프리셋(글자와 아이콘을 함께 바꿈)과 이름만 같음.

## 열 수를 재는 법
- 캔버스로 값 폭을 재고(measureText) 창 크기별 본문 폭을 재서 `(본문 - gap×(N-1)) / N` 이 그 폭 이상인 N 을 고름.
- 내용이 찬 상태로 잼. 빈 패널에는 세로 스크롤바가 없어 폭이 15px 더 나옴.
- 꺾였는지는 dd 높이를 line-height 로 나눈 줄 수로 봄.
- USplitter 에 id 를 주면 reka-ui 가 레이아웃을 localStorage 에 퍼센트로 저장함. sizeUnit 을 바꿔도 이미 연 브라우저는 저장된 값이 이기므로 재기 전에 지움.
- 크롬은 창을 500px 아래로 줄이지 못함. 그보다 좁은 폭은 잰 값이 아니므로 잰 것처럼 적지 않음.

## 분할 화면의 본문 최소 폭
- 좌우 분할(USplitter)의 오른쪽 패널은 창을 따라 줄어듦. 줄 안에 폭이 고정된 것(뱃지, 버튼)이 있거나 키 칸이 비율이면 일정 폭 아래에서 이름이 먼저 사라지고 버튼이 삐져나옴.
- 본문 전체(예: `<div v-if="detail">`, UForm)에 min-w-* 를 걸어 그보다 좁으면 패널 안에서 가로 스크롤이 되게 함. 왼쪽 목록과 패널 제목과 푸터 버튼은 스크롤 밖임.
- 본문 전체에 걸어야 옆으로 스크롤할 때 위의 섹션 제목과 구분선이 패널 폭에서 끊기지 않음.
- 안쪽 그리드는 창 폭(md:)이 아니라 @container 로 접음. 창 폭 기준이면 본문을 넓혀도 창이 좁은 한 1열임.
- 최소 폭은 그 폭에서 원하는 배치가 서도록 잼. AppDetailSection 이 px-4 로 들이므로 그리드가 보는 폭은 본문에서 32px 뺀 값임.

## 상세 모달
- 모달 폭은 창 폭을 따라가지 않음(sm:max-w-lg 이면 640px 이상에서 512px 고정). md:, lg: 열 수만 붙여서는 모달 안이 바뀌지 않으므로 모달 폭도 같은 기준으로 넓힘.
```vue
<UModal :ui="{ content: 'sm:max-w-lg lg:max-w-3xl' }">
<dl class="grid grid-cols-2 gap-x-4 gap-y-4 lg:grid-cols-4">
```
- 섹션끼리 같은 열 수를 써서 세로 줄이 맞게 함. 칸이 셋뿐인 섹션은 좁을 때 3열로 둠(2열이면 한 칸이 혼자 남고 섹션 제목과 구분선이 어긋남을 덜 보이게 함).
- 수정 모달과 폭이 달라도 됨. 헷갈리지 않게 하는 것은 칸 순서임.

## 건수 타일
```
타일   bg-elevated, rounded-md, p-3, text-center
라벨   text-xs, text-toned
숫자   text-base, font-semibold, 0 이면 text-toned
전체   total 을 주면 숫자 뒤에 「/ n」, text-sm, font-normal, text-toned
```
- 전역 타일 부품 하나(AppDetailTile: label, count, 선택 total)로 그리고 dl 안에 둠. 요약과 홈 카드가 같은 타일을 씀.
- 라벨과 0 이 text-toned 인 까닭은 bg-elevated 위의 text-muted 는 라이트 모드 대비가 모자라기 때문임(cog-vue 스타일 규칙).
- 숫자에 색을 입히지 않음. text-base 와 600 은 WCAG 큰 글자 기준(18.66px, 700)에 못 미쳐 4.5:1 을 받아야 함. 배경만 물들이면 그 요건이 안 걸리지만 그래도 한 칸만 다르게 두지 않음.
- 타일에는 최소 폭이 있음(패딩 더하기 가장 긴 라벨이나 숫자, 네 자리면 68px). 그 아래 폭에서는 열을 접고 묶음마다 @container 를 둬 창이 아니라 묶음 폭을 봄.

## 표 한 칸의 여러 항목
```
라벨   UBadge neutral, soft, w-28, justify-center, 기본 size(text-xs)
값     일반 텍스트. 표의 다른 열과 같은 크기(text-sm)
```
- 폭을 고정하는 이유는 값의 시작을 맞추기 위함임. 안 맞추면 값이 줄마다 흔들려 눈이 가로로 다시 훑음. 폭은 가장 긴 라벨을 재서 정함.
- 라벨만 한 단계 작게 둠(값이 읽을 것이고 라벨은 무슨 칸인가만 말함).
- 값에 색을 입히지 않음. 전후를 주황과 파랑 뱃지로 칠하면 글자 대비가 AA 에 못 미치고(예시: text-warning 1.91, text-info 3.76, text-error 3.81), 배경만 칠하면 내용보다 색이 먼저 눈에 옴. 색은 이미 임자가 있음(색의 뜻).

## 전후 값
```vue
<p class="text-muted wrap-break-word whitespace-pre-line">{{ before }}</p>
<p class="text-default pl-4 -indent-4 wrap-break-word whitespace-pre-line">→ {{ after }}</p>
```
- 이전은 text-muted 로 물리고 남는 값이 이후임.
- whitespace-pre-line 이 있어야 줄바꿈으로 이어 붙인 값이 줄로 나뉨. 없으면 공백으로 접혀 한 줄로 보임.
- pl-4 와 -indent-4 로 내어씀. 화살표는 첫 줄에만 붙어서 없으면 둘째 줄이 왼쪽으로 튀어나옴. pl-4(1rem)는 화살표와 공백이 진행하는 폭을 재서 나온 값임.
- 이전 줄에는 들여쓰기를 주지 않음.
