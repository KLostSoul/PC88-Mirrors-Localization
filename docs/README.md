# 문서 목차

문서는 현재 정식 한글 빌드의 기준 문서와, 영문 패치·원본 이미지의 분석 문서로 나뉜다.

## 현재 구현의 기준

- [한글 조합 글리프 빌드 설계](korean-localization-design.md) — 현재 정식 빌드의 입력, 토큰, bank 0 배치, VWF, BASIC/CD 검증 기준
- [한글 조합 글리프 VWF 분석](korean-composite-vwf-analysis.md) — 현재 VWF의 토큰 해석, 8×4×4 조합, bank 0/CD 배치, 출력·호출 경계와 Python 바이트 계약
- [`Composite_16x16/README.md`](../Composite_16x16/README.md) — 16×16 조합 글리프 원본과 생성기, 참고 출처

## 영문 패치와 원본 구조 분석

- [영문 패치 소스 구조 맵](english-source-structure-map.md) — 영문 Ruby 기준 구현, BASIC·ASM·CD 구조
- [영문 VWF·문자열·스크립트 실측 분석](english-vwf-script-capacity-analysis.md) — 영문 VWF와 스크립트 용량의 정적 측정
- [원본 CD 이미지 분석](original-cd-image-analysis.md) — 원본 Track 2와 내장 플로피 구조
- [영문 패치 출처](english-patch-source.md) — 영문 패치 출처와 재배포 조건

## 문서 읽는 순서

1. 현재 구현을 확인하려면 `korean-localization-design.md`를 먼저 읽는다.
2. 영문 패치의 기준 구조가 필요하면 `english-source-structure-map.md`를 읽는다.
3. 원본 이미지와 용량 근거가 필요하면 나머지 분석 문서를 확인한다.

영문 분석 문서에 남아 있는 `vFontNumber`, 3종 영문 폰트, 기존 슬롯 구조는 영문 패치 기준선을 설명하는 내용이다. 현재 한글 정식 빌드의 구현 규칙은 한글 설계 문서의 현재 섹션을 우선한다.
