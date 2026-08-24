# Mirrors PC-8801 MC 영문 패치 소스 구조 맵

분석 대상: `reference/mirrors_tools`

이 문서는 영문 패치 소스에 포함된 Ruby 빌드 도구, 데이터 CSV, BASIC/ASM 소스와 현재 작업 폴더의 Python 포팅본을 대조해 작성한 정적 구조 분석표다. 에뮬레이터 실행 결과가 아니라 소스와 주소표를 기준으로 한 분석이다.

## 1. 핵심 결론

영문 패치는 문자열만 교체한 것이 아니다. 다음 네 층을 함께 수정하고, CD Track 2를 다시 구성한다.

1. N88-BASIC 스크립트와 번역 문자열
2. BASIC 확장 및 게임 루틴에 연결되는 Z80 ASM
3. CD 내부의 커스텀 VWF 폰트·폭 테이블·그래픽 데이터
4. CD에 묶여 있는 게임용 플로피 데이터와 저장 시스템

원본 CD의 Track 2 데이터 트랙을 기준으로 작업하며, 최종적으로 수정된 BASIC/ASM/그래픽/플로피 데이터를 다시 Track 2에 삽입한다. CDDA 음악 트랙은 이 빌드 경로의 대상이 아니다.

## 2. 디렉터리별 역할

| 경로 | 역할 |
|---|---|
| `Data/` | CD 데이터 위치, 스크립트 목록, 디스크 배치, 그래픽 교체 목록, BASIC 패치, ASM 빌드 목록 |
| `Export/` | 원본 Track 2에서 추출·디컴파일·디스어셈블한 결과 |
| `Import/` | 패치 빌드에 넣을 BASIC/ASM/문자열/폰트 raw/그래픽 데이터 |
| `GFX/` | 영문 커스텀 폰트와 교체 그래픽 PNG |
| `Ghidra/` | `mir_main.gzf`, `mir_sub.gzf` 정적 분석 프로젝트 |
| `Ruby/` | 추출·컴파일·폰트 변환·플로피 재패킹·CD 재구성 도구 |
| `Tools/` | VASM Z80 어셈블러, BASIC/디스크 관련 외부 도구 |

영문 소스 저장소는 완전한 원본 입력을 포함한 즉시 재현 가능한 빌드 트리는 아니다. 현재 소스에는 `Export/ISO/02 MIRR.iso`와 일부 `Export/Floppy`, `Export/Files`, `Import/Floppy`, `Import/Files`, `Import/ASM` 생성물이 없다. 이 입력·생성물은 원본 CD Track 2 추출 및 빌드 준비 과정에서 별도로 확보해야 한다.

### 2.1 Python 포팅 정적 검증 상태

`python_mirrors_tools/python_tools/`는 Ruby 도구의 실행 대체본이다. Ruby 소스는 원본 구조와 포팅 내용을 대조하는 참조 자료로 유지한다.

- Ruby 핵심 구현 11개(`BasicCompiler`, `DataImporter`, `FloppyMan`, `FontGen` 등)에 Python 대응 구현이 있다.
- 두 트리의 공통 소스·데이터 파일 190개는 SHA-256이 모두 일치한다. 차이는 Ruby 구현 파일, Python 구현 파일과 로컬 생성물뿐이다.
- Python 모듈 15개는 정적 문법 검사를 통과했다.
- 정적 대조에서 `DataExporter.extract_data()`의 출력 경로 오류를 발견·수정했다. Ruby 원본은 CSV의 `path`를 `Export/` 기준으로 해석하지만, 기존 Python 포팅은 이를 `Export/Data/` 기준으로 해석했다. 따라서 플로피가 잘못된 `Export/Data/Floppy/`에 기록될 문제를 `Export/Floppy/`로 수정했다.
- 2026-08-23 Ruby 2.7.4 x64(`chunky_png` 1.4.0, `-EUTF-8`)를 기준으로 Python 빌드 결과를 파일·바이트 단위로 다시 대조했다. Ruby와 Python은 다음 생성물 집합에서 모두 일치했다.

  | 비교 대상 | Python | Ruby | 동일 | 차이 | 누락 |
  |---|---:|---:|---:|---:|---:|
  | ASM | 12 | 12 | 12 | 0 | 0 |
  | `Import/Data` | 8 | 8 | 8 | 0 | 0 |
  | BASIC·이미지 생성 파일 | 130 | 130 | 130 | 0 | 0 |
  | 플로피 RAW | 44 | 44 | 44 | 0 | 0 |
  | `02 MIRR.iso` | 1 | 1 | 1 | 0 | 0 |

- 직전 불일치의 실제 원인은 두 가지였다. `data_importer.py`가 Save 패치의 BASIC 줄 끝 콜론을 누락했고, `basic_compiler.py`가 Ruby가 단일 바이트로 보존하는 원시 제어 바이트를 UTF-8 2바이트로 인코딩했다. 각각 Ruby 소스와 동일하게 수정했다.
- 최종 Python·Ruby `02 MIRR.iso`는 모두 40,550,400바이트이며 SHA-256은 `447d3f23d81897e040919b89b949814977effefe8ac89252dcf4f51553f411c2`로 동일하다. 이 값은 공개 영문 이미지에서 추출한 Track 2 기준 파일과도 일치한다.
- 따라서 현재 영문 빌드 범위에서는 Python 포트가 Ruby 2.7.4 결과와 바이트 단위로 호환된다. 이 검증은 도구와 생성물의 정적·바이너리 검증이며 에뮬레이터 실행 결과를 포함하지 않는다.

이 수정 뒤 원본 Track 2에서 정의된 플로피 44개를 `Export/Floppy/*.raw`에 추출했으며, 각 파일은 CSV의 원본 오프셋·크기 구간과 바이트 단위로 일치한다. 추출 Track 2와 플로피 RAW는 원본 게임 데이터이므로 Git ignore 대상이다.

## 3. 빌드 진입점과 실행 순서

진입점은 `Ruby/main.rb`다. 현재 파일의 `opMode`는 `"import"`로 고정되어 있다.

```text
main.rb
  └─ DataImporter.new(true).importData
       1. 원본 02 MIRR.iso를 메모리로 복사
       2. FontGen으로 script/ui/menu 폰트와 폭 테이블 생성
       3. GFX PNG를 게임 그래픽 데이터로 변환
       4. ASM 소스 컴파일
       5. intro BASIC 삽입
       6. menu BASIC 삽입 및 디스크 선택표 갱신
       7. 미사용 파일 삭제
       8. 모든 시나리오 BASIC 컴파일·번역·패치
       9. 수정 플로피를 작성하고 CD 내부 2HD 영역에 패킹
      10. i_cddata.csv에 지정된 raw/ASM/폰트를 CD 데이터에 삽입
      11. 수정된 02 MIRR.iso 작성
```

`export` 모드에서는 `DataExporter`가 원본 데이터 트랙을 읽고 BASIC을 디컴파일하며 ASM을 디스어셈블한다. `custom` 모드는 테스트용 코드가 남아 있지만 기본 실행 경로는 아니다.

### 3.1 초기 Main/Game 디스크 구성 루틴

초기 실행 시 외부 플로피를 준비하고 CD에서 Main/Game 데이터를 복사하는 흐름 자체는 원본 BASIC에도 존재한다. 원본 `Export/BASIC/menu.bas`는 빈 디스크를 포맷한 뒤 다음 CD 복사를 수행한다.

```basic
1380 COMMON COPY &H00,13381
1480 COMMON COPY &H01,13581
```

영문 패치는 이 절차를 삭제하지 않고 2HD 배치에 맞게 확장했다. 이미 준비된 Main/Game 디스크인지 먼저 검사하고, 빈 디스크일 때만 CD 복사를 수행한다. 복사 위치는 새 2HD 그룹의 시작으로 바뀐다.

```basic
1380 COMMON COPY &H0,13414
1480 COMMON COPY &H1,14030
```

또한 영문판은 별도 Save 디스크를 제거하고 제공된 `disk1main.d88`, `disk2game.d88`를 Drive 1·2에 사용한다. 이 초기화·복사 루틴은 영문판의 2HD 그룹·서브디스크 배치와 Main/Game 디스크 형식에 맞춰져 있으므로, 디스크 배치나 형식을 변경할 때 관련 주소도 함께 바뀌어야 한다.

## 4. CD Track 2 데이터 구조

`Data/e_cddata.csv`의 주소는 CloneCD `.img` 파일의 raw 오프셋이 아니라, 추출된 `02 MIRR.iso` 데이터 트랙 안의 2048바이트 데이터 오프셋이다.

| 데이터 | Track 2 데이터 오프셋 | 크기 | 형식 | 로드 주소 |
|---|---:|---:|---|---:|
| `intro` | `0x2000` | `0x286` | BASIC | - |
| `menu` | `0x8000` | `0x34C6` | BASIC | - |
| `asminit1` | `0x1000` | `0x800` | ASM | `0xD100` |
| `asminit2` | `0x1800` | `0x800` | ASM | `0xD800` |
| `asmsub` | `0x2800` | `0x800` | ASM | `0x7B00` |
| `asmbasic` | `0x3000` | `0x1000` | ASM | `0x9000` |
| `asm3` | `0x4000` | `0x800` | ASM | `0xB310` |
| `asmmain` | `0x4800` | `0x2800` | ASM | `0xA300` |
| `asm5` | `0xA800` | `0x800` | ASM | `0x9D00` |
| `snddat` | `0xF000` | `0x400` | raw | - |
| `main` 플로피 | `0xF800` | `0x64000` | 2D 이미지 | - |
| `disk01`~`disk12` | `0x73800`부터 | 각 `0x64000` | 플로피 이미지 | - |
| `disk22`~`disk52` | CSV 지정 주소 | 각 `0x64000` | 플로피 이미지 | - |

PC-8801 CD 절대 섹터 번호 변환은 `Const::CD_Sector_DataStart = 13350`, 데이터 섹터 크기는 `2048`이다. BASIC의 `COMMON COPY`로 CD 데이터를 읽을 때 `DataImporter#convertCDoffset_toAbsolute`가 다음 방식으로 변환한다.

```text
absolute_sector = data_offset / 0x800 + 13350
```

현재 작업 폴더의 CloneCD `.img`에 직접 쓰려면 2352바이트 raw 섹터의 16바이트 헤더를 고려한 별도 변환이 필요하다. 이 변환은 Ruby 원본 도구의 빌드 경로에 포함되지 않는다.

## 5. 영문 패치가 삽입하는 CD 데이터

`Data/i_cddata.csv`는 기존 데이터 트랙에 덮어쓸 패치 목록이다.

| 데이터 | 오프셋 | 크기 | 의미 |
|---|---:|---:|---|
| `asmsub` | `0x2800` | `0x800` | 수정된 ASM |
| `asmbasic` | `0x3000` | `0x1000` | BASIC 확장 핸들러 |
| `asminit2` | `0x1800` | `0x800` | 초기화 훅 |
| `asmmain` | `0x4800` | `0x2800` | 메인 ASM 수정 |
| `vwf` | `0x10000` | `0x1000` | VWF 출력 엔진 |
| `patch_copy` | `0x3980` | `0x380` | 추가 복사/패치 루틴 |
| `script_bytes` | `0x11000` | `0xC00` 예약 범위 | 스크립트 폰트 글리프 (`FontGen` 실제 raw는 `0x600`) |
| `script_widths` | `0x11F20` | `0x60` | 스크립트 폰트 폭 |
| `ui_bytes` | `0x12000` | `0xC00` 예약 범위 | UI 폰트 글리프 (`FontGen` 실제 raw는 `0x600`) |
| `ui_widths` | `0x12F20` | `0x60` | UI 폰트 폭 |
| `menu_bytes` | `0x13000` | `0xC00` 예약 범위 | 메뉴 폰트 글리프 (`FontGen` 실제 raw는 `0x600`) |
| `menu_widths` | `0x13F20` | `0x60` | 메뉴 폰트 폭 |
| `snddat` | `0xF000` | `0x400` | 사운드 데이터 |

`FontGen.rb`가 현재 생성하는 실제 글리프 파일은 `0x600 = 96 × 16`바이트이며, 폭 테이블은 96바이트다. `i_cddata.csv`의 `0xC00`은 글리프 영역에 허용한 예약·덮어쓰기 범위다. 따라서 CSV 범위와 생성 raw 파일 길이를 같은 값으로 취급하면 안 된다.

현재 CD의 폰트 데이터는 VWF 코드와 함께 시작 시 뱅크 RAM으로 복사된다. 실제 영문 이미지의 초기 BASIC도 `0x10000`의 VWF/스크립트 블록과 `0x12000`의 UI/메뉴 블록을 각각 4개 CD 섹터씩 읽은 뒤 `copyFnt`를 호출한다. 따라서 글리프를 문자 출력 때마다 CD에서 읽는 구조가 아니다.

두 번의 로드는 각각 다음 범위를 담당한다.

| 순서 | Track 2 범위 | CPU RAM 임시 적재 | 확장 RAM 복사 목적지 |
|---:|---|---|---|
| 1 | `0x10000~0x11FFF` | `0xA300~0xC2FF` | `0x0000~0x1FFF` |
| 2 | `0x12000~0x13FFF` | `0xA300~0xC2FF` | `0x2000~0x3FFF` |

두 번째 복사 전에 `copyFnt`의 목적지 피연산자를 `0x2000`으로 바꾼다. 즉 영문판은 `0x4000`바이트를 한 번에 읽는 것이 아니라, 같은 `0x2000`바이트 CPU RAM 임시 버퍼를 재사용하여 확장 RAM 전체 `0x0000~0x3FFF`를 채운다.

### 5.1 확장 RAM의 하드웨어 창과 영문 패치의 실제 사용 범위

PC-88 M 계열의 확장 RAM은 접근 제어가 활성화되면 CPU 주소 `0x0000~0x7FFF`에 한 번에 `0x8000`바이트(32KB)를 매핑할 수 있다. `E2`는 확장 RAM 읽기·쓰기 접근 제어이고 `E3`가 선택 뱅크를 지정한다. 자세한 포트 정의는 [PC-8801 I/O 메모리 맵](https://www.hitchhikr.net/PC-8801%20Memorandum/PC-8801%20IO%20map.html)을 참조한다. 주소 공간 구성은 [PC-8801 Memory map](https://www.hitchhikr.net/PC-8801%20Memorandum/PC-8801%20Memory%20map.html), 기종 사양은 [NEC 공식 PC-8801 사양 페이지](https://support.nec-lavie.jp/support/product/data/spec/cpu/b034-1.html)를 참조한다.

영문 소스의 `E2=0x11`은 뱅크 번호가 아니라 접근 제어 포트에 쓰는 값이다. 영문판은 `E3=0`만 사용하므로 다른 확장 RAM 뱅크를 선택하지 않는다. `copyFnt`는 선택된 뱅크의 `0x0000~0x1FFF`와 `0x2000~0x3FFF`만 채우며, 현재 소스에는 `0x4000~0x7FFF`에 대한 폰트·VWF 복사나 접근이 없다.

따라서 다음을 구분해야 한다.

- 하드웨어가 한 번에 매핑할 수 있는 확장 RAM 창: 32KB
- 영문 패치가 VWF와 폰트에 실제로 사용하는 범위: 16KB
- 영문 패치 기준 미사용 범위: `0x4000~0x7FFF`의 16KB
- 다른 뱅크 사용: 현재 소스에는 없으며, `E3` 선택·로드·복귀 루틴을 추가해야 함

원본 `Export/ASM`에는 `E2/E3` 확장 RAM 뱅크 선택 루틴이 없고 JIS·Kanji ROM 출력 경로를 사용한다. 확장 RAM 의존성은 영문 패치가 VWF와 커스텀 폰트를 추가하면서 생긴 것이다.

## 6. VWF 출력 엔진 구조

핵심 파일은 `Import/ASM_Source/vwf.asm`, `Ruby/FontGen.rb`, `Ruby/BasicCompiler.rb`다.

### 6.1 폰트 뱅크

`vwf.asm`은 `vFontNumber = 0x92DC` 값을 읽고 네 번 왼쪽 시프트해 폰트 뱅크의 0x1000 단위 기준 주소를 만든다.

```text
font_base = vFontNumber << 12
right_margin_base = font_base + 0x0F00
```

현재 소스는 다음 세 폰트를 서로 다른 용도로 생성한다.

| 생성 이름 | PNG | 용도 | CD 영역 |
|---|---|---|---|
| `script` | `b1-8x16_font.png` | 시나리오 대사 | `0x11000` |
| `ui` | `rcopt2-8x16_font.png` | UI/선택지 | `0x12000` |
| `menu` | `menu.png` | 메뉴 | `0x13000` |

이 세 뱅크는 하나의 공유 288자 토큰 표가 아니다. 세 뱅크는 같은 슬롯 번호 범위를 공유하며, `vFontNumber`가 활성 뱅크를 선택한다. 따라서 `0x20`이라는 같은 입력값도 뱅크 1·2·3에서 서로 다른 글리프로 해석될 수 있다. 288은 세 뱅크에 들어 있는 글리프 슬롯의 합계이지, 필요한 고유 문자 토큰 수가 아니다.

### 6.2 토큰 슬롯 수

현재 영문 VWF는 다음 입력 범위를 사용한다.

```text
0x20~0x7F = 96개 슬롯
0x20~0x7E = 표준 출력 ASCII 95개
```

`0x7F` 슬롯은 현재 표준 영문 출력에 필수적이지 않다. 폰트 파일은 주소 계산과 파일 배치를 위해 96번째 슬롯까지 확보하지만, 표준 출력 ASCII는 95개다. 세 뱅크는 동일한 슬롯 번호를 각자 재사용한다.

### 6.3 현재 문자 인덱싱

`convertASCII_toCharAddr`는 다음 구조다.

```text
index = input_byte - 0x20
glyph_address = font_base + index * 0x10
```

`0x20`부터 `0x7F`까지 96개 슬롯을 사용하고, 각 글리프는 16바이트다. `0x0D`는 줄바꿈으로 먼저 처리된다. 글리프를 `vKanjiBuffer`로 복사한 뒤 화면 버퍼에 비트 시프트해 가변 폭으로 합성한다.

### 6.4 폭 처리

`FontGen.rb`는 PNG의 8×16 셀을 읽는다.

- 가로 8픽셀, 세로 16픽셀
- PNG의 두 번째 행부터 6행을 읽음
- 16열 × 6행 = 96글리프
- 글리프 데이터 96 × 16바이트
- 폭 테이블 96바이트
- 첫 폭 값은 `0x02`로 강제

### 6.5 폰트 상주 용량

현재 선택된 확장 RAM 뱅크에서 VWF 코드가 `0x0000~0x0FFF`를 사용하고, 세 폰트 영역은 `0x1000~0x3FFF`의 `0x3000`바이트를 사용한다. 여기서 `0x3000`은 세 폰트 영역을 합친 주소 공간의 크기이며, `copyFnt` 한 번의 복사량이 아니다. 기존 `copyFnt`의 한 번당 복사량은 `0x2000`바이트다. 하드웨어 창 전체는 `0x0000~0x7FFF`의 32KB이므로, 현재 영문 배치 뒤의 `0x4000~0x7FFF` 16KB는 영문 VWF·폰트가 사용하지 않는다.

다른 문자 체계의 용량 계산과 시험 로더 변경 기록은 `docs/korean-localization-design.md`로 분리했다.

## 7. BASIC·문자열 처리

### 7.1 문자열 원천

- `Export/Strings/stringsExport.csv`: 원문 추출 결과
- `Import/Strings/stringsImport.csv`: 원문과 번역문을 연결하는 입력
- `Data/patchBasic.csv`: 특정 BASIC 라인에 대한 직접 수정
- `Export/BASIC/`: 디컴파일된 원본 BASIC
- `Import/BASIC/`: 패치용 BASIC

`BasicCompiler.rb`는 BASIC 토큰을 다시 바이너리로 만들고, 문자열을 번역 CSV의 `source_text`, `basic_line`과 대조해 교체한다. 현재 영문 경로의 줄 길이 계산은 `@widthData[l.ord - 0x20]`처럼 ASCII 인덱스를 직접 사용한다.

Python 포팅을 사용할 때는 이 Ruby 동작을 기준으로 컴파일 결과를 다시 대조해야 한다. 특히 `menu.bas`에 삽입하는 `COMMON COPY`와 `DATA` 줄의 후행 공백은 BASIC 소스상 사소해 보여도 RAW의 줄 길이와 이후 데이터 문자열에 영향을 줄 수 있다.

### 7.1.1 원문·영문 문자열 대조 결과

원문 추출표와 영문 패치 입력표의 전체 대응은 `korean_mirrors_tools/Export/Strings/stringsJapaneseEnglish.csv`에 기록했다.

- 원문 `stringsExport.csv`: 9,720행
- 영문 패치 `stringsImport.csv`: 5,282행
- 1차 대응: 5,278행
- 번역이 있는 대응: 4,979행
- 영문 패치 입력은 있으나 번역이 빈 대응: 299행
- 패치 쪽에 같은 원문이 추가로 반복된 행: 4행(`patch_duplicate`)
- 원문에만 존재하고 영문 패치 입력표에 없는 행: 4,442행(`original_only`)
- 대응되지 않은 패치 행: 0행

대조는 `i_disks.csv`의 스크립트 매핑을 먼저 적용한 뒤 `script_num` 단위로 수행했다. 원문과 패치의 줄 번호·문자열 번호가 달라진 경우에는 원문 순서와 정규화한 원문을 함께 사용해 대응했으며, 동일한 원문이 반복될 때는 줄 번호가 가장 가까운 행을 우선했다. 따라서 단순한 `disk_num + script_num + basic_line + string_num` 완전 일치 방식이 아니다.

비교 시 `−`·`－` 계열 대시 차이와 원문 추출 과정에서 붙은 `:GOSUB 5100` 꼬리를 정규화했다. 이 정규화로 대응된 행의 원문 내용은 모두 일치한다. 원문에만 존재하는 4,442행은 대조 실패가 아니라 원문 추출표에 포함된 제어값·식별자·데이터 문자열·패치가 건드리지 않은 문자열이다. 예를 들어 메뉴의 `n/N/y/Y`, `A:`, `B:`와 `OPN1`, `NAM1`, `TX1` 같은 값이 여기에 포함된다.

기존의 `english_only` 표기는 패치 쪽 중복 행을 실제 영문-only 행처럼 보이게 했으므로 제거했다. 중복 행은 대응 원문 좌표를 반복 기록하고 `patch_duplicate` 및 `patch_extra_occurrence_of_existing_source`로 구분한다.

### 7.2 VWF 호출 연결

`DataImporter#basic_applyVWFHandler`가 각 공통 스크립트에 출력 루틴을 삽입한다.

- `POKE &H92DC,1`: 스크립트 폰트 선택
- `POKE &HB400,1`: 커스텀 출력 경로 사용
- `CMD WIDTH`: 현재 문자열의 출력 주소·폭 설정
- `CMD KANJI`: VWF ASM 루틴 호출
- `ASC(K$)=92`: 백슬래시 기반 줄바꿈/특수 처리
- UI 루틴에서는 `POKE &H92DC,2`로 UI 폰트 선택

### 7.3 스크립트와 디스크 관계

`Data/e_scripts.csv`는 시나리오 스크립트의 순서·분기·저장 허용 여부를 관리한다. `Data/i_disks.csv`는 스크립트를 논리 디스크, 서브 디스크, CD 내부 Track 2 위치와 연결한다.

### 7.4 실행 중 RAM 상주 구조

영문 이미지와 `Import/BASIC/intro.bas`를 대조하면 모든 시나리오가 동시에 RAM에 올라가는 구조가 아님을 확인할 수 있다. 시작 시 `CLEAR ,&H8FFF`가 실행되어 BASIC 프로그램·변수·현재 문자열 영역의 상한을 `0x8FFF`로 설정하고, 이후 `CMD RUN`으로 현재 시나리오 BASIC 하나를 교체 로드한다.

영문 패치에서 확인되는 주요 CPU 주소 영역은 다음과 같다.

| CPU 주소 | 역할 | 상주/사용 방식 |
|---|---|---|
| `0x7B00~0x82FF` | `asmsub` FDC·디스크 서브루틴 | 메인 실행 중 상주 |
| `0x9000~0x98FF` | `asmbasic` BASIC 명령 훅·CD 로더 | 상주. CD 슬롯은 `0x1000`으로 패딩 |
| `0x9980~0x9CFF` | `patch_copy` | 상주 패치 영역 |
| `0x9D00~0xA4FF` | `asm5` 표·초기화 관련 영역 | 로드되며 일부는 데이터 성격 |
| `0xA300~0xCAFF` | `asmmain` 메인 명령·출력·그래픽·사운드 루틴 | 메인 실행 중 상주 |
| `0xB400~0xB41F` | VWF 상태 변수 | 메인 주소공간의 패치/작업 영역 |
| `0xC000` 주변 | 그래픽·파일·압축 데이터 임시 버퍼 | 장면마다 재사용·덮어쓰기 |
| `0xD800~0xDFFF` | `asminit2` 초기화 및 BASIC 연결 훅 | 초기화 후 연결 루틴으로 사용 |
| `0xF000~0xF3FF` | `snddat` 사운드 데이터 | 로드 후 사용 |

부팅 단계에서 `asminit1`은 `0xD100`에, `asm3`은 `0xB310`에 먼저 사용된다. 이후 `asminit2`가 `0xD800`부터 로드되고 `asmmain`이 `0xA300`부터 로드되므로, 이 영역들은 모두 독립적으로 영구 상주하는 것이 아니라 일부가 단계별로 겹쳐 쓰인다. 특히 `asmmain`은 `0xB310`을 포함하므로 초기 `asm3` 영역을 나중에 덮어쓴다.

VWF 코드와 폰트는 일반 BASIC 프로그램 영역이 아니라 포트 `0x31`, `0xE2`, `0xE3`를 통해 접근하는 뱅크 RAM에 복사된다.

```text
뱅크 RAM 0x0000~0x0FFF : VWF 코드와 폭/여백 관련 테이블
뱅크 RAM 0x1000~0x1FFF : 스크립트 폰트 영역
뱅크 RAM 0x2000~0x2FFF : UI 폰트 영역
뱅크 RAM 0x3000~0x3FFF : 메뉴 폰트 영역
```

소스의 `basic_addHeader`는 컴파일된 BASIC 데이터가 12,288바이트(`0x3000`)를 넘을 때 경고한다. 모든 시나리오의 합계가 아니라 현재 `CMD RUN`으로 실행 중인 BASIC 프로그램과 문자열·작업 버퍼가 RAM 점유 단위다.

## 8. 플로피 이미지와 CD 패킹

`FloppyMan.rb`는 원본 플로피의 디렉터리·섹터 맵을 읽고 파일 단위 교체를 수행한다.

- 일반 2D 이미지: `400 × 0x400` 바이트
- 패치용 2HD 이미지: `1200 × 0x400` 바이트
- 수정 파일을 빈 섹터에 배치하고 디렉터리·섹터 맵 갱신
- `DataImporter#createPackFloppyImages`가 여러 논리 디스크를 CD의 2HD 영역에 패킹
- 소스 코드에는 패킹 영역 뒤에 디스크 번호와 `0xC9` 매직 값을 기록하는 코드가 있음

### 8.1 배포 영문 이미지에서 확인한 실제 2HD 배치

배포 이미지 `reference/Mirrors PC-8801 MC English translation v1.0 (updated emu)/Mirrors eng v1.0.img`를 Track 2 논리 데이터로 변환한 뒤, 각 2D 이미지의 디렉터리 위치(`이미지 시작 + 0x63C00`)를 직접 읽어 확인했다. 결과는 `Data/i_disks.csv`의 그룹·서브디스크 구성과 일치한다.

각 그룹은 `0x12C000` 바이트이며, 서브디스크 하나는 `0x64000` 바이트다. `COMMON COPY`에는 그룹 시작 오프셋을 섹터로 변환한 값을 사용한다.

| 그룹 | CD 논리 오프셋 | `COMMON COPY` 절대 섹터 | 서브디스크 0 | 서브디스크 1 | 서브디스크 2 |
|---:|---:|---:|---|---|---|
| 0 | `0x020000` | 13414 | `main` | 빈 공간 | 빈 공간 |
| 1 | `0x154000` | 14030 | `disk01` | 빈 공간 | 빈 공간 |
| 2 | `0x288000` | 14646 | `disk02` | `disk03` | `disk04` |
| 3 | `0x3BC000` | 15262 | `disk05` | `disk06` | `disk07` |
| 4 | `0x4F0000` | 15878 | `disk08` | `disk09` | `disk10` |
| 5 | `0x624000` | 16494 | `disk11` | `disk12` | `disk44` |
| 6 | `0x758000` | 17110 | `disk45` | `disk46` | `disk47` |
| 7 | `0x88C000` | 17726 | `disk48` | `disk49` | `disk50` |
| 8 | `0x9C0000` | 18342 | `disk51` | `disk52` | `disk22` |
| 9 | `0xAF4000` | 18958 | `disk23` | `disk24` | `disk25` |
| 10 | `0xC28000` | 19574 | `disk26` | `disk27` | `disk28` |
| 11 | `0xD5C000` | 20190 | `disk29` | `disk30` | `disk31` |
| 12 | `0xE90000` | 20806 | `disk32` | `disk33` | `disk34` |
| 13 | `0xFC4000` | 21422 | `disk35` | `disk36` | `disk37` |
| 14 | `0x10F8000` | 22038 | `disk38` | `disk39` | `disk40` |
| 15 | `0x122C000` | 22654 | `disk41` | `disk42` | `disk43` |

영문 menu BASIC의 시나리오 표와 실제 디렉터리 파일명을 교차 확인한 대표 결과는 다음과 같다.

| 파일 | 실제 그룹·서브디스크 |
|---|---|
| `NO0` | 1·0 |
| `NO1`, `NO2`, `N3-1` | 2·0 |
| `N3-2`, `NO4` | 2·1 |
| `NO5` | 2·2 |
| `NO21`, `NO22` | 5·2 |
| `NO43`, `NO44` | 8·1 |
| `NO45` | 8·2 |
| `NO84` | 15·1 |
| `END` | 15·2 |

따라서 영문 패치의 실제 실행 흐름은 다음과 같이 확정된다.

```text
menu BASIC의 그룹 선택
  -> COMMON COPY로 해당 그룹의 2HD 데이터 읽기
  -> POKE &H9089로 서브디스크 0/1/2 선택
  -> 선택된 2D 이미지의 디렉터리에서 BASIC 시나리오 실행
```

이 확인으로 영문 소스의 2HD 재패킹 계획과 배포 이미지의 실제 디스크 배치 사이의 불확정 사항은 해소됐다. 시나리오 파일을 다른 그룹으로 옮기려면 menu BASIC의 그룹·서브디스크 표와 CD 복사 주소도 함께 수정해야 한다.

### 8.2 44개 2D 입력과 16개 2HD 출력 그룹

영문 소스의 `e_cddata.csv`는 원본 Track 2의 53개 2D 이미지 전체가 아니라 `main`, `disk01`–`disk12`, `disk22`–`disk52`의 44개만 추출 대상으로 정의한다. 원본 `disk13`–`disk21`은 중복·동일 게임 파일 구성이므로 영문 2HD 재패킹의 독립 입력으로 쓰지 않는다.

`i_disks.csv`의 `disk2HD` 열에 나타나는 `disk13`, `disk14`, `disk15`는 누락된 원본 2D `disk13.raw` 등을 뜻하지 않는다. 이는 새 2HD 출력 그룹 이름이다. 예를 들어 2HD 그룹 `disk13`은 입력 `disk35`, `disk36`, `disk37`을 서브디스크 0, 1, 2에 패킹한다.

영문 패치의 빌드 경로는 44개 2D 입력을 16개 2HD 그룹으로 재패킹하며, 원본 53개 2D 배치를 그대로 복원하지 않는다.

#### 8.3 중복 슬롯의 확장 사용

원본 `disk13`–`disk21`은 정상적인 2D 이미지이지만, `disk15`–`disk21`이 각각 `disk46`–`disk52`와 바이트 단위로 동일하고 `disk13`–`disk14`도 디렉터리와 게임 파일 구성이 같은 중복 보관본이다. 그러므로 영문 패치의 44개 입력 목록에서는 독립 디스크로 취급하지 않는다. 기능적으로는 Track 2의 고정 슬롯을 채우는 중복 영역에 가깝다.

9개 중복 슬롯의 합계는 `0x384000`바이트로 2HD 그룹 3개 분량이다. 이 영역을 다른 용도로 재배치하려면 `e_cddata.csv`의 입력·주소, `i_disks.csv`의 2HD 그룹·서브디스크 배치, CD Track 2 패킹 위치, BASIC의 디스크 선택 및 `COMMON COPY` 주소를 함께 갱신해야 한다.

`Data/i_gfx.csv`의 PNG 그래픽은 먼저 게임 파일 형식으로 변환된 뒤 해당 플로피 파일로 교체되고, 이후 CD 내부 플로피 영역에 다시 패킹된다.

## 9. ASM 구성

| 소스 | 역할 |
|---|---|
| `asmbasic.asm` | BASIC 확장 명령/핸들러 초기화 및 연결 |
| `asminit2.asm` | 초기화 훅과 기존 루틴 연결 |
| `asmmain.asm` | 메인 패치 명령 처리 |
| `asmsub.asm` | 서브루틴/명령 디스패치 |
| `vwf.asm` | VWF 글리프 주소 변환·폭 조회·화면 합성 |
| `patch_copy.asm` | 추가 복사 루틴 패치 |

`Data/asm.csv`는 실제로 컴파일할 ASM과 원본 크기 확인 여부를 지정한다. 원본 ASM 전체가 모두 소스화된 것은 아니며, 변경이 필요한 부분과 새 VWF 엔진 중심으로 관리된다. 나머지 게임 로직은 CD에 들어 있는 원본 바이너리와 BASIC에 남아 있다.

## 10. 분석 상태와 문서 경계

- 원본 `Mirrors.img`에서 Track 2를 `Export/ISO/02 MIRR.iso`로 추출하고, Python `export`로 44개 2D 플로피 RAW를 생성해 원본 구간과 비교했다.
- Ruby 포트 기준으로 Python 컴파일러·디컴파일러·이미지/플로피 패커의 차이를 수정한 뒤, 공개 영문 이미지에서 추출한 데이터 트랙 `02 MIRR.iso`를 Python `export`로 다시 처리했다.
- 재추출 결과는 `python_mirrors_tools/Export/Floppy`의 44개 RAW이며, 각 파일은 409,600바이트다. 이 재추출 결과를 현재 Python 후속 작업의 플로피 입력 기준으로 사용한다.
- Ruby 2.7.4 기준 재빌드와 Python 재빌드의 비교 결과는 ASM 12개, `Import/Data` 8개, BASIC·이미지 생성 파일 130개, 플로피 RAW 44개, `02 MIRR.iso` 1개 모두 동일했다. 전체 비교에서 차이·누락은 0개다.
- 최종 `02 MIRR.iso`의 SHA-256은 양쪽 모두 `447d3f23d81897e040919b89b949814977effefe8ac89252dcf4f51553f411c2`이며, 공개 영문 이미지에서 추출한 Track 2 기준 파일과도 일치한다.
- 이 문서는 영문 패치의 소스·CSV·바이너리 구조를 기록한 정적 분석표이며, 실행 추적이나 에뮬레이터 검증 결과를 포함하지 않는다.
- 한글 토큰, 폰트 용량 계산, VWF 변경, 시험 이미지와 구현 계획은 `docs/korean-localization-design.md`에서 관리한다.
