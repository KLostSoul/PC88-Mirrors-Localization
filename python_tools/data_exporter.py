import csv
import subprocess

from .basic_decompiler import BasicDecompiler
from .floppy import FloppyMan
from .paths import (
    DASM_EXE, EDATA_SCRIPTS, E_FOLDER_ASM, E_FOLDER_BASIC,
    E_FOLDER_FILES, E_FOLDER_STRINGS, ECSV_CDDATA, ECSV_SCRIPTS,
    EXPORT_PATH, ORIGINAL_ISO_DATATRACK,
)
from .util import b2n, csv_hash_array
from .file_streamer import FileStreamer


class DataExporter:
    def __init__(self, filename=ORIGINAL_ISO_DATATRACK):
        self.cd_file = FileStreamer(filename)
        self.string_rows = []

    def read_sectors(self, sector_number, count=1):
        return self.cd_file.read_bytes(count * 2048, sector_number * 2048)

    def read_data(self, offset, size):
        return self.cd_file.read_bytes(size, offset)

    def export_strings(self, disk, script, string_data):
        for line, strings in string_data.items():
            for string_number, text in strings:
                self.string_rows.append([disk, script, line, string_number, text, ""])

    def extract_data(self):
        for entry in csv_hash_array(ECSV_CDDATA):
            raw = self.read_data(int(entry["offset"], 16), int(entry["size"], 16))
            # ``path`` is relative to Export/ in e_cddata.csv.  In particular,
            # floppy entries must land in Export/Floppy so FloppyMan can open
            # them during the following extraction stage.
            output = EXPORT_PATH / entry["path"] / f'{entry["filename"]}.raw'
            output.parent.mkdir(parents=True, exist_ok=True)
            output.write_bytes(raw)
            if entry["type"] == "basic":
                decompiler = BasicDecompiler()
                decompiler.open_memory(raw)
                result = decompiler.decompile()
                (E_FOLDER_BASIC / f'{entry["filename"]}.bas').write_text(result["mData"], encoding="utf-8")
                self.export_strings(entry["filename"], entry["filename"], result["mStrings"])
            elif entry["type"] == "asm":
                asm_name = E_FOLDER_ASM / f'{entry["filename"]}.asm'
                subprocess.run([
                    str(DASM_EXE), str(output), str(asm_name), "--hex:x", "--xref",
                    "--lowercase", "--addr:" + entry["loadAddr"],
                ], check=True)

    def export_floppy_data(self):
        for entry in [row for row in csv_hash_array(ECSV_CDDATA) if row["type"] == "floppy"]:
            manager = FloppyMan()
            manager.open(entry["filename"])
            manager.extract_all()

    def export_basic_scripts(self):
        for entry in csv_hash_array(ECSV_SCRIPTS):
            raw = (E_FOLDER_FILES / entry["disk"] / entry["script"]).read_bytes()
            file_size = b2n(raw[4:6], little_endian=True)
            decompiler = BasicDecompiler()
            decompiler.open_memory(raw[7:7 + file_size])
            result = decompiler.decompile()
            (E_FOLDER_BASIC / entry["script"]).write_text(result["mData"], encoding="utf-8")
            self.export_strings(entry["disk"], entry["script"], result["mStrings"])

    def export(self):
        E_FOLDER_STRINGS.mkdir(parents=True, exist_ok=True)
        self.extract_data()
        self.export_floppy_data()
        self.export_basic_scripts()
        with EDATA_SCRIPTS.open("w", encoding="utf-8-sig", newline="") as handle:
            writer = csv.writer(handle, delimiter=";", quoting=csv.QUOTE_ALL)
            writer.writerow(["disk_num", "script_num", "basic_line", "string_num", "source_text", "translation"])
            writer.writerows(self.string_rows)
