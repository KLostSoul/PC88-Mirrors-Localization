"""Build the new 16x16 Korean composite assets from the selected 8x4x4 source.

The source is the checked-in reference font, not a newly drawn approximation.
Each source glyph is 16 rows x 2 bytes.  The file contains 8 initial sets,
4 medial sets, and 4 final sets, including the filler cells used by the
original 8x4x4 layout.
"""

from __future__ import annotations

import argparse
import csv
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parent
SOURCE_DIR = ROOT / "source"
SOURCE_FNT = SOURCE_DIR / "han_dkby.fnt"
ASCII_SOURCE_FNT = SOURCE_DIR / "asc_serif.fnt"
COMPONENT_DIR = ROOT / "components"
TRIAL_DIR = ROOT / "trial_100"
TRIAL_1093_DIR = ROOT / "trial_1093"
TEST_BUILD_DIR = ROOT / "test_build"
SYLLABLE_MAPPING_CSV = (
    ROOT.parent / "korean_mirrors_tools" / "Data"
    / "korean_token_table.csv"
)

CELL_WIDTH = 16
CELL_HEIGHT = 16
BYTES_PER_GLYPH = CELL_HEIGHT * 2
ASCII_BYTES_PER_GLYPH = CELL_HEIGHT
ASCII_GRID_COLUMNS = 16
ASCII_GRID_ROWS = 16
SHEET_COLUMNS = 10

CHOSEONG = tuple("ㄱㄲㄴㄷㄸㄹㅁㅂㅃㅅㅆㅇㅈㅉㅊㅋㅌㅍㅎ")
JUNGSEONG = tuple("ㅏㅐㅑㅒㅓㅔㅕㅖㅗㅘㅙㅚㅛㅜㅝㅞㅟㅠㅡㅢㅣ")
JONGSEONG = (
    "", "ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ", "ㄷ", "ㄹ", "ㄺ", "ㄻ",
    "ㄼ", "ㄽ", "ㄾ", "ㄿ", "ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ", "ㅆ", "ㅇ",
    "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ",
)

CHO_KIND_WITHOUT_JONG = (0, 0, 0, 0, 0, 0, 0, 0, 1, 3, 3, 3, 1, 2, 4, 4, 4, 2, 1, 3, 0)
CHO_KIND_WITH_JONG = (5, 5, 5, 5, 5, 5, 5, 5, 6, 7, 7, 7, 6, 6, 7, 7, 7, 6, 6, 7, 5)
JUNG_KIND_BY_INITIAL = (0, 1, 2, 3)
JONG_KIND_BY_JUNG = (0, 2, 0, 2, 1, 2, 1, 2, 3, 0, 2, 1, 3, 3, 1, 2, 1, 3, 3, 1, 1)

ROLE_COUNTS = {"initial": 20, "medial": 22, "final": 28}
ROLE_PROFILES = {"initial": 8, "medial": 4, "final": 4}
ROLE_LABELS = {"initial": "초성", "medial": "중성", "final": "종성"}

BANK_SIZE = 0x8000
ASCII_RUNTIME_BASE = 0x1000
KOREAN_COMPONENT_BASE = 0x2000

# The high byte of a Korean token must not be confused with BASIC string
# control bytes or the old E0-E5 token leads.  The token payload still carries
# all 15 composition bits; this table only remaps its upper payload byte to a
# safe lead byte.
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

TRIAL_GLYPHS = tuple(dict.fromkeys("".join((
    "가나다라마바사아자차카타파하까싸",
    "각낙닥락막박삭악작착칵탁팍학깍싹",
    "간난단란만반산안잔찬칸탄판한깐싼",
    "감남담람맘밤삼암잠참캄탐팜함깜쌈",
    "거너더러머버서어저처커터퍼허꺼써",
    "고노도로모보소오조초코토포호꼬쏘",
    "구누두루무부수우주추쿠투푸후꾸쑤",
    "그느드르므브스으즈츠크트프흐끄쓰",
    "기니디리미비시이지치키티피히끼씨",
    "개내대래매배새애재채캐태패해깨쌔",
    "과놔돠롸뫄봐솨와좌촤콰톼퐈화꽈쏴",
    "괘놰돼뢔뫠봬쇄왜좨쵀쾌퇘퐤홰꽤쐐",
))))[:100]


def read_reference_font() -> bytes:
    data = SOURCE_FNT.read_bytes()
    expected = sum(ROLE_COUNTS[role] * ROLE_PROFILES[role] for role in ROLE_COUNTS) * BYTES_PER_GLYPH
    if len(data) != expected:
        raise RuntimeError(f"Unexpected reference size: {len(data)} (expected {expected})")
    return data


def glyph_at(data: bytes, index: int) -> bytes:
    start = index * BYTES_PER_GLYPH
    return data[start:start + BYTES_PER_GLYPH]


def glyph_index(role: str, profile: int, jamo: str) -> int:
    if role == "initial":
        return profile * ROLE_COUNTS[role] + (0 if not jamo else 1 + CHOSEONG.index(jamo))
    if role == "medial":
        return 8 * ROLE_COUNTS["initial"] + profile * ROLE_COUNTS[role] + (0 if not jamo else 1 + JUNGSEONG.index(jamo))
    return (
        8 * ROLE_COUNTS["initial"] + 4 * ROLE_COUNTS["medial"]
        + profile * ROLE_COUNTS[role] + JONGSEONG.index(jamo)
    )


def profile_for(initial: str, medial: str, final: str) -> tuple[int, int, int | None]:
    jung_index = JUNGSEONG.index(medial)
    initial_profile = (
        CHO_KIND_WITH_JONG if final else CHO_KIND_WITHOUT_JONG
    )[jung_index]
    medial_profile = (2 if final else 0) + (0 if initial in {"ㄱ", "ㅋ"} else 1)
    final_profile = JONG_KIND_BY_JUNG[jung_index] if final else None
    return initial_profile, medial_profile, final_profile


def decompose(character: str) -> tuple[str, str, str]:
    if len(character) != 1 or not ("가" <= character <= "힣"):
        raise ValueError(f"Not a modern Hangul syllable: {character!r}")
    offset = ord(character) - 0xAC00
    initial, remainder = divmod(offset, 21 * 28)
    medial, final = divmod(remainder, 28)
    return CHOSEONG[initial], JUNGSEONG[medial], JONGSEONG[final]


def image_from_glyph(glyph: bytes) -> Image.Image:
    image = Image.new("1", (CELL_WIDTH, CELL_HEIGHT), 0)
    for y in range(CELL_HEIGHT):
        row = int.from_bytes(glyph[y * 2:y * 2 + 2], "big")
        for x in range(CELL_WIDTH):
            if row & (1 << (CELL_WIDTH - 1 - x)):
                image.putpixel((x, y), 1)
    return image


def glyph_from_image(image: Image.Image) -> bytes:
    image = image.convert("1")
    if image.size != (CELL_WIDTH, CELL_HEIGHT):
        raise ValueError("Component cells must remain 16x16")
    output = bytearray()
    for y in range(CELL_HEIGHT):
        row = 0
        for x in range(CELL_WIDTH):
            row = (row << 1) | int(bool(image.getpixel((x, y))))
        output.extend(row.to_bytes(2, "big"))
    return bytes(output)


def read_ascii_font() -> bytes:
    data = ASCII_SOURCE_FNT.read_bytes()
    expected = 256 * ASCII_BYTES_PER_GLYPH
    if len(data) != expected:
        raise RuntimeError(f"Unexpected ASCII reference size: {len(data)} (expected {expected})")
    return data


def sheet_for(data: bytes, role: str, profile: int) -> Image.Image:
    count = ROLE_COUNTS[role]
    start = (
        0 if role == "initial" else
        8 * ROLE_COUNTS["initial"] if role == "medial" else
        8 * ROLE_COUNTS["initial"] + 4 * ROLE_COUNTS["medial"]
    )
    index = start + profile * count
    sheet = Image.new("1", (SHEET_COLUMNS * CELL_WIDTH, ((count + 9) // 10) * CELL_HEIGHT), 0)
    for cell in range(count):
        image = image_from_glyph(glyph_at(data, index + cell))
        x0 = (cell % SHEET_COLUMNS) * CELL_WIDTH
        y0 = (cell // SHEET_COLUMNS) * CELL_HEIGHT
        sheet.paste(image, (x0, y0))
    return sheet


def component_glyphs(data: bytes) -> dict[tuple[str, int, str], bytes]:
    result: dict[tuple[str, int, str], bytes] = {}
    for role, profiles in ROLE_PROFILES.items():
        for profile in range(profiles):
            for jamo in (
                ("",) + CHOSEONG if role == "initial" else
                ("",) + JUNGSEONG if role == "medial" else JONGSEONG
            ):
                result[(role, profile, jamo)] = glyph_at(data, glyph_index(role, profile, jamo))
    return result


def compose(character: str, glyphs: dict[tuple[str, int, str], bytes]) -> bytes:
    initial, medial, final = decompose(character)
    ip, mp, fp = profile_for(initial, medial, final)
    layers = [glyphs[("initial", ip, initial)], glyphs[("medial", mp, medial)]]
    if final:
        layers.append(glyphs[("final", fp, final)])
    output = bytearray(BYTES_PER_GLYPH)
    for layer in layers:
        for index, value in enumerate(layer):
            output[index] |= value
    return bytes(output)


def load_existing_1093_syllables() -> list[tuple[int, str]]:
    """Load the legacy 1,093-syllable trial set from the token table."""
    with SYLLABLE_MAPPING_CSV.open("r", encoding="utf-8-sig", newline="") as handle:
        rows = list(csv.DictReader(handle, delimiter=";"))
    used = rows
    if len(used) != 1093:
        raise RuntimeError(
            f"Expected 1,093 used syllables in {SYLLABLE_MAPPING_CSV}, found {len(used)}"
        )
    result: list[tuple[int, str]] = []
    for row in used:
        character = row.get("character", "")
        if len(character) != 1 or not ("가" <= character <= "힣"):
            raise RuntimeError(f"Invalid syllable in existing mapping: {character!r}")
        result.append((int(row["token_index"]), character))
    return result


def write_mapping(data: bytes) -> None:
    path = COMPONENT_DIR / "korean_8x4x4_mapping.csv"
    with path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.writer(handle, lineterminator="\n")
        writer.writerow(("role", "profile", "profile_label", "cell", "jamo", "glyph_index", "offset"))
        index = 0
        for role, profiles in ROLE_PROFILES.items():
            labels = ROLE_LABELS[role]
            jamos = (("",) + CHOSEONG if role == "initial" else
                     ("",) + JUNGSEONG if role == "medial" else JONGSEONG)
            for profile in range(profiles):
                for cell, jamo in enumerate(jamos):
                    absolute = glyph_index(role, profile, jamo)
                    writer.writerow((role, profile + 1, f"{labels} {profile + 1}벌", cell,
                                     jamo or "(무받침)", absolute, absolute * BYTES_PER_GLYPH))
                    index += 1


def build_reference_assets() -> None:
    data = read_reference_font()
    ascii_data = read_ascii_font()
    SOURCE_DIR.mkdir(parents=True, exist_ok=True)
    (SOURCE_DIR / "han_dkby.fnt").write_bytes(data)
    (SOURCE_DIR / "han_dkby.fnt.sha256.txt").write_text(
        __import__("hashlib").sha256(data).hexdigest() + "  han_dkby.fnt\n", encoding="ascii"
    )
    (SOURCE_DIR / "ascii_8x16_template.fnt").write_bytes(ascii_data)
    (SOURCE_DIR / "ascii_8x16_template.fnt.sha256.txt").write_text(
        __import__("hashlib").sha256(ascii_data).hexdigest()
        + "  ascii_8x16_template.fnt\n",
        encoding="ascii",
    )
    COMPONENT_DIR.mkdir(parents=True, exist_ok=True)
    for role, profiles in ROLE_PROFILES.items():
        role_dir = COMPONENT_DIR / role
        role_dir.mkdir(parents=True, exist_ok=True)
        for profile in range(profiles):
            sheet_for(data, role, profile).save(role_dir / f"{role}_{profile + 1:02d}_16x16.png")
    write_mapping(data)
    combined = Image.new("1", (SHEET_COLUMNS * CELL_WIDTH, 36 * CELL_HEIGHT), 0)
    for index in range(360):
        image = image_from_glyph(glyph_at(data, index))
        combined.paste(image, ((index % SHEET_COLUMNS) * CELL_WIDTH, (index // SHEET_COLUMNS) * CELL_HEIGHT))
    combined.save(COMPONENT_DIR / "han_dkby_8x4x4_360_16x16.png")


def build_ascii_glyph_table() -> None:
    """Create a visual 0x00-0xFF table for the 8x16 ASCII template."""
    data = read_ascii_font()
    SOURCE_DIR.mkdir(parents=True, exist_ok=True)
    sheet = Image.new(
        "1",
        (ASCII_GRID_COLUMNS * 8, ASCII_GRID_ROWS * CELL_HEIGHT),
        0,
    )
    mapping_path = SOURCE_DIR / "ascii_8x16_glyph_table.csv"
    with mapping_path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.writer(handle, lineterminator="\n")
        writer.writerow(("index", "hex", "codepoint", "character", "display", "offset"))
        for index in range(256):
            glyph = data[index * ASCII_BYTES_PER_GLYPH:(index + 1) * ASCII_BYTES_PER_GLYPH]
            image = Image.new("1", (8, CELL_HEIGHT), 0)
            for y, row in enumerate(glyph):
                for x in range(8):
                    if row & (1 << (7 - x)):
                        image.putpixel((x, y), 1)
            sheet.paste(image, ((index % ASCII_GRID_COLUMNS) * 8,
                                (index // ASCII_GRID_COLUMNS) * CELL_HEIGHT))
            character = chr(index) if 0x20 <= index <= 0x7E else ""
            display = character if character else f"<{index:02X}>"
            writer.writerow((index, f"0x{index:02X}", f"U+{index:04X}", character,
                             display, index * ASCII_BYTES_PER_GLYPH))
    sheet.save(SOURCE_DIR / "ascii_8x16_glyph_table.png")
    sheet.resize((sheet.width * 4, sheet.height * 4), Image.Resampling.NEAREST).save(
        SOURCE_DIR / "ascii_8x16_glyph_table_preview_4x.png"
    )


def build_trial() -> None:
    data = read_reference_font()
    glyphs = component_glyphs(data)
    build_reference_assets()
    TRIAL_DIR.mkdir(parents=True, exist_ok=True)
    sheet = Image.new("1", (SHEET_COLUMNS * CELL_WIDTH, ((len(TRIAL_GLYPHS) + 9) // 10) * CELL_HEIGHT), 0)
    raw = bytearray()
    with (TRIAL_DIR / "korean_composite_16x16_trial_100_mapping.csv").open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.writer(handle, lineterminator="\n")
        writer.writerow(("index", "syllable", "initial", "medial", "final", "initial_profile", "medial_profile", "final_profile"))
        for index, character in enumerate(TRIAL_GLYPHS):
            glyph = compose(character, glyphs)
            raw.extend(glyph)
            sheet.paste(image_from_glyph(glyph), ((index % 10) * CELL_WIDTH, (index // 10) * CELL_HEIGHT))
            initial, medial, final = decompose(character)
            ip, mp, fp = profile_for(initial, medial, final)
            writer.writerow((index, character, initial, medial, final or "(none)", ip + 1, mp + 1, (fp + 1) if fp is not None else "(none)"))
    sheet.save(TRIAL_DIR / "korean_composite_16x16_trial_100_editable.png")
    sheet.resize((sheet.width * 8, sheet.height * 8), Image.Resampling.NEAREST).save(TRIAL_DIR / "korean_composite_16x16_trial_100_preview_8x.png")
    (TRIAL_DIR / "korean_composite_16x16_trial_100.raw").write_bytes(raw)


def build_1093_trial() -> None:
    """Build the existing 1,093 syllables as a 16x16 trial asset."""
    data = read_reference_font()
    glyphs = component_glyphs(data)
    build_reference_assets()
    syllables = load_existing_1093_syllables()
    TRIAL_1093_DIR.mkdir(parents=True, exist_ok=True)
    columns = 20
    sheet = Image.new(
        "1",
        (columns * CELL_WIDTH, ((len(syllables) + columns - 1) // columns) * CELL_HEIGHT),
        0,
    )
    raw = bytearray()
    mapping_path = TRIAL_1093_DIR / "korean_composite_16x16_1093_mapping.csv"
    with mapping_path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.writer(handle, lineterminator="\n")
        writer.writerow((
            "token_index", "syllable", "unicode", "source_mapping_index",
            "initial", "medial", "final", "initial_profile",
            "medial_profile", "final_profile",
        ))
        for token_index, (source_index, character) in enumerate(syllables):
            glyph = compose(character, glyphs)
            raw.extend(glyph)
            x = (token_index % columns) * CELL_WIDTH
            y = (token_index // columns) * CELL_HEIGHT
            sheet.paste(image_from_glyph(glyph), (x, y))
            initial, medial, final = decompose(character)
            ip, mp, fp = profile_for(initial, medial, final)
            writer.writerow((
                token_index,
                character,
                f"U+{ord(character):04X}",
                source_index,
                initial,
                medial,
                final or "(none)",
                ip + 1,
                mp + 1,
                (fp + 1) if fp is not None else "(none)",
            ))
    sheet.save(TRIAL_1093_DIR / "korean_composite_16x16_1093_editable.png")
    sheet.resize(
        (sheet.width * 4, sheet.height * 4), Image.Resampling.NEAREST
    ).save(TRIAL_1093_DIR / "korean_composite_16x16_1093_preview_4x.png")
    raw_path = TRIAL_1093_DIR / "korean_composite_16x16_1093.raw"
    raw_path.write_bytes(raw)
    expected_size = len(syllables) * BYTES_PER_GLYPH
    if len(raw) != expected_size:
        raise RuntimeError(f"Unexpected 1,093-syllable RAW size: {len(raw)} (expected {expected_size})")


def composition_token_bytes(initial_index: int, medial_index: int, final_index: int) -> tuple[int, int]:
    """Pack one modern-Hangul composition into a safe two-byte token.

    The 15-bit payload is ``initial(5) | medial(5) | final(5)``.  Its upper
    payload byte is remapped through TOKEN_LEADS so that the token cannot use
    the known BASIC string control bytes or the old E0-E5 token range.  The
    two bytes still carry the complete composition; no 1,093-entry runtime
    lookup table is required.
    """
    if not 0 <= initial_index < len(CHOSEONG):
        raise ValueError(f"Invalid choseong index: {initial_index}")
    if not 0 <= medial_index < len(JUNGSEONG):
        raise ValueError(f"Invalid jungseong index: {medial_index}")
    if not 0 <= final_index < len(JONGSEONG):
        raise ValueError(f"Invalid jongseong index: {final_index}")
    payload = (initial_index << 10) | (medial_index << 5) | final_index
    lead_index, trail = divmod(payload, 0x100)
    if lead_index >= len(TOKEN_LEADS):
        raise ValueError(f"Composition lead index out of range: {lead_index}")
    return TOKEN_LEADS[lead_index], trail


def decode_composition_token(token_hi: int, token_lo: int) -> tuple[int, int, int]:
    """Decode a packed token for build-time round-trip verification."""
    try:
        lead_index = TOKEN_LEADS.index(token_hi)
    except ValueError as exc:
        raise ValueError(f"Unsafe or invalid Korean token lead: 0x{token_hi:02X}") from exc
    value = (lead_index << 8) | token_lo
    return value >> 10, (value >> 5) & 0x1F, value & 0x1F


def build_composition_tokens() -> None:
    """Write the 1,093 actual syllables as self-describing two-byte tokens."""
    syllables = load_existing_1093_syllables()
    TEST_BUILD_DIR.mkdir(parents=True, exist_ok=True)
    raw = bytearray()
    rows: list[tuple[int, str, str, str, str, int, int, int, str, str, int]] = []

    for token_index, (source_index, character) in enumerate(syllables):
        initial, medial, final = decompose(character)
        initial_index = CHOSEONG.index(initial)
        medial_index = JUNGSEONG.index(medial)
        final_index = JONGSEONG.index(final)
        token_hi, token_lo = composition_token_bytes(
            initial_index, medial_index, final_index
        )
        decoded = decode_composition_token(token_hi, token_lo)
        expected = (initial_index, medial_index, final_index)
        if decoded != expected:
            raise RuntimeError(
                f"Token round-trip mismatch for {character}: {decoded} != {expected}"
            )
        if token_hi in TOKEN_CONTROL_BYTES:
            raise RuntimeError(f"Token lead collides with control range: 0x{token_hi:02X}")
        raw.extend((token_hi, token_lo))
        rows.append((
            token_index,
            character,
            f"U+{ord(character):04X}",
            initial,
            medial,
            final or "(none)",
            initial_index,
            medial_index,
            final_index,
            f"0x{token_hi:02X}{token_lo:02X}",
            source_index,
        ))

    if len(rows) != 1093 or len(raw) != 1093 * 2:
        raise RuntimeError(f"Unexpected composition token output: {len(rows)} rows, {len(raw)} bytes")
    if len({(raw[i], raw[i + 1]) for i in range(0, len(raw), 2)}) != len(rows):
        raise RuntimeError("Composition token collision detected")

    raw_path = TEST_BUILD_DIR / "korean_composition_tokens_1093.raw"
    raw_path.write_bytes(raw)
    csv_path = TEST_BUILD_DIR / "korean_composition_tokens_1093.csv"
    with csv_path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.writer(handle, lineterminator="\n")
        writer.writerow((
            "token_index", "syllable", "unicode", "initial", "medial", "final",
            "initial_index", "medial_index", "final_index", "token_word",
            "source_mapping_index",
        ))
        writer.writerows(rows)
    (TEST_BUILD_DIR / "korean_composition_token_format.txt").write_text(
        "Korean 2-byte self-describing composition token\n"
        "payload layout: choseong(5) | jungseong(5) | jongseong(5)\n"
        "token lead: safe lead table[payload >> 8]\n"
        "token trail: payload & 0xFF\n"
        "choseong index 0..18; jungseong index 0..20; jongseong index 0..27\n"
        "jongseong index 0 means no final consonant\n"
        "safe lead table entries: %d\n" % len(TOKEN_LEADS)
        + "known control bytes and old E0-E5 leads are excluded\n"
        "raw order: the existing 1,093-syllable CSV order; runtime strings carry the token directly\n",
        encoding="utf-8",
    )


def build_bank0_test() -> None:
    """Pack the new ASCII and 360 components in one bank.

    Korean strings now carry their choseong/jungseong/jongseong values in the
    two-byte token itself, so the old 1,093-entry runtime map is deliberately
    not loaded into expansion RAM.
    """
    ascii_data = read_ascii_font()
    component_data = read_reference_font()
    if len(ascii_data) != 0x1000:
        raise RuntimeError("The 256-entry ASCII template must be exactly 0x1000 bytes")
    if len(component_data) != 0x2D00:
        raise RuntimeError("The 360 component font must be exactly 0x2D00 bytes")

    bank = bytearray(BANK_SIZE)
    bank[ASCII_RUNTIME_BASE:ASCII_RUNTIME_BASE + len(ascii_data)] = ascii_data
    bank[KOREAN_COMPONENT_BASE:KOREAN_COMPONENT_BASE + len(component_data)] = component_data

    TEST_BUILD_DIR.mkdir(parents=True, exist_ok=True)
    (TEST_BUILD_DIR / "physical_bank0_composite_test.raw").write_bytes(bank)
    (TEST_BUILD_DIR / "ascii_256_8x16.raw").write_bytes(ascii_data)
    (TEST_BUILD_DIR / "korean_components_360_16x16.raw").write_bytes(component_data)
    (TEST_BUILD_DIR / "physical_bank0_composite_test.layout.txt").write_text(
        "Physical bank 0 composite font test build\n"
        "0x0000-0x0FFF: reserved for VWF code, variables, and runtime buffers\n"
        "0x1000-0x1FFF: 256 ASCII glyphs, 16 bytes each\n"
        "0x2000-0x4CFF: 360 Korean component glyphs, 32 bytes each\n"
        "0x4D00-0x7FFF: free/reserved; no 1,093-entry runtime map is loaded\n"
        f"ASCII bytes: {len(ascii_data)}\n"
        f"Component bytes: {len(component_data)}\n"
        "Composition map bytes: 0 (composition is carried by each 2-byte token)\n"
        f"Bank size: {len(bank)}\n",
        encoding="utf-8",
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--trial", action="store_true", help="also build the 100-syllable composed trial")
    parser.add_argument(
        "--trial-1093",
        action="store_true",
        help="build the existing 1,093-syllable list as a 16x16 composed trial",
    )
    parser.add_argument(
        "--ascii-glyph-table",
        action="store_true",
        help="create the 0x00-0xFF glyph table for the 8x16 ASCII template",
    )
    parser.add_argument(
        "--bank0-test",
        action="store_true",
        help="build the single-bank composite font data test pack",
    )
    parser.add_argument(
        "--composition-tokens",
        action="store_true",
        help="build the 1,093 self-describing two-byte composition tokens",
    )
    args = parser.parse_args()
    build_reference_assets()
    if args.trial:
        build_trial()
    if args.trial_1093:
        build_1093_trial()
    if args.ascii_glyph_table:
        build_ascii_glyph_table()
    if args.bank0_test:
        build_bank0_test()
    if args.composition_tokens:
        build_composition_tokens()
    print(f"Source: {SOURCE_FNT}")
    print(f"Assets: {COMPONENT_DIR}")


if __name__ == "__main__":
    main()
