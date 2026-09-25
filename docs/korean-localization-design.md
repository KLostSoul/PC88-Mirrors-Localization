# Mirrors PC-8801 MC 정식 한글 빌드 구조

이 문서는 완성된 정식 한글 빌드의 입력, 토큰, 글리프, 메모리·CD 배치, 출력 경로와 검증 결과를 기록한다.

문서의 적용 범위는 `korean_mirrors_tools` 정식 빌드다. 영문 패치의 원래 구조와 Ruby 기준 구현은 [영문 소스 구조 맵](english-source-structure-map.md)을 참조한다.

## 1. 빌드 구성

- 정식 빌드 진입점은 `korean_mirrors_tools/python_tools/main.py`다.
- 영문 패치의 BASIC·ASM·CD 재구성 구조와 44개 2D 입력·16개 2HD 그룹 배치는 유지한다.
- 한글 출력은 조합 글리프용으로 수정된 VWF를 사용한다.
- 현재 확정된 글리프 구성은 한글 16×16, ASCII 8×16이다.

## 2. 정식 빌드 입력

| 구분 | 기준 경로 | 용도 |
|---|---|---|
| 빌더 | `korean_mirrors_tools/python_tools/main.py` | 전체 빌드 진입점 |
| 한글 번역 | `korean_mirrors_tools/Import/Strings/stringsImportK.csv` | 전체 번역 입력 |
| 하드코딩 문구 | `korean_mirrors_tools/Data/hardcoded_strings.csv` | 오프닝·저장·CD 전환 등 BASIC 패치 직접 삽입 문구 |
| 메뉴·인트로 대응 기준 | 현재 `Import/BASIC/*.bas`의 영문 리터럴·BASIC 행·문자열 위치 | 영문 패치 BASIC과 한글 행 연결 |
| 조합 토큰 | `korean_mirrors_tools/Data/korean_token_table.csv` | 토큰·음절·조합 정보의 단일 기준 |
| 조합 글리프 원본 | `Composite_16x16/source/han_hanme.fnt` | 8×4×4 자모 컴포넌트 |
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

### 5.3 BASIC 문자열의 따옴표

- 번역 CSV에는 일반적인 `"`를 그대로 입력한다. 사용자가 `\"`를 직접 입력하지 않는다.
- 컴파일러는 문자열 내부의 `"`를 BASIC 문자열 안에 raw `0x22`로 넣지 않고, 문자열을 `+CHR$(34)+`로 분리해 최종 출력 바이트가 `0x22`가 되도록 한다. raw `0x22`는 BASIC 런타임에서 문자열 종료로 해석되기 때문이다.
- 백틱 `` ` ``은 `0x60`, 작은따옴표 `'`는 `0x27`로 그대로 출력한다. 두 문자를 연속으로 입력하면 `` ` ``와 `'`를 각각 구분해 출력할 수 있다.
- 백슬래시 `\`를 따옴표 이스케이프로 사용하지 않는다. 현재 VWF에서는 `0x5C`가 줄바꿈 처리에 사용된다.

## 6. 정식 빌드 실행 순서

`korean_mirrors_tools/python_tools/main.py`의 실제 순서는 다음과 같다.

```text
1. `img/`의 `.img` SHA-256으로 일본판·영문판 판별
2. 기준 이미지 하나면 자동 선택하고, 둘 다 있으면 사용자가 선택
3. 선택한 Track 2를 추출하고 Composite_16x16/source에서 ASCII·컴포넌트 RAW 설치
4. 조합 컴포넌트 크기와 ASCII 0x1000바이트 크기 확인
5. DataImporter 초기화
6. 실제 영문 BASIC 리터럴·BASIC 행·문자열 위치로 메뉴·인트로 문자열 연결
7. 반복 대사 19개 행의 폭을 40셀로 패치
8. 전체 BASIC·ASM·그래픽·플로피·ISO 생성
9. FDD용 2HD 공디스크 2개 생성
10. 선택한 이미지에 CloneCD Track 2 반영 및 EDC/ECC 검사
11. `img/`에서 인식된 각 기준판용 xdelta 생성 후 원본 복원 결과와 빌드 출력 해시 대조
```

빌드 입력 검사는 다음 크기·문자 조건을 확인한다.

- ASCII 템플릿이 `0x1000`바이트가 아닌 경우
- 조합 컴포넌트 원본이 `0x2D00`바이트가 아닌 경우
- 반복 대사 19개 행이 정확히 매칭되지 않는 경우
- 지원하지 않는 문자가 폭 0으로 조용히 통과하는 경우

## 7. 빌드 검증

### 7.1 입력·토큰·글리프

- `stringsImportK.csv`의 논리 레코드와 `None` 필드 확인
- 원문·영문·한글 행의 순서와 문자열 위치 대조
- 토큰표의 중복·누락·토큰 바이트·조합 인덱스 대조
- Python 계산값과 ASM 선두·후행 토큰표의 바이트 단위 대조
- 조합 컴포넌트 세 청크를 합친 값과 `han_hanme.fnt`+패딩 대조
- ASCII RAW가 `ascii_8x16_template.fnt`와 일치하는지 대조

### 7.2 BASIC 스트림

- 컴파일된 BASIC의 문자열·연산자·수치·제어 토큰 구조와 바이트 경계 확인
- 각 BASIC 스크립트의 컴파일 크기와 디스크 배치 확인
- NO 간 전환 및 `CMD LOAD`·`COMMON` 실행 흐름 보존 확인

### 7.3 CD·파일

- `i_cddata.csv`의 offset·size와 생성 RAW 크기 대조
- BASIC 로더가 CD에 배치한 VWF·ASCII·컴포넌트 청크를 모두 읽는지 확인
- ISO Track 2에 삽입된 페이로드와 생성 파일 대조
- CloneCD Track 2 전체 19,800개 섹터의 EDC/ECC와 페이로드 일치 확인
- `img/`에서 인식된 각 기준판의 xdelta를 적용해 복원한 `.ccd`, `.img`, `.sub`의 SHA-256이 완성 빌드 출력과 같은지 확인

## 8. 실행 확인 및 산출물

전체 게임을 엔딩까지 플레이해 한국어·영어 출력, 줄바꿈, 선택지와 시나리오 진행을 확인했다. 완성 빌드에는 다음 산출물이 생성된다.

FDD용 D88 두 개는 각각 160트랙·1,331,888바이트이며, Main은 트랙 `0x4F` 섹터 5, Game은 트랙 `0x31` 섹터 8에 `IPLD` 및 두 개의 `0xFE` 표식을 포함한다.

정식 산출물 경로는 다음과 같다.

```text
korean_mirrors_tools/Import/ISO/02 MIRR.iso
korean_mirrors_tools/output/disk1main.d88
korean_mirrors_tools/output/disk2game.d88
korean_mirrors_tools/output/Mirrors_Korean_Mirrors_Tools_Full_Build.img
korean_mirrors_tools/output/Mirrors_Korean_Mirrors_Tools_Full_Build.ccd
korean_mirrors_tools/output/Mirrors_Korean_Mirrors_Tools_Full_Build.cue
korean_mirrors_tools/output/Mirrors_Korean_Mirrors_Tools_Full_Build.sub
korean_mirrors_tools/output/Mirrors_Korean_Mirrors_Tools_Full_Build_from_<Japanese|English>_*.xdelta
```

## 9. 관련 문서

- [문서 목차](README.md): 빌드·VWF·원본 분석 문서
- [영문 패치 소스 구조 맵](english-source-structure-map.md): 영문 Ruby 기준선과 CD·BASIC·ASM 구조
- [영문 VWF·문자열·스크립트 실측 분석](english-vwf-script-capacity-analysis.md): 영문판 용량·VWF·스크립트 실측
- [원본 CD 이미지 분석](original-cd-image-analysis.md): 원본 Track 2·플로피 물리 구조
- [영문 패치 출처](english-patch-source.md): 영문 패치의 출처와 재배포 조건
- [`Composite_16x16/README.md`](../Composite_16x16/README.md): 조합 글리프 원본·생성기

## 10. Git에 포함하는 자료

Git에 기록하는 것:

- ASM·BASIC·Python 빌드 소스
- `stringsImportK.csv`와 조합 토큰표
- `Composite_16x16/source`의 글리프 원본·생성기
- 설계·분석·검수 문서
- 영문 패치 소스와 출처 기록

Git에서 제외하는 것:

- 원본 게임 CD 이미지와 추출 Track 2
- 원본·생성 플로피 RAW
- ISO·IMG·CCD·SUB 등 빌드 산출물
- 에뮬레이터 로그와 임시 시험 결과

원본 CloneCD 입력과 빌드 기준 이미지는 로컬에 별도로 준비한다. 전체 빌드 입력과 명령은 [`korean_mirrors_tools/python_tools/README.md`](../korean_mirrors_tools/python_tools/README.md)에 기록한다.
