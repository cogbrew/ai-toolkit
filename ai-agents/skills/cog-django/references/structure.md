# 디렉토리 구조와 구성

## 최상위 구성
| 위치 | 담는 것 |
|---|---|
| manage.py, pyproject.toml, requirements.txt | 진입 파일, 도구 설정, 패키지 목록 |
| .env, .env.example | 환경변수(.env 는 커밋하지 않음), 값 없는 틀(커밋함) |
| config/ | settings, urls, 진입 파일(wsgi, asgi), 로깅, 미들웨어, 메일, 인증 |
| accounts/ | 계정 도메인(User 와 짝 모델). 특정 기능의 로직을 두지 않음 |
| core/ | 권한과 여러 앱이 함께 쓰는 서비스, 관리 커맨드, 시그널 |
| apps/ | 화면 하나에 대응하는 API |
| modules/ | 다른 서비스와 연계하는 코드 |
| extensions/ | 프레임워크 확장(DRF 공용 부품, 모델 필드 확장) |
| utils/ | Django 를 임포트하지 않는 순수 함수 |
| logs/, media/, static/, staticfiles/ | 실행 중 생기는 폴더. 커밋하지 않음 |
| templates/ | 템플릿(프론트 진입 페이지 등) |

- 의존 방향은 앱에서 기반 계층(accounts, core, utils, extensions)으로만 허용. 앱에서 앱은 허용하지 않음.
- 앱 사이 참조가 정말 필요하면 금지하지 않고 세어서 관리함. 새 예외를 만들기 전에 묻고, 목록이 길어지면 앱 경계를 다시 봄. 막는 실수: 무분별한 참조로 설계가 무너지는 일.

## apps 구성
- 앱 폴더는 화면(메뉴) 모양을 따름. 2단 화면은 apps/분류/화면/, 분류 없는 1단 화면은 apps/화면/ 한 단.
- 1단 화면에 한 단을 더 만들지 않음. apps/org/department/ 처럼 두면 폴더가 메뉴에 없는 2단을 말하게 됨. 폴더 이름은 다루는 데이터로 짓고, API 주소도 같은 모양으로 맞춤.
- 앱 하나의 구성은 아래와 같음.

```
apps/분류/화면/
  apps.py
  app_v1/ (serializers.py, views.py, urls.py)   화면이 쓰는 API
  api_v1/                                        외부 시스템용 API
  models.py, admin.py                            그 화면이 가진 모델(있을 때)
  options.py                                     화면이 쓰는 선택지
  errors.py                                      모듈 오류를 API 오류로 바꿈(app_v1 과 api_v1 이 함께 쓸 때)
  services.py                                    그 앱만 쓰는 DB 로직
  tests.py
```

- options.py 와 errors.py 는 app_v1 밖에 둠. api_v1 도 같은 선택지와 오류 변환을 쓰기 때문이며, 안에 두면 다른 버전이 남의 내부를 임포트하게 됨. 뷰 파일에는 뷰만 둠.
- services.py 와 core/services 가 갈리는 기준은 누구의 것이냐(core.md).

## modules 구성
- 기준은 다른 서비스와 연계하는지 하나.
- Django 를 아느냐로 가르지 않음. 저쪽 API 를 호출하는 연동 모듈은 Django 를 임포트하지 않는 계약으로 둠. 벤더 라이브러리를 django.setup 없이 손으로 돌려 보기 위한 것. 받아서 우리 DB 를 맞추거나 결과를 DB 에 적는 모듈은 Django 를 앎.
- 모듈의 설정은 누가 읽느냐로 둠. Django 가 읽는 설정(메일의 MAILERS 등)은 config/이름/ 에 두고, Django 가 모르는 바깥 서비스의 설정(봇 토큰, 원본 주소)은 modules/이름/config/ 에 둠.
- 모듈이 쓰는 문구 템플릿은 그 모듈의 templates/ 에 두고 Django 템플릿에 붙이지 않음. 그 서비스에만 쓰는 문구이기 때문.
- modules/ 바로 아래에 공용 파일을 새로 두지 않음. 모듈들이 함께 쓸 코드의 자리는 전역(core/services), 묶음 디렉토리(modules/묶음/), 각 모듈에 그대로 두기 중에서 고름.

## utils 와 extensions
- utils 의 자격은 모델을 몰라도 되는가 하나. 값만 받아 값을 돌려주면 utils/용도.py 에 두고, 모델이나 쿼리셋이나 설정을 알아야 하면 그 앱 안에 둠.
- 도메인과 관련 있는가가 아니라 도메인을 임포트해야 하는가로 가름. 계정 정책을 담은 함수라도 문자열을 받아 문자열을 돌려주면 utils 임.
- utils 는 Django 를 임포트하지 않음. 예외는 모델 필드 검증기를 모은 validators.py 하나. DRF 시리얼라이저 검증기는 extensions/rest_framework/validators.py 에 둠.
- 값 해석 함수(parse_bool, parse_list)는 utils/parsers.py 한 곳에 둠. 둘 이상이 쓸 때 올린다는 기준은 cog-code-writer 를 따름.
- extensions 는 프레임워크 확장. DRF 공용 부품(BaseRouter, BaseModelViewSet, 페이지네이션, 예외와 오류 응답)과 모델 필드 확장이 들어감.

## 등록해야 하는 곳
- 새 앱은 두 곳에 등록함. INSTALLED_APPS 와 라우팅. 2단 화면은 그 분류의 라우팅에, 새 분류면 상위 라우팅에도, 1단 화면은 상위 라우팅(config/urls)에 바로 붙임. 빠뜨리면 404.
- 모든 관리 커맨드는 한 디렉토리(core/management/commands/)에 만듦. 앱마다 흩어지면 무엇이 있는지 아무도 모름.
- 새 로거는 config/logging 의 LOGGERS 와 핸들러에 등록함. 빠지면 INFO 가 소리 없이 사라지고, assertLogs 가 자기 핸들러를 붙여서 테스트로도 잡히지 않음.
- 로그 파일 이름은 역할_기능(넓은 것부터)으로 지음. 예: deploy_ldap, send_slack, auth_saml. 같은 역할이 나란히 붙음.
- 로그 이벤트 이름은 대상_일어난 일(과거형이나 상태)로 지음. 예: member_created, request_failed. 동사를 앞에 두지 않고 로거 이름과 겹치는 접두어를 붙이지 않음. error 칸은 타입: 문장 꼴로 적어 원인이 그 자리에서 보이게 함.
- 패키지를 설치하면 requirements.txt 에 추가함.

## 도구 설정
- 도구 설정은 pyproject.toml 한 곳에 두고 .editorconfig 를 함께 둠. ruff 기본값은 한 줄 119자, 들여쓰기 4칸이며, migrations, staticfiles, media 는 검사에서 뺌.
- 작업을 마칠 때 돌리는 명령은 테스트, ruff 검사, 서식 확인(고친 파일), 마이그레이션 누락 확인(makemigrations 의 check 와 dry-run 옵션)임.
