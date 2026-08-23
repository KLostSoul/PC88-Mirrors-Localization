"""Build the isolated 500-glyph Korean intro-to-menu test ISO.

Every generated or staged file stays below Temp/korean_500_test.  The normal
Korean work tree remains the English-patch baseline; this script overlays only
the test VWF, 500-glyph font data, and visible BM$ strings in intro/menu.
"""

from __future__ import annotations

import csv
import json
import re
import shutil
import sys
from pathlib import Path


TEST_ROOT = Path(__file__).resolve().parents[1]
KOREAN_ROOT = Path(__file__).resolve().parents[3]
STAGING_ROOT = TEST_ROOT / "staging_korean_500_test"
STAGING_IMPORT = STAGING_ROOT / "Import"
ASSETS = TEST_ROOT / "assets"
BUILD = TEST_ROOT / "build"
COMPARE = TEST_ROOT / "compare"

FONT_RAW = ASSETS / "korean_500_test_ganada_repeat.raw"
VWF_TEST_SOURCE = ASSETS / "vwf_korean_500_test.asm"
INTRO_TEST_SOURCE = ASSETS / "intro_korean_500_test.bas"
MENU_TEST_SOURCE = ASSETS / "menu_korean_500_test.bas"
ISO_TEST_OUTPUT = BUILD / "Mirrors_korean_500_intro_menu_safe_tokens_test.iso"
MANIFEST = COMPARE / "korean_500_intro_menu_safe_tokens_test_manifest.json"

TOKEN_COUNT = 500
TOKEN_PREFIX = "[[K500:"
TOKEN_SUFFIX = "]]"
TOKEN_LEADS = (0xE0, 0xE1, 0xE2)
SAFE_TRAILS = tuple(range(0x40, 0x7F)) + tuple(range(0x80, 0xFD))


def encode_test_token(index: int) -> tuple[int, int]:
    lead_index, trail_index = divmod(index, len(SAFE_TRAILS))
    return TOKEN_LEADS[lead_index], SAFE_TRAILS[trail_index]


def marker(values: list[int]) -> str:
    return '"' + TOKEN_PREFIX + ",".join(f"{value:03X}" for value in values) + TOKEN_SUFFIX + '"'


def display_length(expression: str) -> int:
    """Count literal displayed bytes; dynamic text gets a small test budget."""
    literals = re.findall(r'"([^"]*)"', expression)
    length = sum(len(item) for item in literals)
    return max(1, length // 2)


def replace_bm_assignments(text: str, filename: str, next_token: int,
                           records: list[dict]) -> tuple[str, int]:
    output: list[str] = []
    for line_number, line in enumerate(text.splitlines(keepends=True), start=1):
        cursor = 0
        rebuilt = ""
        while True:
            found = line.find("BM$=", cursor)
            if found < 0:
                rebuilt += line[cursor:]
                break
            rebuilt += line[cursor:found] + "BM$="
            expression_start = found + 4
            pos = expression_start
            in_quotes = False
            while pos < len(line):
                char = line[pos]
                if char == '"':
                    in_quotes = not in_quotes
                elif char == ":" and not in_quotes:
                    break
                elif char in "\r\n" and not in_quotes:
                    break
                pos += 1
            original = line[expression_start:pos]
            glyph_count = display_length(original)
            values = [(next_token + index) % TOKEN_COUNT
                      for index in range(glyph_count)]
            next_token = (next_token + glyph_count) % TOKEN_COUNT
            rebuilt += marker(values)
            records.append({
                "file": filename,
                "source_line": line_number,
                "original_expression": original,
                "korean_token_count": glyph_count,
                "tokens": values,
            })
            cursor = pos
        output.append(rebuilt)
    return "".join(output), next_token


def create_test_basic_sources() -> list[dict]:
    records: list[dict] = []
    next_token = 0
    for source_name, output_path in (("intro.bas", INTRO_TEST_SOURCE),
                                     ("menu.bas", MENU_TEST_SOURCE)):
        source = KOREAN_ROOT / "Import" / "BASIC" / source_name
        changed, next_token = replace_bm_assignments(
            source.read_text(encoding="utf-8"), source_name, next_token, records
        )
        output_path.write_text(changed, encoding="utf-8", newline="")

    covered = {token for record in records for token in record["tokens"]}
    if len(records) == 0:
        raise RuntimeError("No intro/menu BM$ display assignments were found")
    if len(covered) != TOKEN_COUNT:
        raise RuntimeError(
            "Shortened intro/menu strings do not cover all 500 test tokens "
            f"({len(covered)}/500)"
        )
    return records


def install_test_string_compiler() -> None:
    from python_tools.basic_compiler import BasicCompiler

    original = BasicCompiler._compile_string

    def korean_500_test_compile_string(self, token, line, translate_strings):
        payload = token[1:-1]
        if payload.startswith(TOKEN_PREFIX) and payload.endswith(TOKEN_SUFFIX):
            values = payload[len(TOKEN_PREFIX):-len(TOKEN_SUFFIX)].split(",")
            result = bytearray([0x22])
            for value in values:
                index = int(value, 16)
                if not 0 <= index < TOKEN_COUNT:
                    raise ValueError(f"Invalid Korean test token {value} at BASIC line {line}")
                result.extend(encode_test_token(index))
            result.append(0x22)
            return list(result)
        return original(self, token, line, translate_strings)

    BasicCompiler._compile_string = korean_500_test_compile_string


def stage_test_inputs() -> None:
    base_import = KOREAN_ROOT / "Import"
    shutil.copytree(base_import, STAGING_IMPORT, dirs_exist_ok=True)
    (STAGING_IMPORT / "ASM_Source").mkdir(parents=True, exist_ok=True)
    (STAGING_IMPORT / "BASIC").mkdir(parents=True, exist_ok=True)
    (STAGING_IMPORT / "Data").mkdir(parents=True, exist_ok=True)

    shutil.copy2(VWF_TEST_SOURCE, STAGING_IMPORT / "ASM_Source" / "vwf.asm")
    shutil.copy2(INTRO_TEST_SOURCE, STAGING_IMPORT / "BASIC" / "intro.bas")
    shutil.copy2(MENU_TEST_SOURCE, STAGING_IMPORT / "BASIC" / "menu.bas")

    font = FONT_RAW.read_bytes()
    if len(font) != TOKEN_COUNT * 16:
        raise RuntimeError(f"Test font must be 8000 bytes, got {len(font)}")
    (STAGING_IMPORT / "Data" / "korean500_part1.raw").write_bytes(font[:0x1000])
    (STAGING_IMPORT / "Data" / "korean500_part2.raw").write_bytes(
        font[0x1000:] + bytes(0x1000 - len(font[0x1000:]))
    )


def set_test_paths() -> None:
    from python_tools.defines import Paths

    Paths.IMPORT_PATH = STAGING_IMPORT
    Paths.IFolder_Basic = STAGING_IMPORT / "BASIC"
    Paths.IFolder_Data = STAGING_IMPORT / "Data"
    Paths.IFolder_Floppy = STAGING_IMPORT / "Floppy"
    Paths.IFolder_Strings = STAGING_IMPORT / "Strings"
    Paths.IFolder_ISO = STAGING_IMPORT / "ISO"
    Paths.IFolder_Files = STAGING_IMPORT / "Files"
    Paths.IASM_Source = STAGING_IMPORT / "ASM_Source"
    Paths.IASM_Bin = STAGING_IMPORT / "ASM"
    Paths.IData_Scripts = Paths.IFolder_Strings / "stringsImport.csv"
    Paths.ICSV_CDData = KOREAN_ROOT / "Data" / "i_cddata_korean500_test.csv"
    Paths.Patched_ISO_DataTrack = ISO_TEST_OUTPUT


def cd_slot_size(name: str) -> int:
    with (KOREAN_ROOT / "Data" / "e_cddata.csv").open(
        "r", encoding="utf-8-sig", newline=""
    ) as handle:
        for row in csv.DictReader(handle, delimiter=";"):
            if row["filename"] == name:
                return int(row["size"], 16)
    raise RuntimeError(f"CD data slot not found: {name}")


def _compile_size(compiler, source: Path, debug_name: str) -> int:
    compiler.openFile(source)
    return len(compiler.compileSingle(True, debug_name))


def preflight_sizes(importer) -> dict[str, int]:
    from python_tools.basic_compiler import BasicCompiler
    from python_tools.defines import Const, Paths

    intro_strings = [item for item in importer.stringsData
                     if item["disk_num"] == Const.Const_Intro]
    intro_patch = [item for item in importer.basicPatch
                   if item["disk"] == Const.Const_Intro]
    intro_size = _compile_size(
        BasicCompiler(intro_strings, intro_patch),
        Paths.IFolder_Basic / "intro.bas", "intro.bas"
    )
    english_intro_size = _compile_size(
        BasicCompiler(intro_strings, intro_patch),
        KOREAN_ROOT / "Import" / "BASIC" / "intro.bas", "intro.bas"
    )

    menu_strings = [item for item in importer.stringsData
                    if item["disk_num"] == Const.Const_Menu]
    menu_patch = [item for item in importer.basicPatch
                  if item["disk"] == Const.Const_Menu]
    importer.menu_insertNewDiskData(menu_patch)
    menu_size = _compile_size(
        BasicCompiler(menu_strings, menu_patch),
        Paths.IFolder_Basic / "menu.bas", "menu.bas"
    )
    english_menu_patch = [item for item in importer.basicPatch
                          if item["disk"] == Const.Const_Menu]
    importer.menu_insertNewDiskData(english_menu_patch)
    english_menu_size = _compile_size(
        BasicCompiler(menu_strings, english_menu_patch),
        KOREAN_ROOT / "Import" / "BASIC" / "menu.bas", "menu.bas"
    )

    result = {
        "intro": intro_size,
        "menu": menu_size,
        "english_intro": english_intro_size,
        "english_menu": english_menu_size,
    }
    physical_limits = {"intro": 0x800, "menu": cd_slot_size("menu")}
    for name, size, english_size in (
        ("intro", intro_size, english_intro_size),
        ("menu", menu_size, english_menu_size),
    ):
        if size > english_size:
            raise RuntimeError(
                f"Korean test {name} BASIC grew past the English baseline: "
                f"{size} > {english_size} bytes"
            )
        if size > physical_limits[name]:
            raise RuntimeError(
                f"Korean test {name} BASIC exceeds its confirmed CD region: "
                f"{size} > {physical_limits[name]} bytes"
            )
    return result


def compare_with_english_baseline(sizes: dict[str, int]) -> dict[str, int]:
    baseline = KOREAN_ROOT / "Import" / "ISO" / "02 MIRR.iso"
    test_data = ISO_TEST_OUTPUT.read_bytes()
    baseline_data = baseline.read_bytes()
    if len(test_data) != len(baseline_data):
        raise RuntimeError("Test ISO size differs from English baseline")

    allowed = (
        (0x02000, 0x02000 + max(sizes["intro"], sizes["english_intro"])),
        (0x08000, 0x08000 + max(sizes["menu"], sizes["english_menu"])),
        (0x10000, 0x13000),
    )
    differences = 0
    outside = []
    for offset, (left, right) in enumerate(zip(test_data, baseline_data)):
        if left == right:
            continue
        differences += 1
        if not any(start <= offset < end for start, end in allowed):
            outside.append(offset)
            if len(outside) == 16:
                break
    if outside:
        rendered = ", ".join(f"0x{offset:X}" for offset in outside)
        raise RuntimeError("Unexpected differences outside test areas: " + rendered)
    return {"different_bytes_from_english_baseline": differences}


def main() -> None:
    BUILD.mkdir(parents=True, exist_ok=True)
    COMPARE.mkdir(parents=True, exist_ok=True)
    sys.path.insert(0, str(KOREAN_ROOT))

    records = create_test_basic_sources()
    stage_test_inputs()
    install_test_string_compiler()
    set_test_paths()

    from python_tools.data_importer import DataImporter

    importer = DataImporter(True)
    sizes = preflight_sizes(importer)
    importer.importData()
    comparison = compare_with_english_baseline(sizes)

    manifest = {
        "purpose": "500-glyph Korean intro-to-menu test",
        "base_track2": str(KOREAN_ROOT / "Export" / "ISO" / "02 MIRR.iso"),
        "output_iso": str(ISO_TEST_OUTPUT),
        "font_bytes": FONT_RAW.stat().st_size,
        "token_range": "E040-E0FC, E140-E1FC, E240-E2BC",
        "display_assignments": records,
        "compiled_sizes": sizes,
        "cd_slot_sizes": {"intro": cd_slot_size("intro"), "menu": cd_slot_size("menu")},
        "comparison": comparison,
    }
    MANIFEST.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Korean 500 intro/menu test ISO: {ISO_TEST_OUTPUT}")
    print(f"Intro/menu display assignments: {len(records)}")
    print(
        "Compiled sizes: "
        f"intro={sizes['intro']}/{sizes['english_intro']}, "
        f"menu={sizes['menu']}/{sizes['english_menu']}"
    )
    print(f"Different bytes from English baseline: {comparison['different_bytes_from_english_baseline']}")


if __name__ == "__main__":
    main()
