# settings 와 환경변수

## settings 분리
- config/settings/ 에 공통 base.py 와 환경별 local.py, dev.py, prod.py 를 둠. 환경별 파일은 base 를 임포트하고 환경 차이만 적음.
  - local: DEBUG, CORS, 디버그 도구(debug_toolbar, django_extensions)
  - dev, prod: ALLOWED_HOSTS, INTERNAL_IPS, SECURE_PROXY_SSL_HEADER, 쿠키 보안(SESSION_COOKIE_SECURE, CSRF_COOKIE_SECURE)
- dev 와 prod 가 거의 같아도 파일은 둘 다 둠. 환경이 갈릴 때 나눌 자리를 미리 만들어 두는 것.
- 사용할 설정 모듈은 DJANGO_SETTINGS_MODULE 환경변수로 정함. .env 에서 지정하고 기본값을 두지 않음. 없으면 manage.py 가 안내와 함께 멈춤. 막는 실수: 의도하지 않은 환경의 설정으로 부팅하는 일.
- base.py 는 주석 구획으로 나누고 순서를 고정함. DJANGO CONFIG, I18N 과 TIMEZONE, DATABASE, LOGGING, APPS(Django 기본, 서드파티, 프로젝트), MIDDLEWARE(Django 기본, 프로젝트), TEMPLATES, AUTH, STATIC, MEDIA, REST FRAMEWORK, CSRF, SESSION, 기능별(EMAIL, SLACK 등). 새 설정은 맞는 구획에 넣음.
- 없으면 만드는 폴더(static, media)는 설정 파일에서 mkdir 로 만듦. 새로 받은 저장소에서 손으로 만들지 않게 하려는 것임. 프론트 빌드 산출물처럼 없을 수 있는 경로는 있을 때만 붙임.
- Django 기본값과 다르게 둔 설정은 저장소 문서에 이유를 적음. 예: DATA_UPLOAD_MAX_NUMBER_FIELDS 를 늘린 이유는 어드민에서 1,000건을 한 번에 지우면 행마다 폼 필드가 붙어 기본값 1,000 에 걸리기 때문.

## .env
- 위치는 프로젝트의 backend 폴더 바로 아래 .env 한 개. 진입 파일(manage.py, wsgi.py, asgi.py)에서 python-dotenv 의 load_dotenv 로 불러옴. settings 에서 불러오지 않음.
- .gitignore 에 .env, .env.\*, !.env.example 세 줄을 둠. 값 없는 틀인 .env.example 은 커밋함. logs, media, static, staticfiles, venv 도 커밋에서 뺌.
- 변수 이름은 DJANGO_ 접두사 + 기능 + 항목으로 지음. 예: DJANGO_DB_HOST, DJANGO_MAIL_PORT, DJANGO_OIDC_CLIENT_ID. 앱 이름이 아니라 기능 이름을 씀.
- 새 변수를 더하면 읽는 코드, 필수 목록(필수일 때), .env.example(이름과 설명, 값 없음)을 한 번에 고침. 막는 실수: 코드는 읽는데 틀에 없어서 새 환경에서 부팅이 실패하는 일.
- 환경변수는 설정 계층에서만 읽음. 읽는 곳은 config/settings, config/기능 이름, modules/이름/config, 진입 파일. apps, accounts, core, utils 에서는 읽지 않음.
- 문자열 해석은 utils/parsers.py 의 parse_bool, parse_list 를 씀. 막는 실수: 문자열 false 가 참으로 읽히는 일.

## 필수 변수 검사
- 필수 변수 이름은 config/settings/base_env.py 의 REQUIRED_ENV_VARS 한 목록에 모으고, check_required_env() 가 빠진 것을 모두 모아 ImproperlyConfigured 로 한 번에 보고함. 메시지에 .env 를 확인하라고 적음.
- 기본값을 코드에 두지 않음. 안전하지 않은 기본값이 운영으로 넘어가는 일을 막기 위한 것.
- 검사 자체는 테스트로 지킴.

## 기능 스위치
- 선택 기능은 DJANGO_기능_USE 스위치로 켜고 끔. 켜졌을 때만 그 기능의 필수 키를 검사하고 설정을 불러옴. 막는 실수: 쓰지 않는 기능의 변수까지 모든 환경에 요구하는 일.
- 기능마다 기능_env.py(필수 키 목록과 검사 함수)와 기능_settings.py(설정 값)를 짝으로 둠. config/auth/oidc 와 config/mailers 가 이 모양임.
- 바깥 서비스 모듈은 modules/이름/config/env.py 와 settings.py 를 같은 짝으로 둠.

## 비밀 저장소
- 비밀을 비밀 관리 서비스(AWS Secrets Manager 등)에서 받으면 base.py 맨 앞에서 받아 환경변수에 덮어쓴 뒤 필수 검사를 함. 순서를 바꾸면 검사가 비밀에서 온 값을 보지 못함.

## 에이전트가 .env 를 다루는 규칙
- .env 와 .env.example 의 내용을 읽거나 출력하지 않음. 변수 이름이 필요하면 읽는 코드에서 찾음.
- 설정값을 찍는 명령(shell 로 settings 출력, diffsettings, printenv)을 쓰지 않음. shell 은 데이터 건수 확인처럼 설정을 찍지 않는 용도에만 씀.
- manage.py 로 test, migrate, makemigrations, check, collectstatic 을 돌리는 것은 가능함. .env 를 불러오지만 값은 Django 안에서만 쓰임.
- 검색은 .env 계열을 제외함. 예: rg --glob '!**/.env*'. macOS 의 grep --exclude 는 걸러지지 않았음.
- 서브에이전트에게 맡길 때는 설정을 싣는 명령(load_dotenv, manage.py, django.setup)을 쓰지 말고 필요한 값은 직접 넣어 돌리라고 적음.
