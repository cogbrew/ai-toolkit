# accounts 와 core 기본 구성

## 전제
- accounts 와 core 는 다른 프로젝트가 기반으로 가져다 씀. 특정 기능의 로직을 두지 않음.
- 판별 물음은 템플릿처럼 다른 프로젝트가 그대로 가져가도 되는가 하나.
- 막는 실수: 한 프로젝트의 기능 로직이 기반 계층에 섞여서 다른 프로젝트가 기반을 가져다 쓸 수 없게 되는 일.

## accounts
- 계정 도메인임. User 와 짝 모델(연락처, 부서, 사용자 설정, API 토큰, 사용자 이력 등)을 둠.
- constants.py 에는 여러 앱의 모델이 한 벌을 함께 쓰는 값(기록 모델의 SOURCE_CHOICES, ACTION_CHOICES 등)을 둠. 앱끼리는 서로 임포트할 수 없고 모두 accounts 는 읽기 때문. 모델마다 리스트를 다시 적으면 한 벌이 여러 벌로 갈라짐.
- services.py 에는 사용자 이력을 쓰는 공용 함수처럼 계정 도메인의 공용 로직을 둠.
- User 는 어디서든 accounts.models 에서 직접 임포트함. get_user_model(), settings.AUTH_USER_MODEL, 문자열 accounts.User 를 쓰지 않음.
  - 이유: 프로젝트 코드는 User 의 칸(account, is_idp 등)에 기대고 짝 모델도 같은 앱에서 직접 가져옴. 간접 참조를 쓰면 한 앱의 모델을 두 방식으로 가져오게 되고, 직접 임포트하면 편집기가 칸을 따라감.
  - 예외: User 를 정의하는 accounts/models.py 하나, 아직 정의되지 않은 모델이나 서로 임포트가 될 다른 앱을 가리킬 때의 문자열, 설정의 AUTH_USER_MODEL 과 마이그레이션의 settings.AUTH_USER_MODEL(Django 가 늘 이렇게 적음)

## core
- 권한 모델과 도구(Role, Menu, Feature, 권한 행, permissions.py), 여러 앱이 함께 쓰는 서비스(core/services), constants.py, signals.py, admin.py, 관리 커맨드를 둠.
- 관리 커맨드는 core/management/commands/ 한 곳에 둠. 기본 데이터를 심는 init_app_data 같은 커맨드도 여기에 둠.
- services 의 자리는 누구의 것이냐로 정함. 로그인한 사람이 실제로 받는 권한 계산처럼 여러 앱과 다른 프로젝트가 쓰면 core/services 에 두고, 역할 관리 화면의 권한 표 만들기처럼 한 기능의 것이면 그 앱의 services.py 에 둠. DB 를 만지니까 services 라는 이유만으로 core 에 두면 core 에 특정 기능의 로직이 들어감.
- 서비스의 자리는 다루는 데이터가 정함. 누가 부르는지는 따지지 않음. user 를 인자로 받아도 Menu 와 MenuPerm 만 읽으면 그 코드는 필터 조건에 해당함. User 를 임포트하지 않는 것이 증거임. 예외는 흐름을 잇는 코드이며, 로그인 배선처럼 두 도메인을 함께 건드리지만 어느 쪽 것도 아닌 코드는 그 흐름이 사는 곳에 둠.

## choices
- choices 는 모델 안에 칸이름_CHOICES 리스트로 둠. 별도 파일(choices.py)로 빼지 않음. 빼는 순간 이름을 어떻게 지을지가 매번 판단거리로 남음. 예외는 위의 accounts/constants.py.
- TextChoices 를 쓰지 않음. 얻는 것이 값을 이름으로 부르는 것 하나인데, 쓰는 사람이 그렇게 적어야만 값을 하기 때문.
- choices 는 DB 제약이 아님. save() 는 검사하지 않고 full_clean() 을 부를 때만 걸림. 어드민 폼과 DRF 시리얼라이저는 막지만 내부 코드가 넣는 값은 아무도 보지 않음. 진짜로 막아야 하는 칸에는 CheckConstraint 를 검.
- 칸 이름은 개념마다 하나로 짓고, 라벨은 그 모델의 말로 지음. 기록의 일시는 어느 모델이든 created_at 이지만 라벨은 배포 일시, 시작 일시처럼 무엇의 일시인지 드러냄.

## 테스트 날짜
- 경계는 상대 날짜로 씀. 예: localdate() - timedelta(days=1). 쟁점이 아닌 픽스처 날짜는 넉넉히 미래로 둠. 막는 실수: 시간이 지나면 깨지는 테스트.
