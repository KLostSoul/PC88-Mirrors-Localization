# Python tools

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

Run the GUI from `korean_mirrors_tools`:

```powershell
python python_tools/nam_3plane_editor.py
```

On Windows, double-click `python_tools/NAM_3Plane_Editor.bat` to start the
editor. The batch file finds `nam_3plane_editor.py` in its own folder, so the
whole `python_tools` folder can be moved together without changing its path.

For non-GUI verification or batch conversion:

```powershell
python python_tools/nam_3plane_editor.py --split GFX/NAM1.png --output Temp/NAM1_planes
python python_tools/nam_3plane_editor.py --merge Temp/NAM1_planes/NAM1_plane0_1bpp.png Temp/NAM1_planes/NAM1_plane1_1bpp.png Temp/NAM1_planes/NAM1_plane2_1bpp.png --output Temp/NAM1_merged.png
```
