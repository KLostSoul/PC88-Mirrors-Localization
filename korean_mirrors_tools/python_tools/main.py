import re

from .basic_compiler import BasicCompiler
from .basic_decompiler import BasicDecompiler
from .build_clonecd import build_clonecd
from .clonecd import extract_original_track2
from .data_exporter import DataExporter
from .data_importer import DataImporter
from .defines import Const, Paths
from .d88 import write_blank_2hd
from .file_streamer import FileStreamer
from .floppy import FloppyMan
from .generate_korean_token_table import main as generate_korean_token_table
from .img_encoder import ImgEncoder
from .util import Util


_MENU_DIRECT_HARDCODED_ROWS = (
    ("menu_skip_loading_hint", "1300"),
    ("menu_drive2_erase", "1303"),
    ("menu_load_save_slot", "2030"),
    ("menu_reload_correct_data", "3020"),
    ("menu_save_slot_return", "4500"),
    ("menu_escape_return", "4501"),
    ("menu_repeat_toggle", "9040"),
    ("menu_text_speed_values", "9050"),
    ("menu_text_sound_label", "9060"),
    ("menu_text_sound_values", "9060"),
)


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


def _map_basic_strings_to_current_sources(importer: DataImporter) -> None:
    """Map translation rows to the literals in the current BASIC sources.

    The translation input is the sole CSV source.  Menu and intro BASIC files
    contain the English-patched literals, so their literal at each row's
    position is used as the compiler lookup key.
    """
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

    rows_by_line = {}
    for row in importer.stringsData:
        if row["disk_num"] in {Const.Const_Intro, Const.Const_Menu}:
            rows_by_line.setdefault(
                (row["script_num"], row["basic_line"]), []
            ).append(row)

    hardcoded_rows = {
        row["key"]: row
        for row in Util.CSV2hashArray(Paths.IData_HardcodedStrings)
    }
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
            for hardcoded_key in ("menu_drive1_status", "menu_drive2_status"):
                hardcoded = hardcoded_rows[hardcoded_key]
                bridged.append({
                    **source,
                    "source_text": hardcoded["source_text"],
                    "translation": importer.hardcodedStrings[hardcoded_key],
                })
            continue
        if key == (Const.Const_Menu, Const.Const_Menu, "1700", "35"):
            hardcoded = hardcoded_rows["menu_write_names_hint"]
            bridged.append({
                **source,
                "source_text": hardcoded["source_text"],
                "translation": importer.hardcodedStrings["menu_write_names_hint"],
            })
            continue

        row_group = rows_by_line.get(
            (source["script_num"], source["basic_line"]), []
        )
        row_position = next(
            (index for index, row in enumerate(row_group) if row is source),
            None,
        )
        literals = source_literals.get(
            (source["script_num"], source["basic_line"]), []
        )
        if row_position is None or row_position >= len(literals):
            # Some menu rows only call a shared display routine; they do not
            # contain a literal in the current BASIC source. Keep those rows
            # unchanged so hardcoded/shared output handling remains in charge.
            bridged.append(source)
            continue
        source = {**source, "source_text": literals[row_position]}
        bridged.append(source)

    for hardcoded_key, basic_line in _MENU_DIRECT_HARDCODED_ROWS:
        hardcoded = hardcoded_rows.get(hardcoded_key)
        if hardcoded is None:
            raise RuntimeError(f"Missing hardcoded menu string: {hardcoded_key}")
        bridged.append({
            "disk_num": Const.Const_Menu,
            "script_num": Const.Const_Menu,
            "basic_line": basic_line,
            "string_num": f"hardcoded:{hardcoded_key}",
            "source_text": hardcoded["source_text"],
            "background_pic": "",
            "portrait_pic": "",
            "language": "KO",
            "translation": importer.hardcodedStrings[hardcoded_key],
        })

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


def _create_blank_game_disks() -> None:
    write_blank_2hd(Paths.Main_Disk_D88)
    write_blank_2hd(Paths.Game_Disk_D88)


def main():
    opMode = "import"
    if opMode == "export":
        dataExporter = DataExporter(Paths.Original_ISO_DataTrack)
        dataExporter.export()
    elif opMode == "import":
        extract_original_track2()
        # Rebuild the token table from the current translation inputs before
        # any BASIC compiler instance loads it. This adds newly used Hangul
        # syllables automatically and keeps the table in 가나다순 order.
        generate_korean_token_table()
        _install_composite_resources()
        dataImporter = DataImporter(True)
        _map_basic_strings_to_current_sources(dataImporter)
        _apply_repeated_wake_dialog_width(dataImporter)
        dataImporter.importData()
        _create_blank_game_disks()
        build_clonecd()
    elif opMode == "custom":
        pass


if __name__ == "__main__":
    main()
