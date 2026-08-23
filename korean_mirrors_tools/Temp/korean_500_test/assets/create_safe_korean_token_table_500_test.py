"""Create the 500-entry Korean token table with control-safe byte pairs."""

from __future__ import annotations

import csv
from pathlib import Path


ASSETS = Path(__file__).resolve().parent
OUTPUT = ASSETS / "korean_token_table_500_test.csv"
TOKEN_COUNT = 500
TOKEN_LEADS = (0xE0, 0xE1, 0xE2)
SAFE_TRAILS = tuple(range(0x40, 0x7F)) + tuple(range(0x80, 0xFD))


def main() -> None:
    if len(SAFE_TRAILS) * len(TOKEN_LEADS) < TOKEN_COUNT:
        raise RuntimeError("The safe token range does not contain 500 values")

    rows = []
    for index in range(TOKEN_COUNT):
        lead_index, trail_index = divmod(index, len(SAFE_TRAILS))
        token_hi = TOKEN_LEADS[lead_index]
        token_lo = SAFE_TRAILS[trail_index]
        codepoint = 0xAC00 + index
        rows.append({
            "token_index": index,
            "character": chr(codepoint),
            "unicode": f"U+{codepoint:04X}",
            "token_word": f"0x{token_hi:02X}{token_lo:02X}",
            "token_hi": f"0x{token_hi:02X}",
            "token_lo": f"0x{token_lo:02X}",
            "font_bank": 0,
            "glyph_slot": index,
            "glyph_offset": index * 16,
            "glyph_bytes": 16,
        })

    fieldnames = list(rows[0])
    with OUTPUT.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames, delimiter=";",
                                quoting=csv.QUOTE_ALL, lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)

    used_bytes = {int(row["token_hi"], 16) for row in rows}
    used_bytes.update(int(row["token_lo"], 16) for row in rows)
    forbidden = set(range(0x00, 0x20)) | {0x22, 0x7F, 0xFF}
    if used_bytes & forbidden:
        raise RuntimeError("The generated table contains a forbidden byte")
    print(f"Created {OUTPUT} ({len(rows)} tokens)")
    print(f"First token: {rows[0]['token_word']}")
    print(f"Last token:  {rows[-1]['token_word']}")


if __name__ == "__main__":
    main()
