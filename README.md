# PC88 Mirrors Localization

PC-8801 CD 게임 **Mirrors**의 한국어 패치 프로젝트다. 공개된 Nebulous Group 영문 패치 소스와 검증된 영문 패치 구조를 기반으로, 원본 게임의 CD Track 2·2HD 배치와 기존 VWF 출력 경로를 최대한 유지하면서 한글 글리프와 한글 문자 토큰을 적용하는 것을 목표로 한다.

영문 패치 출처:

- [Nebulous Group Translations – Mirrors](https://nebulous.group/index.php/projects/translations/mirrors/)

## 프로젝트 목적

- 영문 패치의 BASIC·ASM·CD 데이터 구성과 빌드 절차를 기준선으로 유지
- 기존 VWF 출력 엔진을 한글 2바이트 토큰, 16×16 조합 한글, 8×16 ASCII에 맞춰 확장
- 초성·중성·종성 조합 글리프와 토큰표를 확정하고 전체 번역문에 적용
- 원본 이미지와 생성 이미지의 저작권·용량 문제를 분리하고, 재현 가능한 소스와 분석 결과를 Git에 기록

## 스크린샷

![Mirrors](images/mirrors.PNG)

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

### 현재 정식 빌드 구성

16×16 한글 조합 글리프 정식 빌드가 완료됐다. 시험판의 출력 기준과 조합 글리프 구성을 정식 전체 빌드에 반영했으며, 메뉴·NO0·NO1 시험과 ISO·CloneCD 정적 검증까지 완료했다.

최근 `END`를 포함한 정식 전체 재빌드도 성공했다. 생성된 `02 MIRR.iso`는 40,550,400바이트이며, 컴파일 산출물에 구형 선택 UI 패턴(`&HF0D2`, `&H20`, `*13`)이 남아 있지 않다. 정식 빌드에서 사용하지 않는 구형 보조 코드 `fontgen.py`와 `imgdecode.py`도 제거했다.

#### 입력 자료

- 빌더: [`korean_mirrors_tools/python_tools/main.py`](korean_mirrors_tools/python_tools/main.py)
- 번역: `korean_mirrors_tools/Import/Strings/stringsImportK.csv`
- 하드코딩 출력 문구: `korean_mirrors_tools/Data/hardcoded_strings.csv`
- 토큰: `korean_mirrors_tools/Data/korean_token_table.csv`의 실제 빌드 입력 음절 전체
- 조합 원본: [`Composite_16x16`](Composite_16x16/README.md)의 `han_dkby.fnt`와 ASCII 8×16 템플릿
- 출력 코드: `korean_mirrors_tools/Import/ASM_Source/vwf.asm`, `asmbasic.asm`, `asmmain.asm`
- GFX 입력: `Data/i_gfx.csv`에 등록된 교체 그래픽만 유지하며, 구형 8×16 폰트·`Composite_8x16` 시험 자료는 제거했다.

#### 토큰과 조합 방식

- 한글은 2바이트 안전 토큰으로 저장하며, CSV의 실제 토큰 쌍을 단일 기준으로 사용한다.
- 런타임은 안전한 선두 바이트 75개와 후행 바이트 165개를 역변환해 유니코드 한글 음절 인덱스를 계산한다.
- 계산한 음절 인덱스를 초성 19·중성 21·종성 28로 분해하고, 8×4×4 벌 선택 규칙으로 컴포넌트 세 개를 16×16 버퍼에 OR 조합한다.
- 완성 음절 RAW를 적재하지 않는다. 빌드 입력에 실제로 쓰이는 음절만 가나다순 토큰표에 기록하고, 글리프는 런타임 조합으로 생성된다. 번역문에 새 음절이 추가되면 저장·빌드 시 토큰표가 자동 재생성된다.

#### 확장 RAM과 CD 배치

- 물리 확장 RAM bank 0 하나만 사용한다. `vFontNumber`, 기존 영문 3종 폰트 선택, bank 1 전환은 정식 조합 글리프 경로에서 사용하지 않는다.
- RAM `0x0000`부터 VWF 코드, `0x1000`부터 ASCII 8×16 슬롯 표, `0x2000~0x4CFF`에 8×4×4 한글 컴포넌트를 둔다.
- ASCII 원본은 0x1000바이트, 한글 컴포넌트 원본은 0x2D00바이트이며 0x6000바이트로 0 패딩한 뒤 0x2000바이트씩 세 청크로 나눈다.
- CD Track 2 배치는 VWF `0x10000`, ASCII `0x11000`, 컴포넌트 청크 `0x12000`, `0x14000`, `0x16000`이다.

#### 출력 경로

- ASCII는 8×16 셀·8픽셀 전진으로 출력한다.
- 한글은 컴포넌트 세 개를 32바이트 버퍼에 조합하고 16×16으로 출력하며 16픽셀 전진한다.
- 두 문자 경로 모두 기존 VWF의 16행 화면 출력 루틴을 사용한다. 줄바꿈과 BASIC 제어 바이트는 한글 토큰 소비와 분리한다.

#### 정식 빌드 순서와 검증

1. 조합 ASCII·컴포넌트 RAW를 생성하고 크기를 검사한다.
2. 영문 패치 BASIC에 `stringsImportK.csv`를 문자열 위치 기준으로 연결한다.
3. 반복 대사 19개 행의 출력 폭을 40셀로 적용한다.
4. 전체 BASIC·ASM·디스크 데이터를 컴파일해 ISO를 생성한다.
5. 시험판과 `Import/Files`·`Import/Floppy`를 해시 대조하고, CloneCD Track 2 19,800개 섹터의 EDC/ECC와 페이로드를 검증한다.

세부 설계와 전체 검수 기록은 [한글화 설계 및 진행 기록](docs/korean-localization-design.md), 조합 글리프 원본·생성기·편집기는 [`Composite_16x16`](Composite_16x16/README.md)에서 확인할 수 있다.

## 문서

- [문서 목차](docs/README.md)

- [영문 소스 구조 분석](docs/english-source-structure-map.md)
- [영문 VWF·문자열·스크립트 실측 분석](docs/english-vwf-script-capacity-analysis.md)
- [한글화 설계 및 진행 기록](docs/korean-localization-design.md)
- [문자열 바이트 용량 재계산](docs/string-byte-capacity-analysis.md)
- [원본 CD 이미지 분석](docs/original-cd-image-analysis.md)
- [영문 패치 출처](docs/english-patch-source.md)

## 라이선스

- 이 프로젝트에서 새로 작성한 생성기·토큰 도구·편집기 등 프로젝트 자체 소스는 [LICENSE-MIT-PROJECT.txt](LICENSE-MIT-PROJECT.txt)에 따라 MIT 라이선스로 배포한다.
- Composite_16x16에 포함된 원본 폰트와 그 파생 글리프는 해당 폴더의 [LICENSE-OFL.txt](Composite_16x16/LICENSE-OFL.txt)에 따른다.
- Composite_16x16에 보관된 원본 생성·변환 소스의 upstream MIT 고지는 [LICENSE-MIT.txt](Composite_16x16/LICENSE-MIT.txt)에 보관한다.
- Nebulous Group 영문 패치, 원본 게임·이미지·추출물 및 기타 외부 자료는 이 프로젝트의 MIT 라이선스 범위에 포함하지 않는다.

## 데이터 및 Git 정책

원본 게임 이미지와 원본에서 추출한 Track 2·플로피 RAW는 저장소에 포함하지 않는다. 영문 패치 공개 소스, 한국어 작업 소스, 토큰표, 글리프 원본, 분석문서는 Git에 기록한다. 생성 이미지와 임시 산출물은 `.gitignore` 정책에 따라 제외한다.
