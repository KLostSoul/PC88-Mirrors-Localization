# Python mirrors_tools 기준 포트

이 디렉터리는 영문 패치 Ruby 소스를 Python으로 1:1 대응시킨 기준 포트다.

## 역할

- Ruby 도구의 처리 순서와 입력·출력 구조를 Python으로 대응한다.
- BASIC 컴파일·디컴파일, ASM·이미지·플로피 처리 결과를 Ruby 기준과 대조한다.
- 영문 패치의 데이터 구조와 빌드 동작을 Python에서 재현할 때 사용한다.

## Ruby와 Python 대응

```text
reference/mirrors_tools/Ruby/       → reference/python_mirrors_tools/python_tools/
BasicCompiler.rb                    → basic_compiler.py
BasicDecompiler.rb                  → basic_decompiler.py
DataExporter.rb                     → data_exporter.py
DataImporter.rb                     → data_importer.py
FileStreamer.rb                     → file_streamer.py
FloppyMan.rb                        → floppy.py
FontGen.rb                          → fontgen.py
ImgEncoder.rb                       → img_encoder.py
ImgDecoder.rb                       → imgdecode.py
Util.rb                             → util.py
```

Python 포트는 Ruby 소스의 파일 순서, 분기 순서, 바이트 순서, Shift-JIS 처리, 출력 배치를 대응 대상으로 삼는다. 따라서 이 폴더의 README는 정식 한글 빌드 설명이 아니라 영문 패치 Ruby 포트의 구조 설명이다.

## 실행

`reference/python_mirrors_tools`에서 실행한다.

```powershell
python -m python_tools
```

`python_tools/main.py`의 현재 기본 모드는 `import`이며, 영문 패치 입력을 처리해 `Import/ISO/02 MIRR.iso`를 생성하는 경로를 호출한다. `Paths`는 이 디렉터리의 `Data`, `Import`, `Export`, `GFX`, `Tools`를 기준으로 계산한다.

## 주요 디렉터리

- `Data/`: 영문 패치의 디스크·스크립트·ASM·그래픽 배치표
- `Import/`: 영문 패치 빌드 입력
- `Export/`: 원본·영문 패치에서 추출한 비교 자료
- `GFX/`: 영문 패치의 폰트·그래픽 입력
- `Tools/`: ASM 컴파일·디컴파일 도구
- `python_tools/`: Ruby 대응 Python 모듈
