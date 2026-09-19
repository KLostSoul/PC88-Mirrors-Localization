# Mirrors PC-8801 MC 한글 조합 글리프 빌드 설계

이 문서는 현재 저장소의 정식 한글 빌드가 무엇을 입력으로 사용하고, 어떤 토큰·글리프·메모리·CD 배치·출력 경로로 동작하는지 기록하는 기준 문서다. 현재 구현과 충돌하는 초기 시험 설계는 마지막의 역사 기록으로 분리했다.

문서의 적용 범위는 `korean_mirrors_tools` 정식 빌드다. 영문 패치의 원래 구조와 Ruby 기준 구현은 [영문 소스 구조 맵](english-source-structure-map.md)을 참조한다.

## 1. 현재 상태와 기준

- 정식 빌드 진입점은 `korean_mirrors_tools/python_tools/main.py`다.
- 정식 빌드는 저장소 상위 `Temp`나 `reference/python_mirrors_tools`를 입력으로 사용하지 않는다.
- 영문 패치의 BASIC·ASM·CD 재구성 구조와 44개 2D 입력·16개 2HD 그룹 배치는 유지한다.
- 한글 출력은 기존 VWF의 화면 합성 구조를 참고해 수정한 조합형 VWF를 사용한다.
- 현재 확정된 글리프 구성은 한글 16×16, ASCII 8×16이다.
- 원본 CD 이미지, 추출 Track 2, 플로피 RAW, ISO·CloneCD 결과물은 Git에 넣지 않고 로컬 `Temp` 또는 빌드 출력 경로에서 관리한다.

## 2. 정식 빌드 입력

| 구분 | 기준 경로 | 용도 |
|---|---|---|
| 빌더 | `korean_mirrors_tools/python_tools/main.py` | 전체 빌드 진입점 |
| 한글 번역 | `korean_mirrors_tools/Import/Strings/stringsImportK.csv` | 전체 번역 입력 |
| 하드코딩 문구 | `korean_mirrors_tools/Data/hardcoded_strings.csv` | 오프닝·저장·CD 전환 등 BASIC 패치 직접 삽입 문구 |
| 메뉴·인트로 대응 기준 | 현재 `Import/BASIC/*.bas`의 영문 리터럴·BASIC 행·문자열 위치 | 영문 패치 BASIC과 한글 행 연결 |
| 조합 토큰 | `korean_mirrors_tools/Data/korean_token_table.csv` | 토큰·음절·조합 정보의 단일 기준 |
| 조합 글리프 원본 | `Composite_16x16/source/han_dkby.fnt` | 8×4×4 자모 컴포넌트 |
| ASCII 원본 | `Composite_16x16/source/ascii_8x16_template.fnt` | 256슬롯 ASCII 템플릿 |
| 출력 VWF | `korean_mirrors_tools/Import/ASM_Source/vwf.asm` | 토큰 해석·조합·화면 출력 |
| BASIC 연결 | `korean_mirrors_tools/Import/ASM_Source/asmbasic.asm` | BASIC 확장·출력 호출 연결 |
| 메인 패치 | `korean_mirrors_tools/Import/ASM_Source/asmmain.asm` | 패치 명령과 런타임 연결 |
| CD 배치표 | `korean_mirrors_tools/Data/i_cddata.csv` | ASM·RAW의 Track 2 위치와 크기 |

`stringsImportK.csv`가 번역 입력의 단일 기준이다. 영문 패치에서 줄 번호·문자열 위치가 달라진 메뉴·인트로는 현재 `Import/BASIC/*.bas`에 실제로 존재하는 영문 리터럴과 BASIC 행·문자열 위치를 함께 사용해 연결한다. BASIC 행 번호만으로 문자열을 선택하지 않는다.

CSV 번역표를 거치지 않고 직접 삽입되는 오프닝·저장·CD 전환·출력 마커 7개와 ASM이 VWF에 직접 보내는 저장 슬롯 안내문 1개, 메뉴 BASIC의 직접 출력 문구 14개를 `hardcoded_strings.csv`로 관리한다. 문구 수정은 실제 컴파일 용량 검사와 정식 빌드에 반영된다. ASM 안내문은 기존 29바이트 고정 슬롯 안에서만 변경할 수 있으며, 초과하거나 토큰표에 없는 문자를 사용하면 빌드를 중단한다.


## 3. 한글 토큰과 조합 규칙

### 3.1 토큰표

`korean_token_table.csv`가 토큰의 단일 기준이다. 현재 파일에는 다음 필드가 있다.

```text
token_index;character;unicode;token_word;token_hi;token_lo;
initial_index;medial_index;final_index;composition_payload
```

- 번역문·하드코딩 문구·기본 패치에서 실제로 출력되는 모든 음절을 가나다순으로 기록한다.
- 정식 빌드 시작 시 새 음절을 자동 감지해 토큰표를 재생성한다.
- `token_word`는 2바이트 토큰이며, `token_hi`와 `token_lo`가 그 바이트를 분리해 기록한다.
- `composition_payload`는 유니코드 음절을 초성·중성·종성 인덱스로 확인하기 위한 검증용 값이다.
- 완성 음절의 16×16 RAW를 확장 RAM에 미리 적재하지 않는다.
- 토큰표는 빌드 시 문자열 인코딩과 ASM 검증에 사용하고, 런타임은 토큰을 유니코드 한글 음절 인덱스로 역변환한 뒤 조합한다.

### 3.2 런타임 조합

한글 토큰 하나의 처리 순서는 다음과 같다.

```text
2바이트 토큰 읽기
→ 선두·후행 테이블에서 토큰 위치 확인
→ 유니코드 한글 음절 인덱스 계산
→ 초성 19·중성 21·종성 28로 분해
→ 8×4×4 벌 선택
→ 초성·중성·종성 컴포넌트 세 개를 32바이트 버퍼에 OR 조합
→ 16×16으로 출력
→ 16픽셀 전진
```

컴포넌트 원본은 `0x2D00`바이트이며, 8×4×4 배치 규칙으로 초성·중성·종성의 프로필을 선택한다. 받침이 없으면 종성 컴포넌트를 조합하지 않는다.

문자 처리 우선순위는 다음과 같다.

```text
1. BASIC 제어·이스케이프 바이트 확인
2. 제어 데이터면 기존 제어 동작 수행
3. 한글 토큰 선두면 후행 바이트까지 소비해 조합
4. 일반 ASCII면 ASCII 글리프 출력
5. 어느 경로에도 해당하지 않는 바이트는 출력하지 않음
```

한글 토큰의 두 번째 바이트를 제어 바이트나 일반 ASCII로 다시 처리하지 않는다. 반대로 제어 바이트를 숫자 범위만으로 한글 토큰에서 제거하지 않는다.

## 4. 확장 RAM과 CD 배치

정식 조합 글리프 빌드는 물리 확장 RAM bank 0 하나만 사용한다. `vFontNumber`, 기존 영문 3종 폰트 선택, bank 1 전환, `copyFntBank1`은 현재 정식 경로에 없다.

### 4.1 bank 0 배치

```text
0x0000~0x0FFF : VWF 코드·런타임 변수·조합 버퍼
0x1000~0x1FFF : ASCII 256슬롯 × 16바이트
0x2000~0x4CFF : 8×4×4 한글 컴포넌트
0x4D00~0x7FFF : 예약 영역
```

ASCII 원본은 `0x1000`바이트다. 실제 출력 가능한 ASCII 영역은 8×16 셀로 읽고, 폭표는 256칸 구조를 유지한다. 한글 컴포넌트 원본 `0x2D00`은 `0x6000`까지 0으로 패딩한 뒤 세 청크로 나눈다.

### 4.2 CD Track 2 배치

`korean_mirrors_tools/Data/i_cddata.csv`의 현재 배치는 다음과 같다.

```text
0x10000~0x10FFF : vwf
0x11000~0x11FFF : composite_ascii
0x12000~0x13FFF : composite_components_0
0x14000~0x15FFF : composite_components_1
0x16000~0x17FFF : composite_components_2
```

ASM·사운드 데이터 배치는 같은 CSV에 남아 있는 영문 패치 기준을 유지한다. `COMMON R`와 복사 루틴은 이 CD 주소와 CPU 임시 버퍼를 통해 데이터를 bank 0으로 적재한다. CD에 RAW를 배치하는 것만으로 끝내지 않고, BASIC 로딩 루틴이 다섯 데이터 영역을 실제로 읽는지 정적 검증한다.

## 5. VWF 출력 규칙

### 5.1 문자별 출력

| 입력 | 글리프 | 화면 셀 | 전진 폭 |
|---|---|---:|---:|
| ASCII | 8×16 | 1셀 | 8픽셀 |
| 한글 토큰 | 조합한 16×16 | 2셀 | 16픽셀 |

ASCII와 한글은 같은 16행 래스터 출력 루틴을 사용한다. 한글만 별도의 영문 폰트나 완성 음절 RAW로 보내지 않는다. 조합 버퍼를 만든 뒤 첫 번째 8픽셀 버퍼와 두 번째 8픽셀 버퍼를 차례로 출력한다.

### 5.2 줄바꿈·세로 기준

- 본문은 16행 출력 프로필과 `0x50 × 16` 행 이동을 사용한다.
- Python 컴파일러가 생성하는 `0x5C` 줄바꿈과 기존 `0x0D` 줄바꿈을 모두 처리한다.
- 한글은 두 셀을 출력하므로 문자 잔여 폭도 두 셀만큼 감소시킨다.
- UI 선택문·설명문은 본문과 다른 출력 주소를 가질 수 있으므로 `menu.bas`의 각 주소와 창 높이를 별도로 16행 기준에 맞춘다.
- 반복 직접 출력 대사 19개 행은 `CMD WIDTH &HF0C2,&H28,7`로 40개의 8픽셀 셀을 사용한다.
- 메뉴 선택 커서와 시스템 설정 커서는 해당 UI의 실제 화면 주소를 기준으로 세로 위치를 조정한다. 문장 한 줄을 내리는 것과 커서를 1픽셀 내리는 것은 서로 다른 수정이다.

글리프의 하단 정렬은 시험판에서 확인한 기준을 정식 빌드에 반영했다. 영문 3종 폰트 선택 구조를 되살리는 것이 아니라, 조합 글리프의 16행 출력과 ASCII 템플릿의 기준선을 맞추는 조정이다.

### 5.1.1 BASIC 문자열의 따옴표

- 번역 CSV에는 일반적인 `"`를 그대로 입력한다. 사용자가 `\"`를 직접 입력하지 않는다.
- 컴파일러는 문자열 내부의 `"`를 BASIC 문자열 안에 raw `0x22`로 넣지 않고, 문자열을 `+CHR$(34)+`로 분리해 최종 출력 바이트가 `0x22`가 되도록 한다. raw `0x22`는 BASIC 런타임에서 문자열 종료로 해석되기 때문이다.
- 백틱 `` ` ``은 `0x60`, 작은따옴표 `'`는 `0x27`로 그대로 출력한다. 두 문자를 연속으로 입력하면 `` ` ``와 `'`를 각각 구분해 출력할 수 있다.
- 백슬래시 `\`를 따옴표 이스케이프로 사용하지 않는다. 현재 VWF에서는 `0x5C`가 줄바꿈 처리에 사용된다.

## 6. 정식 빌드 실행 순서

`korean_mirrors_tools/python_tools/main.py`의 실제 순서는 다음과 같다.

```text
1. Composite_16x16/source에서 ASCII·컴포넌트 RAW 설치
2. 조합 컴포넌트 크기와 ASCII 0x1000바이트 크기 확인
3. DataImporter 초기화
4. 실제 영문 BASIC 리터럴·BASIC 행·문자열 위치로 메뉴·인트로 문자열 연결
5. 반복 대사 19개 행의 폭을 40셀로 패치
6. 전체 BASIC·ASM·그래픽·플로피·ISO 생성
7. FDD용 2HD 공디스크 2개 생성
8. 생성물 크기·주소·해시·Track 2 구조 검증
```

빌더는 다음을 자동으로 중단시켜야 한다.

- ASCII 템플릿이 `0x1000`바이트가 아닌 경우
- 조합 컴포넌트 원본이 `0x2D00`바이트가 아닌 경우
- 반복 대사 19개 행이 정확히 매칭되지 않는 경우
- 토큰표에 완성 음절 RAW 주소 필드가 다시 들어온 경우
- 지원하지 않는 문자가 폭 0으로 조용히 통과하는 경우
- BASIC 스트림의 문자열·수치·제어 토큰 경계가 영문 기준 구조와 불일치하는 경우

## 7. 정적 검증 기준

정식 빌드 검수는 어셈블 성공이나 파일 크기만 확인하지 않는다.

### 7.1 입력·토큰·글리프

- `stringsImportK.csv`의 논리 레코드와 `None` 필드 확인
- 원문·영문·한글 행의 순서와 문자열 위치 대조
- 토큰표의 중복·누락·토큰 바이트·조합 인덱스 대조
- Python 계산값과 ASM 선두·후행 토큰표의 바이트 단위 대조
- 조합 컴포넌트 세 청크를 합친 값과 `han_dkby.fnt`+패딩 대조
- ASCII RAW가 `ascii_8x16_template.fnt`와 일치하는지 대조

### 7.2 BASIC 스트림

- 영문 패치 BASIC과 한글 BASIC의 행·명령·수치·문자열 구조 비교
- N88-BASIC 파서가 소비하는 문자열·수치·제어 토큰 길이 확인
- `RST 08H` 기대 바이트 검증 위치와 실제 스트림 바이트 대조
- 줄바꿈·문자열 종료·`CMD LOAD`·`COMMON`의 바이트 경계 확인
- 실패 경로인 `ED66 → DBCC`가 생성 스트림에서 발생할 수 없는지 확인
- NO0·NO1 전환 행의 `COMMON STOP`, `COMMON COPY`, `COMMON R`, `CMD LOAD` 보존 확인

### 7.3 CD·파일

- `i_cddata.csv`의 offset·size와 생성 RAW 크기 대조
- BASIC 로더가 CD에 배치한 VWF·ASCII·컴포넌트 청크를 모두 읽는지 확인
- ISO Track 2에 삽입된 페이로드와 생성 파일 대조
- CloneCD Track 2 전체 19,800개 섹터의 EDC/ECC와 페이로드 일치 확인
- ISO·CloneCD·RAW·로그는 Git에 들어가지 않는지 확인

## 8. 확인된 정식 빌드 상태

- 정식 소스는 `korean_mirrors_tools`로 통일했다.
- 정식 빌더는 `Composite_16x16`의 ASCII·컴포넌트 원본을 직접 설치한다.
- `korean_mirrors_tools/GFX`에는 `Data/i_gfx.csv`에 등록된 실제 교체 그래픽만 남겼다. 구형 8×16 폰트·완성형 한글 PNG·`Composite_8x16` 시험 자료는 정식 빌드에서 사용하지 않으므로 삭제했다.
- 전체 번역 입력에는 `stringsImportK.csv`를 사용하고, 메뉴·인트로의 영문 패치 행은 문자열 브리지로 연결한다.
- 완성 음절 RAW를 적재하지 않고, 실행 시 조합 글리프로 생성한다. 음절 수는 번역 입력에 따라 변할 수 있다.
- 메뉴·NO0·NO1 격리 시험에서 한글 출력, 영문·한글 혼용, 줄바꿈, UI 선택문, 40셀 반복 대사를 확인했다.
- 메뉴 하드코딩 문구 14개를 `hardcoded_strings.csv`로 관리하고, 수정한 값이 용량 검사와 전체 빌드에 반영되도록 했다.
- 일반 `"`의 `0x22` 출력, 백틱 `0x60`, 작은따옴표 `0x27`의 구분 출력을 확인했다. 문자열 내부의 따옴표에서 BASIC 스트림이 중단되지 않는다.
- 정식 전체 빌드의 ISO·CloneCD 정적 검증을 완료했다.
- 정식 빌드가 에뮬레이터 FDD용 2HD 공디스크 `disk1main.d88`과 `disk2game.d88`를 `korean_mirrors_tools/output`에 생성하도록 반영했다. 두 파일은 160개 트랙, 1,331,888바이트의 2HD D88 구조다.
- 사용자가 확인한 실행 범위에서는 메뉴부터 NO1/NO2 구간까지 조합 글리프 출력과 게임 진행이 정상이다. 전체 시나리오의 런타임 확인 여부는 정적 빌드 검증과 별도로 기록한다.
- 최근 `END`를 포함한 정식 전체 재빌드를 성공시켰다. `Temp/basic/NO1`과 `Temp/basic/END` 모두 16행 UI 출력(`&H60`, `*16`)으로 생성되며, 컴파일 산출물에는 구형 `&HF0D2`, `&H20`, `*13` 선택 UI 패턴이 남아 있지 않다.
- 최근 생성된 `Import/ISO/02 MIRR.iso`는 40,550,400바이트이며, 조합 데이터는 ASCII 4,096바이트와 컴포넌트 3청크 각 8,192바이트로 확인했다.
- 정식 빌드에서 참조하지 않는 구형 보조 코드 `python_tools/fontgen.py`와 `python_tools/imgdecode.py`는 삭제했다. `python_tools`의 현재 빌드 모듈에 해당 코드 참조가 남아 있지 않다.

정식 산출물 경로는 다음과 같다.

```text
korean_mirrors_tools/Import/ISO/02 MIRR.iso
korean_mirrors_tools/output/disk1main.d88
korean_mirrors_tools/output/disk2game.d88
korean_mirrors_tools/output/Mirrors_Korean_Mirrors_Tools_Full_Build.img
korean_mirrors_tools/output/Mirrors_Korean_Mirrors_Tools_Full_Build.ccd
korean_mirrors_tools/output/Mirrors_Korean_Mirrors_Tools_Full_Build.sub
```

## 9. 폐기된 초기 설계와 시험 기록

아래 항목은 현재 정식 빌드의 규칙이 아니다. 과거 시험의 원인과 변경 이력을 보존하기 위해 기록한다.

- 500개 완성 글리프를 연속 RAW로 적재하는 시험
- `E0~E5` 계열의 초기 토큰안
- `0x1000 + index × 16`으로 1,093개 완성 음절 RAW를 직접 읽는 방식
- 물리 bank 1에 한글 VWF·글리프를 적재하고 bank를 전환하는 방식
- `vFontNumber`로 영문 3종 폰트를 선택하는 방식
- 기존 영문 3개 폰트 영역을 한글 글리프로 덮어쓰는 방식
- `Temp/korean_composite_*` 및 `Temp/english_menu_*`에 있던 격리 시험 산출물

500자 안전 토큰 시험은 제어 바이트 충돌과 BASIC 스트림 정지 원인을 분리하는 데 사용했다. 이후 16×16 조합 글리프 시험에서 다음 문제를 확인·수정했다.

1. `0x5C` 줄바꿈과 기존 `0x0D` 줄바꿈의 처리 불일치
2. 16행 출력과 맞지 않는 기존 줄 이동값
3. 한글 2셀 출력 후 잔여 셀을 1셀만 차감하던 오류
4. 직접 VWF 호출 데이터가 새 입력 규칙과 맞지 않던 문제
5. 토큰표에 완성 음절 RAW 메타데이터가 남아 있던 문제
6. 지원하지 않는 문자를 폭 0으로 넘기던 문제

이 문제들은 현재 정식 `vwf.asm`, Python 컴파일러, 토큰표 검증과 빌드 회귀 검사에 반영되어 있다. 과거 시험 산출물은 현재 정식 입력이나 기준으로 사용하지 않는다.

## 10. 관련 문서의 역할

- [문서 목차](README.md): 현재 기준 문서와 분석 문서의 관계
- [영문 패치 소스 구조 맵](english-source-structure-map.md): 영문 Ruby 기준선과 CD·BASIC·ASM 구조
- [영문 VWF·문자열·스크립트 실측 분석](english-vwf-script-capacity-analysis.md): 영문판 용량·VWF·스크립트 실측
- [원본 CD 이미지 분석](original-cd-image-analysis.md): 원본 Track 2·플로피 물리 구조
- [영문 패치 출처](english-patch-source.md): 영문 패치의 출처와 재배포 조건
- [`Composite_16x16/README.md`](../Composite_16x16/README.md): 조합 글리프 원본·생성기

세부 영문 분석 문서의 `vFontNumber`, 3종 폰트, 영문 8×16 슬롯 설명은 영문 패치의 과거 기준선을 설명하는 자료다. 현재 한글 정식 빌드의 구현 규칙으로 읽지 않는다.

## 11. Git·재빌드 정책

Git에 기록하는 것:

- ASM·BASIC·Python 빌드 소스
- `stringsImportK.csv`와 조합 토큰표
- `Composite_16x16/source`의 글리프 원본·생성기
- 설계·분석·검수 문서
- 영문 패치의 공개 소스와 출처 기록

Git에서 제외하는 것:

- 원본 게임 CD 이미지와 추출 Track 2
- 원본·생성 플로피 RAW
- ISO·IMG·CCD·SUB 등 빌드 산출물
- 에뮬레이터 로그와 임시 시험 결과

저장소를 복제한 뒤 빌드하려면 사용자가 보유한 원본 CD에서 필요한 Track 2와 플로피 입력을 먼저 준비해야 한다. 정식 빌드 소스는 `korean_mirrors_tools`이며, legacy Python 포트는 `reference/python_mirrors_tools`에 보관된 참고 자료다.
