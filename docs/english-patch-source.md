# 영문 패치 출처

이 프로젝트에서 참조하는 `Mirrors` PC-8801 MC 영문 패치의 출처와 재배포 조건을 기록한다.

## 원본 출처

- 영문 패치 프로젝트 페이지: <https://nebulous.group/index.php/projects/translations/mirrors/>
- 영문 패치 빌드 도구·소스 저장소: <https://github.com/Mistranger/mirrors_tools>
- 현재 프로젝트에 보관된 영문 패치 패키지: `reference/Mirrors_ENG_translation_v1.0/`
- 현재 프로젝트에 보관된 영문 패치 분석 소스: `reference/mirrors_tools/`

## 패키지 구성

`reference/Mirrors_ENG_translation_v1.0/`에는 영문 패치 배포본에서 가져온 다음 자료가 포함되어 있다.

- `disk1main.d88`, `disk2game.d88`: 영문 패치용 PC-8801 디스크 이미지
- `patcher/`: CloneCD 이미지용 xdelta 패치와 패치 실행 파일
- `pc8801ma.ini`: ePC8801MA 권장 설정
- `readme.txt`: 원본 배포 readme 및 사용·재배포 조건

`reference/mirrors_tools/`에는 영문 패치를 빌드·분석하기 위한 Ruby 도구, ASM/BASIC 소스, 데이터 표, 그래픽 자료가 포함되어 있다.

## 재배포 조건

배포본의 `reference/Mirrors_ENG_translation_v1.0/readme.txt` 6절(Disclaimer)에 따르면, 해당 번역은 금전적 대가를 받지 않는 조건에서 `readme.txt`를 함께 포함하면 자유롭게 재배포할 수 있다. 이 조건을 유지하기 위해 원본 `readme.txt`를 패키지에 포함해 보존한다.

이 기록은 영문 패치 자료의 출처를 명확히 하기 위한 것이며, 원본 게임 CD 이미지와 별도 보관 중인 `reference/Original/` 자료의 재배포를 의미하지 않는다.
