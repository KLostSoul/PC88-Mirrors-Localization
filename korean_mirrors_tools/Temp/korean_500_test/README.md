# Korean 500-glyph test source

이 폴더는 500자 한글 글리프를 RAM에 상주시켜 기존 VWF 출력 경로로 메뉴까지 출력하는 시험의 재현용 소스 입력을 보관한다.

추적 대상:

- `assets/*.py`: 시험용 폰트·토큰·BASIC/이미지/CloneCD 생성 스크립트
- `assets/*.bas`, `assets/*.asm`: 시험용 BASIC·VWF 소스
- `assets/*.csv`: 시험 토큰표
- `assets/*.png`: 시험 글리프 원본
- `assets/font_test/*.py`: 시험 글리프 원본 생성 스크립트
- `korean_mirrors_tools/Data/i_cddata_korean500_test.csv`: 시험 CD 데이터 배치표

ISO, RAW, CloneCD 세트, 로그, 매니페스트와 `.lst` 파일은 생성 결과이므로 Git에 넣지 않는다. 500자는 생산판의 최종 글자 수가 아니라 출력 경로 검증을 위한 임시 시험 규격이다.
