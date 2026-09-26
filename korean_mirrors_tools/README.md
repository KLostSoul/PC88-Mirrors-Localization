# Korean Mirrors build tools

완성된 한글 조합 글리프 패치의 전체 빌드 소스다.

ASM·BASIC·데이터 스냅샷과 조합 글리프 입력 데이터는 저장소에 포함하고, 원본
디스크에서 추출한 로컬 파일과 재생성되는 플로피·ISO·컴파일 임시물은 포함하지
않는다. 빌드 중간 파일과 진단 덤프는 `temp/`에 생성된다.

- 빌드 진입점: `python_tools/main.py`
- 번역 입력: `Import/Strings/stringsImportK.csv`
- 하드코딩 출력 문구: `Data/hardcoded_strings.csv`
- 토큰표: `Data/korean_token_table.csv`
- CD 배치표: `Data/i_cddata.csv`
- ASM 입력: `Import/ASM_Source/`
- 공개 ASM 스냅샷: `Export/ASM/`
- 공개 BASIC 스냅샷: `Export/BASIC/`
- 공개 추출 데이터: `Export/Data/`
- 조합 글리프 RAW 입력: `Import/Data/`
- 생성 결과: `output/`의 CloneCD 세트, `img/`에서 인식된 원본 판본별 xdelta 패치(각 3개), FDD용 2HD 공디스크 2개
- 빌드 임시 파일: `temp/`의 BASIC 진단 덤프, 생성 ASM, xdelta 검증용 임시 파일

이미지가 하나면 자동으로 입력에 사용한다. 일본판과 영문판 이미지가 모두 있으면 빌드 전에 이번 한글판 생성에 사용할 이미지 하나를 선택한다. xdelta는 `img/`에서 인식된 모든 판본용으로 생성한다. 판본은 파일명이 아닌 `.img`의 SHA-256으로 식별한다. 자세한 해시와 명령행 옵션은 [`python_tools/README.md`](python_tools/README.md)를 참조한다.

전체 구조와 검증 기준은 [`../docs/korean-localization-design.md`](../docs/korean-localization-design.md)를 참조한다.
