import ast
import csv
import subprocess

from .basic_compiler import BasicCompiler
from .floppy import FloppyMan
from .fontgen import FontGen
from .img_encoder import ImgEncoder
from .paths import (
    ASM_EXE, ECSV_CDDATA, ECSV_SCRIPTS, E_FOLDER_BASIC, GFX_PATH,
    ICSV_ASM, ICSV_CDDATA,
    ICSV_DISKS, ICSV_GFX, I_FOLDER_DATA, I_FOLDER_FILES, I_FOLDER_FLOPPY,
    I_FOLDER_ISO, I_FOLDER_STRINGS, IASM_BIN, IASM_SOURCE, IMPORT_PATH,
    ORIGINAL_ISO_DATATRACK, PATCHED_ISO_DATATRACK, Const,
)
from .util import csv_hash_array, n2b


def read_tsv(path):
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        return list(csv.DictReader(handle, delimiter="\t"))


def integer(value):
    return int(str(value), 0)


class DataImporter:
    def __init__(self, translate=True):
        from .paths import IDATA_BASICPATCH, IDATA_SCRIPTS

        self.strings_data = read_tsv(IDATA_SCRIPTS)
        self.basic_patch = csv_hash_array(IDATA_BASICPATCH)
        self.disk_data = csv_hash_array(ICSV_DISKS)
        self.script_data = csv_hash_array(ECSV_SCRIPTS)
        self.disk_mans = {}
        self.enable_translation = translate
        self.create_disk_mans()

    def create_disk_mans(self):
        for disk in self.disk_data:
            if disk["disk"] not in self.disk_mans:
                manager = FloppyMan()
                manager.open(disk["disk"])
                self.disk_mans[disk["disk"]] = manager

    @staticmethod
    def add_patch_line(patch, disk, script, line, code):
        patch.append({"disk": disk, "script": script, "line": str(line), "patchedLine": code})

    @staticmethod
    def convert_cd_offset_to_absolute(offset):
        return offset // 0x800 + Const.CD_SECTOR_DATA_START

    def apply_vwf_opening(self, patch, script_data):
        disk, script = script_data["disk"], script_data["script"]
        for line, code in [
            (10010, 'CMD SCREEN 1:GOSUB 2400:BN=&HD007:BM$="This story is a work of fiction.":GOSUB 5100'),
            (5100, 'CMD WIDTH BN,&H40,7:CMD KANJI BM$:BN=BN+&H0640:RETURN'),
            (5120, 'GOSUB 2400:CMD WIDTH &HD504,&H60,7:CMD KANJI BM$'),
            (5130, 'CMD WIDTH &HDF04,&H60,7:CMD KANJI BM2$:GOSUB 5110:RETURN'),
            (5140, 'GOSUB 2400:CMD WIDTH &HD50A,&H60,6:CMD KANJI BM$'),
            (5150, 'CMD WIDTH &HDC90,&H60,7:CMD KANJI BM2$'),
            (5160, 'CMD WIDTH &HE417,&H60,7:CMD KANJI BM3$:GOSUB 5110:RETURN'),
        ]:
            self.add_patch_line(patch, disk, script, line, code)

    def apply_vwf(self, patch, script_data, line=5000):
        disk, script = script_data["disk"], script_data["script"]
        rows = [
            (line + 1, f"POKE &HB401,0:POKE &H92DC,1:BN=&HED93:GOSUB {line + 40}"),
            (line + 5, f"FOR K1=1 TO LEN(BM$):K$=MID$(BM$,K1,1):IF ASC(K$)=92 THEN GOSUB {line + 44}:GOTO {line + 20}:ELSE {line + 10}:"),
            (line + 10, "CMD WIDTH BN,&H60,7:POKE &HB400,1:CMD KANJI K$:KN=KN+1:"),
            (line + 20, f"GOSUB {line + 41}:FOR L=1 TO PEEK(&HE3FF):NEXT:NEXT:RETURN"),
            (line + 40, f"POKE &HB40B,(BN\\256)AND 255:POKE &HB40A,BN AND 255:KN=BN:RETURN"),
            (line + 41, "SZ=PEEK(&HE3FE):IF SZ=0 THEN POLL P,&H0410,&HD214:RETURN"),
            (line + 42, "IF SZ=1 THEN FOR K2=0 TO 2:BEEP 1:BEEP 0:NEXT:RETURN"),
            (line + 43, "RETURN"),
            (line + 44, f"BN=BN+&H50*14:GOSUB {line + 40}:POKE &HB401,0:RETURN"),
            (line + 105, 'BM$=">>>":CMD WIDTH &HF9CD,&H10,7:CMD KANJI BM$'),
            (line + 410, "POKE &H92DC,2:BN=&HEF42:CN=0:FOR I=1 TO CM:CMD WIDTH BN,&H40,7:CMD KANJI CM$(I):BN=BN+&H50*11:NEXT:POKE &H92DC,1"),
            (line + 420, "LINE(110,154+CN*11)-(512,164+CN*11),7,BF,XOR:CN2=CN"),
            (line + 440, "LINE(110,154+CN2*11)-(512,164+CN2*11),7,BF,XOR"),
        ]
        for row, code in rows:
            self.add_patch_line(patch, disk, script, row, code)

    def apply_save_patch(self, patch, script_data, disk_data):
        disk, script = script_data["disk"], script_data["script"]
        rows = [
            (10000, 'BM$="Save game? (press Y or N)":GOSUB 5000'),
            (10040, 'BM$="Select slot (1-9, ESC to exit):":GOSUB 5000'),
            (10049, 'S$=INKEY$:IF S$="" THEN 10049'),
            (10050, 'IF S$=CHR$(27) THEN RETURN'),
            (10060, 'TH=VAL(S$):IF TH>=1 AND TH<=9 THEN 10070:ELSE 10049'),
            (10070, f'POKE &HE302,{disk_data["scriptN"]}:POKE &HE303,{disk_data["scribtSub"]}:'),
            (10080, 'TU=&H31:TU=TU+TH:CMD WRITE &H00,TU,&H01,&HE300'),
            (10090, 'BM$="Done. Press ENTER to continue.":GOSUB 5100:RETURN'),
            (10110, ""), (10120, ""), (10130, ""), (10140, ""), (10150, ""),
        ]
        for row, code in rows:
            self.add_patch_line(patch, disk, script, row, code)

    def apply_cd_switch_patch(self, script_data, patch, disk_data):
        load_data = ast.literal_eval(disk_data["loadLineNum"])
        next_scripts = disk_data["nextScript"].split(",")
        if load_data is None or len(load_data) != len(next_scripts):
            raise ValueError(f"Wrong load data for {script_data['script']}")
        for index, next_script in enumerate(next_scripts):
            next_data = next(item for item in self.disk_data if item["script"] == next_script)
            if next_data["diskNum"] != disk_data["diskNum"]:
                lines = [
                    'ISET X:COMMON FO:GOSUB 5200:BM$="Press any key to start reading data from CD-ROM.":GOSUB 5100',
                    'COMMON STOP:CMD SCREEN 1:BM$="Reading data...":GOSUB 5000',
                    f'COMMON COPY &H01,{self.convert_cd_offset_to_absolute(integer(next_data["trackCD"]))}',
                    f'POKE &H9089,{next_data["subDisk"]}:CMD SET:CMD SCREEN 0:CMD RUN"{next_data["script"]}"',
                ]
            elif next_data["subDisk"] != disk_data["subDisk"]:
                lines = [
                    "ISET X:COMMON FO:GOSUB 5200:FOR I=0 TO 3000:NEXT",
                    "COMMON STOP", "'",
                    f'POKE &H9089,{next_data["subDisk"]}:CMD SET:CMD SCREEN 0:CMD RUN"{next_data["script"]}"',
                ]
            else:
                continue
            for line, code in zip(load_data[index], lines):
                self.add_patch_line(patch, script_data["disk"], script_data["script"], line, code)

    @staticmethod
    def add_header(binary):
        size = len(binary)
        header = [0] + n2b(size, 2, little_endian=False) + [0, 0, (size + 0x3FF) // 0x400, 1]
        print(f"Compiled size: {size}/12288 ({size * 100.0 / 12288:3.2f} %)")
        if size > 12288:
            print("WARNING: exceeding maximum size")
        binary[:0] = header
        return binary

    def translate_basic_scripts(self):
        for script in self.script_data:
            strings = [row for row in self.strings_data if row.get("script_num") == script["script"]]
            basic_patch = [row for row in self.basic_patch if row["script"] == script["script"]]
            disk_data = next(row for row in self.disk_data if row["script"] == script["script"])

            if self.enable_translation and script["script"] == "NO0":
                self.apply_vwf(basic_patch, script, 9000)
                self.apply_vwf_opening(basic_patch, script)
            elif self.enable_translation and script["commonPatch"] == "true":
                self.apply_vwf(basic_patch, script)
            if script["allowSave"] == "true":
                self.apply_save_patch(basic_patch, script, disk_data)
            if disk_data["loadLineNum"] != "-1":
                self.apply_cd_switch_patch(script, basic_patch, disk_data)

            output_dir = I_FOLDER_FILES / script["disk"]
            output_dir.mkdir(parents=True, exist_ok=True)
            compiler = BasicCompiler(strings, basic_patch, self.script_font[0])
            print(f'Compiling BASIC script {script["script"]}')
            compiler.open_file(E_FOLDER_BASIC / script["script"])
            split_points = script.get("splitPoints")
            if not split_points or split_points == "-1":
                binary = self.add_header(compiler.compile_single(self.enable_translation, script["script"]))
                (output_dir / script["script"]).write_bytes(bytes(binary))
            else:
                parts = split_points.split(",")
                binaries = compiler.split_and_compile(script["script"], parts, self.enable_translation)
                for binary in binaries:
                    self.add_header(binary)
                self.disk_mans[script["disk"]].add_replace_file(parts[0], binaries[1])
                (output_dir / script["script"]).write_bytes(bytes(binaries[0]))
                (output_dir / parts[0]).write_bytes(bytes(binaries[1]))

    def create_pack_floppy_images(self):
        for entry in self.disk_data:
            if int(entry["diskNum"]) > 0:
                binary = (I_FOLDER_FILES / entry["disk"] / entry["script"]).read_bytes()
                self.disk_mans[entry["disk"]].add_replace_file(entry["script"], binary)
        for disk, manager in self.disk_mans.items():
            print(f"Writing disk {disk}")
            manager.write_modified()

        grouped = {}
        for entry in self.disk_data:
            grouped.setdefault(entry["disk2HD"], []).append(entry)
        for _, group in sorted(grouped.items()):
            by_disk = {}
            for entry in group:
                by_disk.setdefault(entry["disk"], []).append(entry)
            disk_info = next(iter(by_disk.values()))[0]
            track_cd = integer(disk_info["trackCD"])
            self.cd_image[track_cd:track_cd + Const.DISK_2HD_IMG_SIZE] = b"\0" * Const.DISK_2HD_IMG_SIZE
            self.cd_image[track_cd + 0x12C002] = int(disk_info["diskNum"])
            self.cd_image[track_cd + 0x12C003] = 0xC9
            print(f'Packing 2HD disk {disk_info["disk"]} at offset {track_cd:x}')
            for disk_entries in by_disk.values():
                index = int(disk_entries[0]["subDisk"])
                disk_name = disk_entries[0]["disk"]
                data = (I_FOLDER_FLOPPY / f"{disk_name}.raw").read_bytes()
                offset = track_cd + Const.DISK_IMG_SIZE * index
                self.cd_image[offset:offset + Const.DISK_IMG_SIZE] = data[:Const.DISK_IMG_SIZE]

    def compile_asm(self):
        for asm in csv_hash_array(ICSV_ASM):
            source = IASM_SOURCE / f'{asm["asmFile"]}.asm'
            binary = IASM_BIN / f'{asm["asmFile"]}.raw'
            listing = IASM_BIN / f'{asm["asmFile"]}.lst'
            binary.parent.mkdir(parents=True, exist_ok=True)
            print(f"Compiling ASM file {source}")
            result = subprocess.run([
                str(ASM_EXE), "-L", str(listing), "-Fbin", "-o", str(binary), str(source),
            ], capture_output=True, text=True)
            if result.returncode != 0 or result.stderr:
                raise RuntimeError(f"ASM compilation error for {source}: {result.stderr}")
            if asm["compileOnly"] == "true" and integer(asm["fileSize"]) > 0:
                expected = integer(asm["fileSize"])
                actual = binary.stat().st_size
                if expected != actual:
                    raise ValueError(f"Image size mismatch for {asm['asmFile']}! {expected}(orig) != {actual}(mod)")

    def import_intro_script(self):
        strings = [row for row in self.strings_data if row.get("disk_num") == Const.INTRO]
        patch = [row for row in self.basic_patch if row["disk"] == Const.INTRO]
        compiler = BasicCompiler(strings, patch)
        compiler.open_file(E_FOLDER_BASIC / f"{Const.INTRO}.bas")
        binary = compiler.compile_single(True, f"{Const.INTRO}.bas")
        entry = next(row for row in csv_hash_array(ECSV_CDDATA) if row["filename"] == Const.INTRO)
        offset = integer(entry["offset"])
        self.cd_image[offset:offset + len(binary)] = bytes(binary)

    def menu_insert_new_disk_data(self, data):
        grouped = {}
        for entry in self.disk_data:
            grouped.setdefault(entry["disk2HD"], []).append(entry)
        basic_line = 6010
        on_f_line = ""
        for _, group in sorted(grouped.items()):
            info = group[0]
            if int(info["diskNum"]) > 0:
                self.add_patch_line(data, Const.MENU, Const.MENU, basic_line,
                                    f'COMMON COPY &H1,{self.convert_cd_offset_to_absolute(integer(info["trackCD"]))}:RETURN ')
                on_f_line += f"{basic_line},"
                basic_line += 10
        on_f_line = "ON C GOSUB " + on_f_line[:-1] + ":RETURN "
        self.add_patch_line(data, Const.MENU, Const.MENU, 6000, on_f_line)
        basic_line = 7000
        for script in self.disk_data[1:]:
            if script["scriptN"] != "-1":
                self.add_patch_line(data, Const.MENU, Const.MENU, basic_line,
                                    f'DATA {script["scriptN"]},{script["scribtSub"]}, {script["diskNum"]}, {script["subDisk"]}, {script["script"]} ')
                basic_line += 5

    def import_menu_script(self):
        strings = [row for row in self.strings_data if row.get("disk_num") == Const.MENU]
        patch = [row for row in self.basic_patch if row["disk"] == Const.MENU]
        self.menu_insert_new_disk_data(patch)
        compiler = BasicCompiler(strings, patch)
        compiler.open_file(E_FOLDER_BASIC / f"{Const.MENU}.bas")
        binary = compiler.compile_single(self.enable_translation, "menu.bas")
        (I_FOLDER_DATA / f"{Const.MENU}.raw").parent.mkdir(parents=True, exist_ok=True)
        (I_FOLDER_DATA / f"{Const.MENU}.raw").write_bytes(bytes(binary))
        entry = next(row for row in csv_hash_array(ECSV_CDDATA) if row["filename"] == Const.MENU)
        offset = integer(entry["offset"])
        self.cd_image[offset:offset + len(binary)] = bytes(binary)

    def delete_unused_data(self):
        self.disk_mans["disk52"].free_file("ﾘﾝR")

    def generate_fonts(self):
        from .paths import FONT_MENU, FONT_SCRIPT, FONT_UI
        generator = FontGen()
        generator.generate_vwf(FONT_SCRIPT, "script")
        self.script_font = generator.generate_vwf(FONT_UI, "ui")
        generator.generate_vwf(FONT_MENU, "menu")

    def replace_images(self):
        for gfx in csv_hash_array(ICSV_GFX):
            print(f'Converting image {gfx["origFile"]}')
            encoded = ImgEncoder().img_encode(GFX_PATH / gfx["origFile"], gfx["isMono"] == "true")
            header = n2b(len(encoded), 2, little_endian=False) + n2b(integer(gfx["loadAddr"]), 2, little_endian=False)
            header += [(len(encoded) + 0x3FF) // 0x400, 2]
            encoded = header + encoded
            output = I_FOLDER_FILES / gfx["disk"]
            output.mkdir(parents=True, exist_ok=True)
            (output / gfx["file"]).write_bytes(bytes(encoded))
            self.disk_mans[gfx["disk"]].add_replace_file(gfx["file"], encoded)

    def import_data(self):
        self.cd_image = bytearray(ORIGINAL_ISO_DATATRACK.read_bytes())
        self.generate_fonts()
        self.replace_images()
        self.compile_asm()
        self.import_intro_script()
        self.import_menu_script()
        self.delete_unused_data()
        self.translate_basic_scripts()
        self.create_pack_floppy_images()

        for entry in csv_hash_array(ICSV_CDDATA):
            source_file = IMPORT_PATH / entry["path"] / f'{entry["filename"]}.raw'
            data = source_file.read_bytes()
            offset = integer(entry["offset"])
            limit = integer(entry["size"])
            self.cd_image[offset:offset + min(len(data), limit)] = data[:limit]

        PATCHED_ISO_DATATRACK.parent.mkdir(parents=True, exist_ok=True)
        PATCHED_ISO_DATATRACK.write_bytes(self.cd_image)
