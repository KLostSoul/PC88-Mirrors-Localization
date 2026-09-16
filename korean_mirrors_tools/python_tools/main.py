import csv
import re

from .basic_compiler import BasicCompiler
from .basic_decompiler import BasicDecompiler
from .data_exporter import DataExporter
from .data_importer import DataImporter
from .defines import Const, Paths
from .file_streamer import FileStreamer
from .floppy import FloppyMan
from .generate_korean_token_table import main as generate_korean_token_table
from .img_encoder import ImgEncoder
from .util import Util


def _csv_rows(path, delimiter=";"):
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        return list(csv.DictReader(handle, delimiter=delimiter))


def _install_composite_resources() -> None:
    source_dir = Paths.MAIN_PATH.parent / "Composite_16x16" / "source"
    data_dir = Paths.IFolder_Data
    data_dir.mkdir(parents=True, exist_ok=True)

    ascii_data = (source_dir / "ascii_8x16_template.fnt").read_bytes()
    components = (source_dir / "han_dkby.fnt").read_bytes()
    if len(ascii_data) != 0x1000:
        raise RuntimeError(
            f"ASCII template must be 0x1000 bytes, got {len(ascii_data):#x}"
        )
    if len(components) != 0x2D00:
        raise RuntimeError(
            f"Component source must be 0x2D00 bytes, got {len(components):#x}"
        )

    padded = components + bytes(0x6000 - len(components))
    (data_dir / "composite_ascii.raw").write_bytes(ascii_data)
    for index in range(3):
        start = index * 0x2000
        (data_dir / f"composite_components_{index}.raw").write_bytes(
            padded[start:start + 0x2000]
        )


def _bridge_patch_basic_strings(importer: DataImporter) -> None:
    """Map Korean rows onto the English-patched menu and intro sources."""
    bridge_path = Paths.EFolder_Strings / "stringsJapaneseEnglish.csv"
    bridge = _csv_rows(bridge_path)
    bridge_by_key = {
        (
            row["original_disk_num"],
            row["script_num"],
            row["original_basic_line"],
            row["original_string_num"],
        ): row
        for row in bridge
        if row["patch_disk_num"] in {Const.Const_Intro, Const.Const_Menu}
    }

    source_literals = {}
    for script in (Const.Const_Intro, Const.Const_Menu):
        path = Paths.IFolder_Basic / f"{script}.bas"
        for line in path.read_text(encoding="utf-8").splitlines():
            parts = line.split(" ", 1)
            if len(parts) != 2 or not parts[0].isdigit():
                continue
            source_literals[(script, parts[0])] = re.findall(
                r'"(.*?)"', parts[1]
            )

    bridged = []
    for source in importer.stringsData:
        if source["disk_num"] not in {Const.Const_Intro, Const.Const_Menu}:
            bridged.append(source)
            continue

        key = (
            source["disk_num"],
            source["script_num"],
            source["basic_line"],
            source["string_num"],
        )

        if key == (Const.Const_Menu, Const.Const_Menu, "1600", "34"):
            for text, translation in (
                (
                    "The disk in Drive 1 is the Main Disk.",
                    "드라이브 1의 디스크가 메인 디스크입니다.",
                ),
                (
                    "The disk in Drive 2 is the Game Disk.",
                    "드라이브 2의 디스크가 게임 디스크입니다.",
                ),
            ):
                bridged.append({
                    **source,
                    "source_text": text,
                    "translation": translation,
                })
            continue
        if key == (Const.Const_Menu, Const.Const_Menu, "1700", "35"):
            bridged.append({
                **source,
                "source_text": "Don't forget to write their names on them.",
                "translation": "이름을 적어주세요.",
            })
            continue

        bridge_row = bridge_by_key.get(key)
        if bridge_row is not None:
            patch_key = (
                source["script_num"],
                bridge_row["patch_basic_line"],
            )
            literals = source_literals.get(patch_key, [])
            patch_source = bridge_row["english_text"]
            if patch_source not in literals and literals:
                patch_source = literals[0]
            source = {**source, "source_text": patch_source}
        bridged.append(source)

    importer.stringsData = bridged


def _apply_repeated_wake_dialog_width(importer: DataImporter) -> None:
    target = "데이비드: 으아악!! ...하아, 하아..."
    rows = [
        row for row in importer.stringsData
        if row.get("translation") == target
    ]
    if len(rows) != 19:
        raise RuntimeError(
            f"Expected 19 repeated wake-dialog rows, got {len(rows)}"
        )

    existing = {
        (item["disk"], item["script"], int(item["line"])): item
        for item in importer.basicPatch
    }
    old_width = "CMD WIDTH &HF0C2,&H20,7"
    new_width = "CMD WIDTH &HF0C2,&H28,7"

    for row in rows:
        source_path = Paths.EFolder_Basic / row["script_num"]
        source_line = next(
            (
                line for line in source_path.read_text(
                    encoding="utf-8"
                ).splitlines()
                if line.startswith(row["basic_line"] + " ")
            ),
            None,
        )
        if source_line is None:
            raise RuntimeError(
                f"Missing source line {row['script_num']}:{row['basic_line']}"
            )
        if old_width not in source_line:
            raise RuntimeError(
                f"Unexpected wake-dialog width at "
                f"{row['script_num']}:{row['basic_line']}"
            )

        key = (row["disk_num"], row["script_num"], int(row["basic_line"]))
        patched_line = source_line.replace(old_width, new_width, 1)
        patch = existing.get(key)
        if patch is None:
            importer.basicPatch.append({
                "disk": key[0],
                "script": key[1],
                "line": str(key[2]),
                "patchedLine": patched_line.split(" ", 1)[1],
            })
        else:
            patch["patchedLine"] = patched_line.split(" ", 1)[1]


def main():
    opMode = "import"
    if opMode == "export":
        dataExporter = DataExporter(Paths.Original_ISO_DataTrack)
        dataExporter.export()
    elif opMode == "import":
        # Rebuild the token table from the current translation inputs before
        # any BASIC compiler instance loads it. This adds newly used Hangul
        # syllables automatically and keeps the table in 가나다순 order.
        generate_korean_token_table()
        _install_composite_resources()
        dataImporter = DataImporter(True)
        _bridge_patch_basic_strings(dataImporter)
        _apply_repeated_wake_dialog_width(dataImporter)
        dataImporter.importData()
    elif opMode == "custom":
        pass


if __name__ == "__main__":
    main()
