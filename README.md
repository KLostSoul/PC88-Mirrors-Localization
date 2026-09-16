# PC88 Mirrors Localization

PC-8801 CD 게임 **Mirrors**의 한국어 패치 프로젝트다. 공개된 Nebulous Group 영문 패치 소스와 검증된 영문 패치 구조를 기반으로, 원본 게임의 CD Track 2·2HD 배치와 기존 VWF 출력 경로를 최대한 유지하면서 한글 글리프와 한글 문자 토큰을 적용하는 것을 목표로 한다.

영문 패치 출처:

- [Nebulous Group Translations – Mirrors](https://nebulous.group/index.php/projects/translations/mirrors/)

## 프로젝트 목적

- 영문 패치의 BASIC·ASM·CD 데이터 구성과 빌드 절차를 기준선으로 유지
- 기존 VWF 출력 엔진을 한글 2바이트 토큰, 16×16 조합 한글, 8×16 ASCII에 맞춰 확장
- 초성·중성·종성 조합 글리프와 토큰표를 확정하고 전체 번역문에 적용
- 원본 이미지와 생성 이미지의 저작권·용량 문제를 분리하고, 재현 가능한 소스와 분석 결과를 Git에 기록

## 현재 진행사항

### 확정된 구조

- 영문 패치는 원본 CD Track 2의 2D 디스크를 44개 입력과 16개 2HD 그룹으로 재배치한다.
- `Data/i_disks.csv`가 스크립트·논리 디스크·서브 디스크·Track 2 위치를 연결한다.
- 게임은 모든 시나리오를 동시에 RAM에 올리지 않고 현재 실행할 BASIC 스크립트를 교체 로드한다.
- 글리프는 CD에 저장하고 필요한 폰트 데이터를 RAM으로 로드하는 기존 경로를 사용한다.
- 500자 글리프는 생산판 글자 수가 아니라 VWF·토큰·글리프 상주 여부를 확인하기 위한 시험 규격이다.

### 영문 소스와 도구

- Ruby 영문 빌드 도구를 Python 작업 폴더로 1:1 대응시켜 유지하고 있다.
- Ruby 2.7.4 기준 영문 빌드 결과를 Python 결과와 파일·바이트 단위로 대조했다.
- 영문 소스에 포함된 BASIC·ASM·CSV·GFX·Tools·Ghidra 자료는 참조와 재현을 위해 저장소에 보관한다.

### 문자열 대조

전체 원문·영문 패치 대조표는 [`stringsJapaneseEnglish.csv`](korean_mirrors_tools/Export/Strings/stringsJapaneseEnglish.csv)에 기록되어 있다.

- 원문 추출표: 9,720행
- 영문 패치 입력표: 5,282행
- 정상 대응: 5,278행
- 번역 포함 대응: 4,979행
- 번역 공란 대응: 299행
- 패치 쪽 중복: 4행
- 원문에만 존재하는 비패치 문자열: 4,442행
- 대응되지 않은 패치 행: 0행

대조 시 `i_disks.csv` 매핑, 스크립트 순서, 줄 번호·문자열 번호 이동, `−`·`－` 차이와 원문 추출 과정의 `:GOSUB 5100` 꼬리를 함께 처리한다. 기존의 모호한 `english_only` 표기는 사용하지 않고 패치 중복 행은 `patch_duplicate`로 기록한다.

### 한글 조합 글리프 시험

초기 500자 상주 시험에서 사용자가 메뉴 진입과 한글 출력을 확인했고, 이후 16×16 조합 글리프로 전환했다. 조합 글리프 원본·생성기·편집기는 [`Composite_16x16`](Composite_16x16/README.md)에 기록한다.

- 조합 규칙: 8×4×4 초성·중성·종성 벌
- 한글 출력: 16×16, ASCII 출력: 8×16
- ISO·RAW·CloneCD 이미지·원본 Track 2·플로피 추출물·로그·스테이징 결과: Git에서 제외

### 최근 메뉴·NO0·NO1 격리 시험

- 공개 영문 2HD Track 2를 기준으로 메뉴·NO0·NO1만 한글 토큰으로 교체한 시험판의 메뉴 진입과 NO0·NO1 진행을 확인했다.
- 이전 행 번호 전용 매핑은 폐기하고, `source_text`·BASIC 행·문자열 위치·영문 리터럴을 함께 사용하는 매칭으로 교체했다. NO1의 `09:06` 시간값과 `CMD LOAD"NAM1"` 제어 흐름은 보존된다.
- 본문은 16행 프로필과 `&H50*16` 행 이동을 사용해 상단 잘림 없이 출력된다. UI 선택 항목 출력도 `&H60`·`&H50*16`·`CN*16` 기준으로 수정했고, 선택 박스 높이를 16행에 맞췄다.
- UI 설명문 겹침은 VWF 글리프 문제가 아니라 `menu.bas`의 4000/4001·4500/4501 출력 주소가 14행 간격이었던 것이 원인이었다. 4001·4501의 두 번째 주소를 `&HF710`에서 `&HF7B0`으로 옮겨 16행 간격으로 수정했고, UI5에서 겹침이 사라진 것을 확인했다.
- 영문 3종 글리프의 실제 사용 셀을 글리프별로 하단 정렬해 마지막 잉크 행 아래에 한 행의 공백을 남긴 검증판을 만들었다. 메뉴·NO0·NO1에서 한글과 영문 출력이 겹치지 않는 것을 사용자가 확인했다.
- 하단 정렬 글리프를 적용한 최신 검증판은 `Temp/english_menu_no0_no1_ui16_validation/`에서 관리한다. CloneCD Track 2 19,800개 섹터의 EDC/ECC와 페이로드 일치를 정적으로 확인했고, `.ccd`·`.sub` 메타데이터는 기준 이미지와 동일하다.
- 시험 산출물은 `Temp/english_menu_no0_no1_test/`에서 관리한다. 이전 `v2` 산출물은 삭제했다.

### 정식 조합 글리프 전체 빌드

- 정식 빌더는 [`korean_mirrors_tools/python_tools/main.py`](korean_mirrors_tools/python_tools/main.py)다.
- 조합 글리프 리소스 설치, `stringsImportK.csv` 문자열 브리지, 반복 대사 19개 행의 40셀 폭 적용을 정식 빌드 절차에 포함했다.
- 정식 `Import/Files`와 검증 완료 시험판의 파일 해시 차이는 0개이며, `Import/Floppy`도 차이가 0개다.
- 정식 `Import/Data/menu.raw`는 11,257바이트로 시험판과 일치한다.
- 정식 ISO [`02 MIRR.iso`](korean_mirrors_tools/Import/ISO/02%20MIRR.iso)는 40,550,400바이트로 생성됐다.
- 정식 CloneCD는 [`IMG`](korean_mirrors_tools/output/Mirrors_Korean_Mirrors_Tools_Full_Build.img), [`CCD`](korean_mirrors_tools/output/Mirrors_Korean_Mirrors_Tools_Full_Build.ccd), [`SUB`](korean_mirrors_tools/output/Mirrors_Korean_Mirrors_Tools_Full_Build.sub)로 생성됐다.
- Track 2 19,800개 섹터의 EDC/ECC와 ISO 페이로드 일치를 모두 확인했다.

## 문서

- [영문 소스 구조 분석](docs/english-source-structure-map.md)
- [영문 VWF·문자열·스크립트 실측 분석](docs/english-vwf-script-capacity-analysis.md)
- [한글화 설계 및 진행 기록](docs/korean-localization-design.md)
- [문자열 바이트 용량 재계산](docs/string-byte-capacity-analysis.md)
- [원본 CD 이미지 분석](docs/original-cd-image-analysis.md)
- [영문 패치 출처](docs/english-patch-source.md)

## 데이터 및 Git 정책

원본 게임 이미지와 원본에서 추출한 Track 2·플로피 RAW는 저장소에 포함하지 않는다. 영문 패치 공개 소스, 한국어 작업 소스, 토큰표, 글리프 원본, 분석문서는 Git에 기록한다. 생성 이미지와 임시 산출물은 `.gitignore` 정책에 따라 제외한다.
