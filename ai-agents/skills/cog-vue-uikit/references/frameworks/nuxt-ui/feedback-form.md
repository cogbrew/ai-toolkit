# 토스트, 모달, 폼 (@nuxt/ui)

`../../common.md` 의 알림과 모달과 폼 원칙을 @nuxt/ui(useToast, UAlert, useOverlay, UModal, UForm)로 구현하는 규칙.

## 토스트 래퍼
- useToast() 를 직접 부르지 않고 래퍼(예시: useResultToast)만 씀. 색과 아이콘과 제목 만드는 법이 한 곳에만 있어야 함.
```ts
const { toastError, toastSuccess, toastWarning } = useResultToast();
toastError('삭제하지 못했습니다.', errors);
toastSuccess('4건을 삭제했습니다.');
toastWarning('3건을 처리했습니다.', '1건은 실패했습니다.');
```

| 함수 | 색 | 아이콘 | 제목 | 설명 |
|---|---|---|---|---|
| toastError | error | i-ph-warning-circle | 호출부가 줌 | errors.message(화면이 지어내지 않음) |
| toastSuccess | success | i-ph-check-circle | 호출부가 줌 | 호출부가 줌(선택) |
| toastWarning | warning | i-ph-warning | 호출부가 줌 | 호출부가 줌(선택) |

- 아이콘 이름은 프로젝트가 표준으로 잡은 한 컬렉션을 따름(cog-vue 스타일 규칙).
- 토스트 설명, 확인 모달의 실패 사유, 로그인 화면의 UAlert 세 자리가 errors.message 를 그대로 읽음.

## useOverlay 와 destroyOnClose
```ts
const modal = useOverlay().create(SomeModal);   // setup 에서 한 번 만들어 계속 씀
```
- 재사용하는 모달에 destroyOnClose 를 붙이지 않음. 붙이면 두 번째 open() 부터 `Error: Overlay not found` 가 나며 모달이 아예 안 열림. 닫히는 순간 unmount 가 그 항목을 overlays 배열에서 splice 하는데 핸들이 쥔 id 는 그대로라 다음 open() 의 getOverlay(id) 가 못 찾음.
- 상태는 이 옵션 없이도 남지 않음. unmount 는 destroyOnClose 와 무관하게 isMounted 를 false 로 하고 OverlayProvider 는 isMounted 인 것만 그림. 폼 값과 loading 과 onMounted 가 모두 초기화됨.
- 붙여도 되는 자리는 부를 때마다 create() 를 새로 하는 일회용 하나뿐이며 이때는 지워져야 배열이 안 쌓임.
- UModal 의 `#footer="{ close }"` 슬롯 인자는 값을 못 실음. Reka 의 dialog close 라 open 을 내릴 뿐이고 result 는 undefined 가 됨. 결과를 돌려주려면 `emit('close', value)` 로 함. 부모는 `await modal.open().result` 로 받음.

## 확인 모달 호출
```ts
confirmModal.open({
    title: '확인 메시지',
    description: '무엇이 사라지는지',
    errorTitle: '삭제하지 못했습니다.',
    color: 'error',
    confirmLabel: '삭제',
    onConfirm: () => deleteSelected(targets),
});
async function deleteSelected(targets) {
    const { errors } = await deleteMembers(targets.map(row => row.id));
    if (errors) { return errors.message; }   // 문자열이면 모달을 열어 두고 사유를 설명 자리에 보임
    toastSuccess(`${targets.length}건을 삭제했습니다.`);
    clearSelection();
    refresh();
}
```
- 확인, 진행(스피너와 진행 제목), 실패(경고 아이콘과 오류 제목과 사유) 세 상태는 본문을 통째로 갈아끼움. 덧붙이면 실행하시겠습니까와 실패했습니다가 한 화면에 남음.
- 설명의 줄바꿈은 모달이 whitespace-pre-line 을 걸어 두어 description 의 줄바꿈이 그대로 먹음.
- 입력을 받는 확인의 묶음은 가운데 정렬(pt-4 text-center)에 아이콘(size-12 mb-4), 제목(text-highlighted text-base font-semibold), 설명(text-muted mt-2 text-sm)임. 묻는 창은 i-ph-info 와 text-primary, 결과를 알리는 창은 성공 토스트와 같은 i-ph-check-circle 과 text-success, 부분 성공은 i-ph-warning 과 text-warning, 실패는 i-ph-warning-circle 과 text-error 임.
- 오래 걸리는 제출은 `:close="!form?.loading"` 과 `:dismissible="!form?.loading"` 로 도는 동안 닫히지 않게 함.

## 모달 푸터 버튼
- 오른쪽 끝에 모음(`flex w-full justify-end gap-2`). 보조 버튼은 `color="neutral" variant="outline"`, 제출과 주 동작은 색을 주지 않음(기본색). 삭제는 왼쪽 끝에 `color="error" variant="outline" mr-auto`.

## UForm
```vue
<UForm id="x-form" ref="form" :schema="X_FORM_SCHEMA" :state="state" @submit="onSave">
    <UFormField name="name" label="이름" required>
        <UInput v-model="state.name" class="w-full" />
    </UFormField>
</UForm>
<UButton type="submit" form="x-form" label="저장" :loading="form?.loading" />
```
- UFormField 의 name 이 스키마 키와 같아야 에러가 그 필드에 붙음. 빠뜨리면 검증은 도는데 화면에 아무 말도 안 나옴. 스키마는 앱의 definitions 에 둠(cog-vue).
- 저장 로딩은 UForm 이 이미 들고 있음(loadingAuto 기본 true). 제출 중에 폼 안 입력칸이 전부 disabled 가 되고 finally 로 내려 핸들러가 던져도 스피너가 안 남음. 버튼이 폼 밖(모달 푸터)이면 inject 가 안 닿으므로 `useTemplateRef('form')` 로 읽음.
- .d.ts 에는 loading 이 Ref 로 적혀 있지만 Vue 가 exposed 를 proxyRefs 로 감싸 템플릿에서는 boolean 으로 풀림. 템플릿에서 .value 를 붙이지 않음.
- 서버 에러는 `form.value?.setErrors(toFormErrors(errors.fieldErrors))` 로 넣고, 다시 제출할 때 `form.value?.clear()` 로 지난 에러를 지움(clearErrors 가 아님). 없는 name 을 주면 조용히 사라짐.
- 입력칸이 없는 저장 화면(사람을 고르는 모달, 체크박스 권한 표)은 스키마 없이 id, ref, @submit 만 주고 UForm 으로 감쌈.

### 에러 prop
| 넘긴 값 | 동작 |
|---|---|
| undefined | 내장 검증 메시지가 정상 표시됨 |
| true | 에러 스타일(빨간 테두리)만, 메시지 없음 |
| false | 에러 없음으로 처리되어 내장 검증까지 차단됨 |
| 문자열 | 그 문자열이 에러 메시지가 됨 |

- 빈 문자열도 에러 있음으로 읽혀 아무것도 안 했는데 테두리가 빨개짐. null 이 올 수 있는 값은 `serverError ? true : undefined` 로 씀.

### 못 바꾸는 칸
- disabled 를 주고 variant 를 같이 줌. 기본 outline 은 배경이 bg-default 라 잠가도 opacity 말고는 옆 칸과 차이가 없음.

| variant | 배경 | 테두리 |
|---|---|---|
| outline(기본) | bg-default | ring |
| subtle | bg-elevated | ring |
| soft | bg-elevated/50 | 없음 |
| ghost, none | 투명 | 없음 |

- subtle 이면 테두리는 그대로 두고 배경만 채워져 같은 칸이 잠긴 것으로 읽힘.
- readonly 로는 안 됨. UInput 이 $attrs 를 네이티브 input 에 넘겨 동작은 하지만 테마에 read-only: 변형이 없어 편집 가능한 칸과 똑같이 보임.
- UFormField 에는 disabled 가 없음. 내려오는 경로는 UForm(폼 전체)이나 입력 컴포넌트 자신뿐이므로 칸 하나만 잠그려면 UInput 에 줌. 스키마에 없는 칸이면 UFormField 에 name 도 required 도 주지 않음.

## 가져오기 상태 슬롯
- AppFetchState 의 슬롯은 이름 없는 default 임(슬롯이 하나뿐이고 본문이라 붙일 이름이 없음). 나중에 이름을 준다면 #body 만은 피함(바로 바깥이 UModal 의 #body 임).
- 목록 조회와 갱신 중인 화면은 스피너로 화면을 지우지 않음(이미 내용이 있으면 갱신 중에 지우면 안 됨).
