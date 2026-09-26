# Python 빌드 도구

이 디렉터리에는 완성된 정식 한글 조합 글리프 패치를 생성하는 Python 빌드 도구가 있다.

이 디렉터리에서 프로젝트가 새로 작성한 한글 토큰·조합 글리프 연동 코드는
저장소 루트의 [LICENSE-MIT-PROJECT.txt](../../LICENSE-MIT-PROJECT.txt)에 따라
MIT 라이선스로 배포한다. 영문 패치에서 유래한 코드와 외부 게임·폰트·번역
자료는 각 출처의 라이선스와 재배포 조건을 따른다.

## 실행

저장소 루트(`G:\PC88-Mirror`)에서 다음 명령으로 전체 빌드를 실행한다.

```powershell
python -m korean_mirrors_tools.python_tools
```

`main.py`는 현재 `import` 모드로 실행되며 다음 작업을 순서대로 수행한다.

1. `img/`의 일본판 또는 영문판 CloneCD raw Track 2를 선택해 `Export/ISO/02 MIRR.iso`로 추출한다.
2. 번역 입력에 포함된 한글 음절을 수집해 `Data/korean_token_table.csv`를 가나다순으로 재생성한다.
3. `Composite_16x16/source/`의 ASCII 템플릿과 `han_hanme.fnt`를 빌드 입력용 RAW 데이터로 분할한다.
4. 그래픽을 PC-88 형식으로 변환한다.
5. ASM을 컴파일하고 하드코딩 문구를 고정 슬롯에 반영한다.
6. `intro`, `menu`, 전체 NO 스크립트를 번역·컴파일한다.
7. 플로피 파일과 2HD 디스크 데이터를 갱신한다.
8. 추출한 원본 CD 데이터 트랙에 변경 데이터를 반영해 `Import/ISO/02 MIRR.iso`를 생성한다.
9. 에뮬레이터 FDD용 2HD 공디스크 `disk1main.d88`과 `disk2game.d88`를 `output/`에 생성한다.
10. 선택한 원본 이미지에 패치 Track 2를 삽입하고 EDC/ECC를 재생성해 `output/`에 CloneCD 세트와 호환용 CUE를 생성한다.
11. `img/`에서 인식된 각 기준판의 `.ccd`, `.img`, `.sub` xdelta를 만들고, 각 복원 결과의 SHA-256이 완성 빌드 파일과 일치하는지 검사한다.

이미지 파일은 `img/`에 둔다. 판본은 파일명이 아니라 `.img` 전체의 SHA-256으로 구분한다.

| 판본 | `.img` SHA-256 |
| --- | --- |
| 일본판 | `258533b4ac5fd8b16170ddf9509dcf2d6c4a0959bac61e999b3d14c9c0b48d65` |
| 영문판 | `294ee461a2bea8745394c71ca7eec64960a865673d72f8b60557c0a29a9ca7aa` |

각 `.img`와 같은 기본 파일명의 `.ccd`·`.sub`가 필요하다. `.cue`는 선택 사항이며, 없으면 `.ccd`의 트랙 메타데이터에서 호환용 CUE를 생성한다. 한 판본만 있으면 자동 사용하고, 일본판과 영문판이 모두 있으면 이번 한글판 빌드의 입력으로 사용할 이미지 하나를 선택한다. 두 판본이 모두 있으면 xdelta는 두 판본용 모두 생성한다. 등록되지 않은 이미지 해시는 빌드를 중단한다.

```powershell
python -m korean_mirrors_tools.python_tools --source japanese
python -m korean_mirrors_tools.python_tools --source english
```

`--source`를 생략하면 한 세트만 있을 때 자동 선택하며, 두 세트가 모두 있으면 대화형 선택을 요청한다.

### 전체 빌드에 필요한 입력

| 경로 | 파일 |
| --- | --- |
| `korean_mirrors_tools/img/` | 등록된 해시의 일본판 또는 영문판 `.img`와 동일 기본 파일명의 `.ccd`·`.sub` |
| `korean_mirrors_tools/Tools/` | xdelta 생성·검증 도구 `xdelta.exe` |

## 입력과 출력

주요 입력은 다음과 같다.

| 경로 | 용도 |
| --- | --- |
| `Import/Strings/stringsImportK.csv` | 일본어 원문과 한국어 번역 입력 |
| `img/`의 선택 기준 이미지 | 일본판 또는 영문판 원본 CloneCD 이미지 |
| `Data/hardcoded_strings.csv` | BASIC 외부에 직접 저장되는 문구 |
| `Data/patchBasic.csv` | BASIC 행별 패치 |
| `Data/e_scripts.csv` | 스크립트·디스크·분할 정보 |
| `Data/i_cddata.csv` | CD 데이터 트랙 배치 정보 |
| `Data/i_disks.csv` | 플로피와 2HD 디스크 구성 |
| `Data/i_gfx.csv` | 그래픽 입력·주소·디스크 배치 정보 |
| `Import/BASIC/` | 컴파일할 BASIC 원본 |
| `Import/ASM_Source/` | 컴파일할 ASM 원본 |
| `Composite_16x16/source/` | 8×16 ASCII 템플릿과 16×16 한글 조합 글리프 원본 |

주요 생성물은 다음과 같다.

| 경로 | 용도 |
| --- | --- |
| `Data/korean_token_table.csv` | 현재 번역문에 필요한 한글 음절의 토큰·조합 정보 |
| `Import/Data/composite_ascii.raw` | 256슬롯 ASCII 8×16 글리프 데이터 |
| `Import/Data/composite_components_0.raw` | 한글 조합 컴포넌트 청크 0 |
| `Import/Data/composite_components_1.raw` | 한글 조합 컴포넌트 청크 1 |
| `Import/Data/composite_components_2.raw` | 한글 조합 컴포넌트 청크 2 |
| `Import/Files/` | 디스크에 삽입할 BASIC·그래픽 파일 |
| `Import/ASM/` | 컴파일된 ASM RAW와 목록 파일 |
| `Import/ISO/02 MIRR.iso` | 최종 패치 CD 데이터 트랙 |
| `output/disk1main.d88` | FDD1에 넣는 Main용 2HD 공디스크 |
| `output/disk2game.d88` | FDD2에 넣는 Game용 2HD 공디스크 |
| `output/Mirrors_Korean_Mirrors_Tools_Full_Build.cue` | 완성 CloneCD `.img`를 지정하는 호환용 CUE |
| `output/Mirrors_Korean_Mirrors_Tools_Full_Build_from_<Japanese|English>_*.xdelta` | `img/`에서 인식된 판본별 `.ccd`, `.img`, `.sub` 패치 |

### 임시 빌드 파일

빌드 중간 파일과 진단 자료는 `korean_mirrors_tools/temp/`에 생성된다.

- `temp/basic/`: 컴파일된 BASIC의 진단용 디컴파일 덤프
- `temp/editable_asm/`: `asmmain.asm`과 하드코딩 문구 입력을 반영해 생성한 ASM 중간 파일
- `temp/xdelta-verify-*`: xdelta 복원 검증용 임시 디렉터리. 검증이 끝나면 자동 삭제된다.
- `temp/script_editor_build.log`: 에디터에서 빌드를 실행했을 때의 로그

이 파일들은 빌드 과정에서 재생성되며, 원본 입력은 `Import/ASM_Source/`와 `Data/hardcoded_strings.csv`에 있다.

## 모듈 설명

### `main.py` / `__main__.py`

전체 빌드의 진입점과 실행 순서를 관리한다. 조합 글리프 원본을 검증하고
`Import/Data/`에 ASCII RAW와 3개 컴포넌트 청크를 만든다. 메뉴·인트로의 현재
BASIC 문자열을 번역 입력과 연결하고, 반복 대사와 하드코딩 문구에 필요한 정식
패치를 적용한다.

### `generate_korean_token_table.py`

`stringsImportK.csv`, `hardcoded_strings.csv`, `patchBasic.csv`에서 실제로 사용되는
한글 음절을 수집한다. 음절을 가나다순으로 정렬하고, 각 음절의 유니코드 조합값과
안전한 2바이트 조합 토큰을 계산해 `Data/korean_token_table.csv`에 기록한다.
새 번역 음절이 추가되면 전체 빌드 시작 시 토큰표도 다시 생성된다.

### `basic_compiler.py`

N88-BASIC 텍스트를 게임이 읽는 바이트 스트림으로 컴파일한다.

- 한국어 2바이트 조합 토큰과 ASCII를 구분해 인코딩한다.
- 한글은 16픽셀, ASCII는 8픽셀 기준으로 출력 폭을 계산한다.
- 줄바꿈, `LineLimit`, BASIC 제어어·수치·문자열을 처리한다.
- 문자열 안의 따옴표와 역슬래시를 BASIC 스트림 규칙에 맞게 변환한다.
- `splitPoints`가 지정된 스크립트는 0x3000 제한에 맞춰 두 파일로 컴파일한다.
- 토큰표와 폭표의 불일치, 지원하지 않는 문자를 오류로 처리한다.

### `basic_decompiler.py`

PC-88 BASIC 바이너리를 BASIC 소스와 문자열 위치 정보로 역변환한다. 원본 CD에서
스크립트를 추출하거나 컴파일 결과를 바이트 단위로 확인할 때 사용한다.

### `data_importer.py`

정식 패치의 핵심 처리 모듈이다. BASIC 번역, ASM 컴파일, 그래픽 교체, 플로피
파일 갱신, 2HD 디스크 패킹, CD 데이터 트랙 반영을 수행한다. `main.py`가 만든
토큰표·RAW 데이터와 `Data/`의 배치표를 사용한다.

### `d88.py`

PC-8801 2HD 형식의 D88 공디스크를 생성하고, Main·Game 디스크 확인 루틴이 검사하는
각 위치에 `IPLD` 표식을 기록한다. 게임 첫 실행 시 `menu.bas`가 두 디스크를
포맷하고 데이터를 기록한다.

### `data_exporter.py`

원본 CD 데이터 트랙에서 BASIC·ASM·그래픽·플로피 데이터를 추출한다. 추출한
BASIC은 `basic_decompiler.py`로 소스화하고, 문자열 위치를 번역 입력 작성에
사용할 수 있는 형식으로 내보낸다.

### `floppy.py`

PC-88 플로피 RAW/D88 구조를 읽고 파일을 교체·추가한다. 수정된 BASIC과 그래픽을
디스크 이미지에 다시 배치하고, 최종 2HD 데이터로 패킹한다.

### `img_encoder.py`

PNG 그래픽을 PC-88의 압축된 그래픽 데이터로 변환한다. 단색 1-plane과 일반
3-plane 그래픽을 모두 지원하며 `Data/i_gfx.csv`의 주소와 디스크 정보를 사용한다.

### `clonecd.py` / `build_clonecd.py`

`clonecd.py`가 `img/`의 기준판을 자동 선택하거나 사용자에게 선택받는다.
`build_clonecd.py`는 선택한 이미지에 패치 Track 2를 반영하고 섹터 EDC/ECC를
재생성한다. `img/`에서 인식된 각 판본에 대해 `.ccd`, `.img`, `.sub` xdelta를
만들고, 복원 파일의 SHA-256이 정식 빌드 파일과 일치하는지 검사한다.

### `file_streamer.py`

바이트·워드·롱 값의 읽기와 메모리 스트림 처리를 제공하는 공통 저수준 도구다.
CD, BASIC, ASM, 플로피 처리 모듈에서 공유한다.

### `defines.py` / `util.py`

프로젝트 경로, CD·디스크 크기, BASIC 상수와 바이트 변환·CSV 로딩·JIS/Shift-JIS
관련 공통 함수를 정의한다.

## 조합 글리프 처리 기준

한글 완성 음절 RAW를 개별적으로 확장 RAM에 적재하지 않는다. 빌드 시 생성된
토큰표를 BASIC 문자열에 적용하고, 실행 시 조합 VWF가 토큰에서 초성·중성·종성
조합값을 얻어 `Composite_16x16/source/han_hanme.fnt`의 컴포넌트를 조합한다.

- 한글 글리프: 16×16, 전진 폭 16픽셀
- ASCII 글리프: 8×16, 전진 폭 8픽셀
- ASCII 원본: `ascii_8x16_template.fnt`
- 한글 원본: `han_hanme.fnt`
- 토큰표: `Data/korean_token_table.csv`
- 물리 확장 RAM: bank 0 구성

Python 의존성은 다음으로 설치한다.

```powershell
python -m pip install -r korean_mirrors_tools/python_tools/requirements.txt
```

전체 설계와 검증 기준은 [`../../docs/korean-localization-design.md`](../../docs/korean-localization-design.md)를
참조한다.
