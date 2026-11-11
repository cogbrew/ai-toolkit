# 조용히 깨지는 Django 와 DRF 코드

없어도 될 것처럼 보이지만 없애면 조용히 깨지는 것들. 에러가 나면 여기 적을 이유가 없음. 조용히 깨진다는 점이 기준임.

## 모델과 쿼리
- 빈 order_by() 를 지우지 않음. Meta.ordering 이 있는 모델에서 집계 앞의 빈 order_by() 를 지우면 정렬 필드가 GROUP BY 에 들어가 집계가 쪼개짐. 분류별 건수를 세는데 날짜 칸까지 묶여 모든 건수가 1 이 되는 식. 전건 스캔에서 지우면 쓰지도 않는 정렬이 붙음.
- update_or_create 는 변경 여부를 보지 않음. 바뀐 것이 없어도 SELECT 와 UPDATE 가 나감. 야간 배치처럼 반복해서 도는 곳에서는 무변경 재실행의 쓰기가 0 이어야 하므로, 기존 값을 읽어 비교하고 차이가 없으면 save() 를 건너뜀. 쿼리 수를 테스트로 고정함.
- 목록을 돌며 연관 객체를 읽는 코드는 select_related 와 prefetch_related 로 쿼리 수를 고정함. 막는 실수: 건수만큼 쿼리가 나가는 N+1.
- QuerySet.update() 와 bulk_update() 는 save() 도 시그널도 부르지 않고, auto_now 칸도 갱신하지 않음. 그 일이 필요하면 직접 함.
- MySQL 은 조건부 유니크를 지원하지 않음. UniqueConstraint(condition=...) 를 Django 가 조용히 건너뛰고, SQLite 는 지원해서 테스트가 거짓으로 통과함. 테스트는 운영과 같은 DB 로 돌림.
- 비밀번호를 시리얼라이저 CharField 로 받지 않음. DRF CharField 는 trim_whitespace 가 기본이라 앞뒤 공백을 오류 없이 잘라 냄. 로그인(authenticate)은 받은 그대로 확인하므로 공백이 든 비밀번호는 로그인은 되는데 시리얼라이저를 거친 확인에서만 틀림. 비밀번호 하나를 받는 동작은 request.data.get("password") 로 그 자리에서 받음.

## 시그널
- pre_delete 는 모델을 지정해서 검. sender 없이 receiver 를 걸면 모든 모델에 리스너가 생겨서 Django 가 관련 행을 읽지 않고 지우는 빠른 일괄 삭제를 못 씀. 연결된 테이블마다 SELECT 가 붙음. 여러 모델에 같은 것을 걸어야 하면 앱의 ready() 에서 모델마다 connect(sender=...) 하고 dispatch_uid 를 함께 줌. ready() 가 두 번 불릴 수 있기 때문.
- 새 행이 생길 때마다 해야 하는 일은 post_save(created=True) 한 곳에 둠. 만드는 통로가 여럿이어도 모두 save() 를 지나므로 통로마다 붙이면 하나를 빠뜨림. bulk_create 는 save() 도 post_save 도 부르지 않으므로 벌크로 만드는 곳에서는 그 일을 직접 함.

## 트랜잭션과 스레드
- 배치 루프는 건별 savepoint 로 감쌈. 없으면 한 건의 데이터 문제가 전체를 롤백함.

```python
for item in items:
    with transaction.atomic():   # 한 건이 터져도 나머지는 반영됨
        ...
```

- 예외: 쓰기 전에 걸러낼 것을 모두 걸러서 쓰는 중에 실패할 건이 없으면 회차 전체를 한 트랜잭션으로 묶음. 그때 쓰는 중의 예외는 데이터가 아니라 코드나 DB 의 문제이므로 반쯤 반영된 채 남기지 않고 통째로 되돌림.
- 트랜잭션 안에서 부른 외부 호출이나 알림은 transaction.on_commit 으로 미룸. 막는 실수: 롤백됐는데 이미 나간 알림.
- 스레드는 ORM 을 만지지 않음. ThreadPoolExecutor 안에서 쿼리를 날리면 스레드마다 커넥션이 열리고 닫힘. 외부 호출만 스레드에서 하고 DB 쓰기는 본 스레드가 모아서 함.

## DRF 와 미들웨어
- DRF 라우터에서 빈 prefix 는 반드시 마지막에 등록함. 빈 prefix 의 상세는 pk 이고 기본 lookup 은 슬래시와 점을 뺀 아무 글자라서, 다른 prefix 도 pk 로 잡힘. 바꾸면 404 도 500 도 아니고 조용히 다른 뷰로 감. path() 를 include(router.urls) 위에 두는 것도 같은 이유임.
- 미들웨어는 할 일이 없으면 먼저 빠져나옴. request.user.is_authenticated 를 첫 줄에 두면 AuthenticationMiddleware 의 지연 평가가 모든 요청에서 깨져서 인증이 필요 없는 요청에도 세션 조회와 User SELECT 가 붙음.

## 설정
- 프록시 뒤에서는 SECURE_PROXY_SSL_HEADER 를 설정함. 프록시가 TLS 를 끝내고 앱에 http 로 넘기면 request.is_secure() 가 항상 False 라서 모든 POST 가 CSRF 403 이 됨. 프록시 쪽에도 X-Forwarded-Proto 헤더 전달이 있어야 함.
- USE_TZ = True 를 끄지 않음. TIME_ZONE 과 대체 관계가 아님. 껐다가 다시 켜려면 쌓인 데이터를 전부 UTC 로 옮겨야 함.

## 마이그레이션
- 이미 적용된 마이그레이션 파일은 고치지 않음. 바꿀 것은 새 마이그레이션으로 만듦. 막는 실수: 환경마다 스키마가 어긋나는 일.
- 운영 DB 의 행은 지킴. 모델을 바꾸면 옛 행을 새 모양에 맞추는 옮김을 같은 안건에 올리고, 행이나 기록을 지우는 마이그레이션은 돌리기 전에 물음.
- 작업을 마칠 때 makemigrations 의 check 와 dry-run 옵션으로 누락된 마이그레이션이 없는지 확인함.

## 방어 코드
- 계약이 보장하는 값에 방어 코드를 쓰지 않음. 없을 수 없는 값에 if not x: return 을 붙이면 조건이 실제로 발생했을 때 데이터를 조용히 버리고, 읽는 사람에게 이 필드는 없을 수도 있다는 잘못된 인상을 줌. 계약이 깨지면 터지는 편이 나음.
- 버리지 않을 때도 조용히 넘기지 않고 경고와 식별자를 함께 남김.
