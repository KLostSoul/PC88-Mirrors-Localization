"""Replace all menu display strings with one Korean test-token sequence.

The sequence exercises the low range and the two 500-glyph boundaries:
0, 1, 2, 3, 255, 256, and 499.  It is intentionally a test asset; it keeps
all test logic out of the normal build tools.
"""

from pathlib import Path
import re


MENU = Path(__file__).resolve().parent.parent / "python_mirrors_tools" / "Import" / "BASIC" / "menu.bas"
TOKENS = (
    "CHR$(&H00E0)+CHR$(0)+CHR$(&H00E0)+CHR$(1)+"
    "CHR$(&H00E0)+CHR$(2)+CHR$(&H00E0)+CHR$(3)+"
    "CHR$(&H00E0)+CHR$(&H00FF)+CHR$(&H00E1)+CHR$(0)+"
    "CHR$(&H00E1)+CHR$(&H00F3)"
)


def main() -> None:
    text = MENU.read_text(encoding="utf-8")
    text, replaced = re.subn(r'BM\$="[^"]*"', "BM$=TK$", text)
    if replaced == 0:
        raise RuntimeError("No menu BM$ literals found")

    title_pattern = r"^1190 BM\$=TK\$:(.*)$"
    text, title_replaced = re.subn(title_pattern, rf"1190 TK$={TOKENS}:BM$=TK$:\1", text, count=1, flags=re.MULTILINE)
    if title_replaced != 1:
        raise RuntimeError("Menu title line does not have the expected form")
    MENU.write_text(text, encoding="utf-8")
    print(f"Replaced {replaced} menu display strings with Korean test tokens")


if __name__ == "__main__":
    main()
