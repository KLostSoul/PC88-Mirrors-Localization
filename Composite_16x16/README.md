# 16×16 한글 조합 글리프 자료

정식 빌드는 한글 자모 컴포넌트에 `source/han_hanme.fnt`, ASCII에 `source/ascii_8x16_template.fnt`를 사용한다. 한글 음절은 실행 중 8×4×4 프로필 규칙으로 조합한다.

원본 GitHub 저장소:

- [iolo/8x4x4-fonts](https://github.com/iolo/8x4x4-fonts)

라이선스 파일:

- [LICENSE-OFL.txt](LICENSE-OFL.txt): 원본 폰트와 파생 글리프
- [LICENSE-MIT.txt](LICENSE-MIT.txt): 원본 저장소의 생성·변환 소스 고지
- [../LICENSE-MIT-PROJECT.txt](../LICENSE-MIT-PROJECT.txt): 이 저장소에서 새로 작성한 생성·검증 코드

## 정식 입력

한글 조합 입력: `source/han_hanme.fnt`

이 FNT는 16×16 셀 360개로 구성된다.

- 초성 8벌 × (초성 19개 + 채움 셀)
- 중성 4벌 × (중성 21개 + 채움 셀)
- 종성 4벌 × 종성 28개

같은 `source` 폴더에는 아래 한글 조합 글리프 원본을 보관한다. 이 중 정식 빌드 입력은 `han_hanme.fnt`다.

- `han_dkby.fnt`
- `han_hanme.fnt`
- `han_iyagi.fnt`
- `han_pilgi.fnt`
- `han_sam.fnt`
- `han_sans.fnt`
- `han_serif.fnt`
- `han_thin.fnt`
- `han_u4k.fnt`

ASCII 원본도 함께 보관한다.

- `asc_serif.fnt`
- `asc_sans.fnt`
- `asc_thin.fnt`
- `asc_u4k.fnt`

`generate_korean_composite_16x16.py`는 선택한 원본 셀을 PNG 시트와 조합 컴포넌트 자료로 변환한다. 정식 전체 빌더는 이 생성 단계를 거치지 않고 `han_hanme.fnt`와 ASCII 템플릿을 직접 읽는다.

`source/ascii_8x16_template.fnt`는 256자, 4,096바이트의 8×16 ASCII 템플릿이다. 생성기의 기본 ASCII 원본은 `source/asc_serif.fnt`다.
