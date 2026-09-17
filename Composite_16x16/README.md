# 16×16 한글 조합 글리프

이 작업판은 임의로 그린 글리프가 아니라 다음 기존 완성 자료를 입력으로 사용한다.

원본 GitHub 저장소:

- [iolo/8x4x4-fonts](https://github.com/iolo/8x4x4-fonts)

라이선스 파일:

- [LICENSE-OFL.txt](LICENSE-OFL.txt): 원본 폰트와 파생 글리프
- [LICENSE-MIT.txt](LICENSE-MIT.txt): 원본 저장소의 생성·변환 소스 고지
- [../LICENSE-MIT-PROJECT.txt](../LICENSE-MIT-PROJECT.txt): 이 저장소에서 새로 작성한 생성·검증 코드

이 라이선스 고지는 PC-8801 게임 원본, 영문 패치 소스, 한국어 번역문,
게임 이미지 또는 이 저장소의 다른 외부 자료에 적용되지 않는다.

`source/han_dkby.fnt`

이 FNT는 16×16 셀 360개로 구성된다.

- 초성 8벌 × (초성 19개 + 채움 셀)
- 중성 4벌 × (중성 21개 + 채움 셀)
- 종성 4벌 × 종성 28개

같은 `source` 폴더에 조합형 한글 원본 전체를 보관한다.

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

`generate_korean_composite_16x16.py`는 이 원본 셀을 PNG 편집 시트와 RAW로 변환하고, 동일한 8×4×4 규칙으로 시험용 완성 음절을 조합한다. 글리프를 선분으로 새로 그리지 않는다.

`source/asc_serif.fnt`는 ASCII 템플릿 생성에 사용하는 원본이고, 생성된 `source/ascii_8x16_template.fnt`에는 위 한글 글꼴과 짝을 이루는 참조 8×16 ASCII 템플릿(256자, 4,096바이트)을 보관한다. 한글 조합 글리프 소스와 ASCII 소스를 별도 데이터로 유지하며, ASCII 템플릿을 16×16 한글 조합 데이터에 섞지 않는다.
