"""Generate the production Korean token table from current build inputs."""

from __future__ import annotations

import csv
from pathlib import Path


TOOLS_ROOT = Path(__file__).resolve().parent.parent
TRANSLATION_TABLE = TOOLS_ROOT / "Import" / "Strings" / "stringsImportK.csv"
HARDCODED_TABLE = TOOLS_ROOT / "Data" / "hardcoded_strings.csv"
BASIC_PATCH_TABLE = TOOLS_ROOT / "Data" / "patchBasic.csv"
OUTPUT = TOOLS_ROOT / "Data" / "korean_token_table.csv"

TOKEN_CONTROL_BYTES = frozenset(
    {
        0x0E, 0x13, 0x8D, 0xEC, 0xF1,
        0x8C, 0xA8, 0xA9, 0xA7, 0xA4, 0xA6, 0xE4,
        0x9F, 0x8A, 0x93, 0x9C, 0x89, 0x8E, 0xDD,
    }
    | set(range(0xE0, 0xE6))
)
TOKEN_LEADS = tuple(
    value for value in range(0x80, 0xE0)
    if value not in TOKEN_CONTROL_BYTES
)[:0x4B]
TRAIL_CONTROL_BYTES = TOKEN_CONTROL_BYTES | {0x5C}
SAFE_TRAILS = tuple(
    value
    for value in tuple(range(0x40, 0x7F)) + tuple(range(0x80, 0xFD))
    if value not in TRAIL_CONTROL_BYTES
)
def _hangul_syllables(text: str) -> set[str]:
    return {
        character
        for character in text
        if "\uac00" <= character <= "\ud7a3"
    }


def load_required_syllables() -> list[str]:
    """Collect every Hangul syllable currently emitted by the build."""
    syllables: set[str] = set()
    with TRANSLATION_TABLE.open("r", encoding="utf-8-sig", newline="") as handle:
        for row in csv.DictReader(handle, delimiter="\t"):
            syllables.update(_hangul_syllables(row.get("translation") or ""))

    for path in (HARDCODED_TABLE, BASIC_PATCH_TABLE):
        if not path.is_file():
            continue
        with path.open("r", encoding="utf-8-sig", newline="") as handle:
            for row in csv.DictReader(handle, delimiter=";"):
                for value in row.values():
                    syllables.update(_hangul_syllables(value or ""))

    if not syllables:
        raise RuntimeError("No Hangul syllables were found in build inputs")
    # Unicode Hangul syllables are arranged in 가나다순 code-point order.
    return sorted(syllables, key=ord)


def build_table(syllables: list[str]) -> list[dict[str, object]]:
    rows: list[dict[str, object]] = []
    for index, character in enumerate(syllables):
        syllable_offset = ord(character) - 0xAC00
        initial_index, remainder = divmod(syllable_offset, 21 * 28)
        medial_index, final_index = divmod(remainder, 28)
        payload = (
            (initial_index << 10)
            | (medial_index << 5)
            | final_index
        )
        # Encode the contiguous Unicode Hangul syllable index with lead and
        # trail alphabets that both exclude BASIC/VWF control bytes.
        # The composition payload is retained as verification metadata only.
        lead_index, trail_index = divmod(syllable_offset, len(SAFE_TRAILS))
        if lead_index >= len(TOKEN_LEADS):
            raise RuntimeError(f"Composition token lead overflow for {character}")
        token_hi = TOKEN_LEADS[lead_index]
        token_lo = SAFE_TRAILS[trail_index]
        token = (token_hi << 8) | token_lo
        rows.append(
            {
                "token_index": index,
                "character": character,
                "unicode": f"U+{ord(character):04X}",
                "token_word": f"0x{token:04X}",
                "token_hi": f"0x{token_hi:02X}",
                "token_lo": f"0x{token_lo:02X}",
                "initial_index": initial_index,
                "medial_index": medial_index,
                "final_index": final_index,
                "composition_payload": f"0x{payload:04X}",
            }
        )

    tokens = [row["token_word"] for row in rows]
    if len(set(tokens)) != len(tokens):
        raise RuntimeError("Generated token values are not unique")
    if any(int(row["token_hi"], 16) in TOKEN_CONTROL_BYTES for row in rows):
        raise RuntimeError("Generated table contains a forbidden lead byte")
    if any(int(row["token_lo"], 16) not in SAFE_TRAILS for row in rows):
        raise RuntimeError("Generated table contains an unsafe trail byte")
    if any(int(row["token_lo"], 16) in TRAIL_CONTROL_BYTES for row in rows):
        raise RuntimeError("Generated table contains a forbidden trail byte")
    if len(SAFE_TRAILS) != 165:
        raise RuntimeError(
            f"Safe trail alphabet must contain 165 values, got {len(SAFE_TRAILS)}"
        )

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
    syllables = load_required_syllables()
    rows = build_table(syllables)
    write_table(rows)
    print(f"Created: {OUTPUT}")
    print(f"Tokens:  {len(rows)}")
    print(f"Range:   {rows[0]['token_word']} - {rows[-1]['token_word']}")
    print("Runtime glyphs: composed from the resident 8x4x4 component table")


if __name__ == "__main__":
    main()
