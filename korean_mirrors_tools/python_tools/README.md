# Python tools

현재 정식 빌드 진입점은 [`main.py`](main.py)다. 이 디렉터리의 Python 모듈은 BASIC·ASM·그래픽·플로피·ISO 생성에 사용되며, 조합 글리프 원본은 상위 [`Composite_16x16`](../../Composite_16x16/README.md)에서 읽는다. NAM 편집기(`nam_3plane_editor.py`, `NAM_3Plane_Editor.bat`)는 저장소 상위 `Editor/`로 이동했으며 로컬 편집 도구이므로 Git에서 제외한다. 앞으로 추가하는 모든 에디터도 `Editor/`에 저장한다.

This directory contains manually written Python counterparts for every Ruby
tool in reference/mirrors_tools/Ruby.

The port preserves the Ruby source's file order, branch order, byte order,
Shift-JIS handling, and output layout. It does not start an emulator.

## NAM 3-plane editor

`nam_3plane_editor.py` edits the six `NAM*.png` graphics without changing the
game's 3-plane storage rule. It splits one indexed NAM PNG into Plane 0, 1,
and 2 1bpp PNGs, lets the user edit them, and merges the three bit values back
into one indexed PNG for the existing image importer.

The editor supports undo (`Ctrl+Z`), redo (`Ctrl+Y` or `Ctrl+Shift+Z`), and a
full reset to the state that was loaded into the editor. One mouse drag is one
undoable edit.

Run the GUI from the repository root:

```powershell
python Editor/nam_3plane_editor.py
```

On Windows, double-click `Editor/NAM_3Plane_Editor.bat` to start the editor.
The batch file finds `nam_3plane_editor.py` in its own folder.

For non-GUI verification or batch conversion:

```powershell
python Editor/nam_3plane_editor.py --split korean_mirrors_tools/GFX/NAM1.png --output Temp/NAM1_planes
python Editor/nam_3plane_editor.py --merge Temp/NAM1_planes/NAM1_plane0_1bpp.png Temp/NAM1_planes/NAM1_plane1_1bpp.png Temp/NAM1_planes/NAM1_plane2_1bpp.png --output Temp/NAM1_merged.png
```
