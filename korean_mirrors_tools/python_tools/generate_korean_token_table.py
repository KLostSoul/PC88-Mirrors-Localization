"""Generate the production Korean token table from the finalized glyph order."""

from __future__ import annotations

import csv
from pathlib import Path


TOOLS_ROOT = Path(__file__).resolve().parent.parent
GLYPH_MAPPING = TOOLS_ROOT / "Data" / "korean_glyphs_20kb_1280_mapping.csv"
TRANSLATION_TABLE = TOOLS_ROOT / "Import" / "Strings" / "stringsImportK.csv"
OUTPUT = TOOLS_ROOT / "Data" / "korean_token_table.csv"

TOKEN_LEADS = tuple(range(0xE0, 0xE6))
SAFE_TRAILS = tuple(range(0x40, 0x7F)) + tuple(range(0x80, 0xFD))
GLYPH_BYTES = 16
EXPECTED_GLYPHS = 1093
FORBIDDEN_TRAILS = set(range(0x00, 0x40)) | {0x7F, 0xFD, 0xFE, 0xFF}


def load_glyphs() -> list[dict[str, str]]:
    with GLYPH_MAPPING.open("r", encoding="utf-8-sig", newline="") as handle:
        rows = [row for row in csv.DictReader(handle) if row["status"] == "used"]

    if len(rows) != EXPECTED_GLYPHS:
        raise RuntimeError(
            f"Expected {EXPECTED_GLYPHS} used glyphs, found {len(rows)}"
        )

    indices = [int(row["index"]) for row in rows]
    if indices != list(range(EXPECTED_GLYPHS)):
        raise RuntimeError("Used glyph indices must be contiguous from 0")

    syllables = [row["syllable"] for row in rows]
    if len(set(syllables)) != len(syllables):
        raise RuntimeError("The glyph mapping contains duplicate syllables")

    return rows


def validate_translation_set(glyphs: list[dict[str, str]]) -> None:
    with TRANSLATION_TABLE.open("r", encoding="utf-8-sig", newline="") as handle:
        translations = csv.DictReader(handle, delimiter="\t")
        translation_syllables = {
            character
            for row in translations
            for character in (row.get("translation") or "")
            if "\uac00" <= character <= "\ud7a3"
        }

    glyph_syllables = {row["syllable"] for row in glyphs}
    missing = translation_syllables - glyph_syllables
    extra = glyph_syllables - translation_syllables
    if missing or extra:
        raise RuntimeError(
            "Glyph mapping and translation syllables differ: "
            f"missing={sorted(missing)!r}, extra={sorted(extra)!r}"
        )


def build_table(glyphs: list[dict[str, str]]) -> list[dict[str, object]]:
    capacity = len(TOKEN_LEADS) * len(SAFE_TRAILS)
    if len(glyphs) > capacity:
        raise RuntimeError(f"Token capacity {capacity} is smaller than glyph count")

    rows: list[dict[str, object]] = []
    for glyph in glyphs:
        index = int(glyph["index"])
        lead_index, trail_index = divmod(index, len(SAFE_TRAILS))
        token_hi = TOKEN_LEADS[lead_index]
        token_lo = SAFE_TRAILS[trail_index]
        token = (token_hi << 8) | token_lo
        offset = index * GLYPH_BYTES

        rows.append(
            {
                "token_index": index,
                "character": glyph["syllable"],
                "unicode": glyph["unicode"],
                "token_word": f"0x{token:04X}",
                "token_hi": f"0x{token_hi:02X}",
                "token_lo": f"0x{token_lo:02X}",
                "glyph_slot": index,
                "glyph_offset": offset,
                "glyph_offset_hex": f"0x{offset:04X}",
                "glyph_bytes": GLYPH_BYTES,
            }
        )

    tokens = [row["token_word"] for row in rows]
    if len(set(tokens)) != len(tokens):
        raise RuntimeError("Generated token values are not unique")
    if any(int(row["token_lo"], 16) in FORBIDDEN_TRAILS for row in rows):
        raise RuntimeError("Generated table contains a forbidden trail byte")

    return rows


def write_table(rows: list[dict[str, object]]) -> None:
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    with OUTPUT.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(
            handle,
            fieldnames=list(rows[0]),
            delimiter=";",
            quoting=csv.QUOTE_ALL,
            lineterminator="\n",
        )
        writer.writeheader()
        writer.writerows(rows)


def main() -> None:
    glyphs = load_glyphs()
    validate_translation_set(glyphs)
    rows = build_table(glyphs)
    write_table(rows)
    print(f"Created: {OUTPUT}")
    print(f"Tokens:  {len(rows)}")
    print(f"Range:   {rows[0]['token_word']} - {rows[-1]['token_word']}")
    print(f"Glyphs:  0x0000 - 0x{int(rows[-1]['glyph_offset']) + GLYPH_BYTES - 1:04X}")


if __name__ == "__main__":
    main()
