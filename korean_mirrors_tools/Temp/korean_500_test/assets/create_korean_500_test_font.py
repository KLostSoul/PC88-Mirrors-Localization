"""Convert the temporary 500-cell 8x16 Korean sheet into font raw data.

The sheet is deliberately not a production font.  It repeats the existing
``가나다라`` test glyphs so that glyph index, 8,000-byte loading, and rendering
can be checked independently of final font design.  The output is one
16-byte bitmap per cell in row-major order.
"""

from pathlib import Path

from PIL import Image


WORK_DIR = Path(__file__).resolve().parent
SOURCE = WORK_DIR / "korean_500_test_ganada_repeat.png"
OUTPUT = WORK_DIR / "korean_500_test_ganada_repeat.raw"

CELL_WIDTH = 8
CELL_HEIGHT = 16
COLUMNS = 25
ROWS = 20
GLYPH_COUNT = COLUMNS * ROWS


def main() -> None:
    source = Image.open(SOURCE).convert("RGB")
    if source.size != (COLUMNS * CELL_WIDTH, ROWS * CELL_HEIGHT):
        raise ValueError(f"Expected a 200x320 sheet, got {source.size}")

    raw = bytearray()
    for index in range(GLYPH_COUNT):
        left = (index % COLUMNS) * CELL_WIDTH
        top = (index // COLUMNS) * CELL_HEIGHT
        glyph = source.crop((left, top, left + CELL_WIDTH, top + CELL_HEIGHT))
        for y in range(CELL_HEIGHT):
            value = 0
            for x in range(CELL_WIDTH):
                if glyph.getpixel((x, y)) != (0, 0, 0):
                    value |= 1 << (7 - x)
            raw.append(value)

    OUTPUT.write_bytes(raw)
    print(f"Wrote {OUTPUT} ({len(raw)} bytes, {GLYPH_COUNT} glyphs)")


if __name__ == "__main__":
    main()
