# PC88 Mirrors Localization

![Mirrors](images/mirrors.PNG)

Mirrors PC-8801 CD 게임의 완성된 한국어 조합 글리프 패치와 전체 빌드 소스다. 전체 게임을 한국어로 패치하며, 빌드 과정에서 CloneCD 이미지와 일본판·영문판용 xdelta 패치를 생성한다.

## 완성 빌드

- 한글 16×16 조합 글리프와 ASCII 8×16 글리프를 사용한다.
- 한글 음절은 2바이트 토큰으로 저장하고, 실행 중 초성·중성·종성 컴포넌트를 조합한다.
- 전체 게임 플레이가 엔딩까지 진행되는 것을 확인했다.
- ISO·CloneCD Track 2의 섹터 데이터와 EDC/ECC를 검사하고, 일본판·영문판 xdelta 복원 결과가 빌드 이미지와 일치하는 것을 확인한다.

## 빌드

저장소 루트에서 실행한다.

```powershell
python -m korean_mirrors_tools.python_tools
```

번역 입력은 `korean_mirrors_tools/Import/Strings/stringsImportK.csv`, 하드코딩 문구는 `korean_mirrors_tools/Data/hardcoded_strings.csv`다. 글리프 입력은 `Composite_16x16/source/han_hanme.fnt`와 `ascii_8x16_template.fnt`다. 원본 CloneCD 이미지 세트는 `korean_mirrors_tools/img/`에 둔다. 일본판·영문판 xdelta 생성에 필요한 기준 이미지와 `xdelta.exe` 경로는 [Python 빌드 도구 안내](korean_mirrors_tools/python_tools/README.md)에 적혀 있다.

주요 산출물은 `korean_mirrors_tools/output/`에 생성된다.

- 완성 CloneCD 세트: `.img`, `.ccd`, `.cue`, `.sub`
- 일본판·영문판용 xdelta: 각각 `.ccd`, `.img`, `.sub` 패치
- 에뮬레이터 FDD용 `disk1main.d88`, `disk2game.d88`

패치 빌드는 [korean_mirrors_tools](korean_mirrors_tools/README.md)에, 조합 글리프 입력과 VWF 구조는 아래 문서에 설명한다.

## 문서

- [문서 목차](docs/README.md)
- [정식 한글 빌드 구조](docs/korean-localization-design.md)
- [한글 조합 글리프 VWF](docs/korean-composite-vwf-analysis.md)
- [영문 패치 소스 구조](docs/english-source-structure-map.md)
- [영문 VWF·문자열·스크립트 실측](docs/english-vwf-script-capacity-analysis.md)
- [원본 CD 이미지 분석](docs/original-cd-image-analysis.md)
- [영문 패치 출처](docs/english-patch-source.md)
- [조합 글리프 자료](Composite_16x16/README.md)

## 라이선스

- 프로젝트에서 새로 작성한 도구: [MIT](LICENSE-MIT-PROJECT.txt)
- 조합 글리프 원본 및 파생 자료: [OFL](Composite_16x16/LICENSE-OFL.txt)
- 조합 글리프 생성·변환 소스의 upstream 고지: [MIT](Composite_16x16/LICENSE-MIT.txt)

원본 게임 이미지와 생성 산출물은 Git에 포함하지 않는다.
