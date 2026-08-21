# Python build tools

This directory is the Python replacement for the Ruby build tools in
`reference/mirrors_tools/Ruby`. The reference tree is not modified.

The source tree used by the Python tools is `python_mirrors_tools` by default.
Set `MIRRORS_TOOLS_ROOT` to point at another copy when comparing builds.

```powershell
python -m python_tools fonts
python -m python_tools export
python -m python_tools import

To compare artifacts from two builds:

```powershell
python -m python_tools.verify .\ruby-output .\python-output Import\Data\script_bytes.raw
```
```

`fonts` only converts the three PNG atlases to RAW data. It does not read a CD
image, start an emulator, or alter the original image. `export` and `import`
operate on the extracted data track and disk files expected by the original
toolchain.

Before `export`, `Export/ISO/02 MIRR.iso` must exist. Before `import`, the
exported BASIC files and `Export/Floppy/*.raw` files must also exist. The
command performs a preflight check and stops before writing anything when
those inputs are missing.

The Python implementation is intended to be checked against the Ruby output
byte-for-byte before the Ruby tools are retired. VASM remains the assembler;
Ruby is not needed by the Python commands.
