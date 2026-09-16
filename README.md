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

### 현재 정식 빌드

16×16 한글 조합 글리프 정식 빌드가 완료됐으며, 메뉴·NO0·NO1 시험과 ISO·CloneCD 정적 검증까지 마쳤다. 조합 규칙과 전체 검증 기록은 [한글화 설계 및 진행 기록](docs/korean-localization-design.md), 조합 글리프 자료는 [`Composite_16x16`](Composite_16x16/README.md)에서 확인할 수 있다.

## 문서

- [영문 소스 구조 분석](docs/english-source-structure-map.md)
- [영문 VWF·문자열·스크립트 실측 분석](docs/english-vwf-script-capacity-analysis.md)
- [한글화 설계 및 진행 기록](docs/korean-localization-design.md)
- [문자열 바이트 용량 재계산](docs/string-byte-capacity-analysis.md)
- [원본 CD 이미지 분석](docs/original-cd-image-analysis.md)
- [영문 패치 출처](docs/english-patch-source.md)

## 데이터 및 Git 정책

원본 게임 이미지와 원본에서 추출한 Track 2·플로피 RAW는 저장소에 포함하지 않는다. 영문 패치 공개 소스, 한국어 작업 소스, 토큰표, 글리프 원본, 분석문서는 Git에 기록한다. 생성 이미지와 임시 산출물은 `.gitignore` 정책에 따라 제외한다.
