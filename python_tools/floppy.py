from pathlib import Path

from .file_streamer import FileStreamer
from .paths import Const, E_FOLDER_FLOPPY, E_FOLDER_FILES, I_FOLDER_FLOPPY


class FloppyMan:
    DIR_POS = 399 * Const.DISK_SECTOR_SIZE
    FT_REPLACE = 1
    FT_ADD = 2

    def __init__(self):
        self.files = []
        self.modified_files = {}
        self.disk_name = ""
        self.floppy_file = None
        self.write_sector = 0

    @staticmethod
    def _sjis(value):
        return value.encode("cp932", errors="replace")

    def free_file(self, name):
        if isinstance(name, str):
            name = self._sjis(name)
        original_index = next((i for i, entry in enumerate(self.files)
                               if entry["file_name"] == name), None)
        if original_index is None:
            raise FileNotFoundError(f"File not found: {name!r}")
        print(f"Deleting file {name!r}...")
        self.files.pop(original_index)

    def find_free_sectors(self, count):
        mapping = [0xFF] * 400
        mapping[0] = 0xFE
        mapping[0x18B] = 0xFE
        for entry in self.files:
            for sector in entry["sectors"]:
                mapping[sector] = entry["index"]
        result = []
        next_index = 0
        for _ in range(count):
            try:
                index = mapping.index(0xFF, next_index)
            except ValueError:
                break
            result.append(index)
            next_index = index
        return result

    def add_replace_file(self, filename, data):
        filename_bytes = self._sjis(filename)
        original_index = next((i for i, entry in enumerate(self.files)
                               if entry["file_name"] == filename_bytes), None)
        action = "Adding" if original_index is None else "Replacing"
        print(f"{action} {filename_bytes!r} in disk {self.disk_name}...")
        self.modified_files[filename_bytes] = bytes(data)
        if original_index is not None:
            self.free_file(filename_bytes)

    @staticmethod
    def _write_filename(filename, index, directory):
        for position in range(4):
            directory[index * 4 + position] = filename[position] if position < len(filename) else 0

    def _write_mod_sector(self, disk, sector, data):
        if self.write_sector >= 400:
            raise RuntimeError("Out of disk space")
        start = Const.DISK_SECTOR_SIZE * sector
        chunk = data[:Const.DISK_SECTOR_SIZE]
        disk[start:start + len(chunk)] = chunk
        self.write_sector += 1

    def write_modified(self):
        original = bytearray((E_FOLDER_FLOPPY / f"{self.disk_name}.raw").read_bytes())
        modified = bytearray(original)
        directory = bytearray([0xFF] * 0x200)
        mapping = bytearray([0xFF] * 0x200)
        file_count = 0
        self.write_sector = 1

        for entry in self.files:
            for sector in entry["sectors"]:
                mapping[self.write_sector] = file_count
                start = Const.DISK_SECTOR_SIZE * sector
                self._write_mod_sector(modified, self.write_sector,
                                       original[start:start + Const.DISK_SECTOR_SIZE])
            self._write_filename(entry["file_name"], file_count, directory)
            file_count += 1

        for filename, data in self.modified_files.items():
            self._write_filename(filename, file_count, directory)
            sector_count = (len(data) + Const.DISK_SECTOR_SIZE - 1) // Const.DISK_SECTOR_SIZE
            for sector_index in range(sector_count):
                mapping[self.write_sector] = file_count
                start = sector_index * Const.DISK_SECTOR_SIZE
                self._write_mod_sector(modified, self.write_sector, data[start:start + Const.DISK_SECTOR_SIZE])
            file_count += 1

        mapping[0] = 0xFE
        modified[self.DIR_POS:self.DIR_POS + 0x200] = directory
        modified[self.DIR_POS + 0x200:self.DIR_POS + 0x400] = mapping

        free_sectors = sum(1 for index, value in enumerate(mapping) if index < 400 and value == 0xFF)
        print(f"Free sectors: {free_sectors}/400")
        output = I_FOLDER_FLOPPY / f"{self.disk_name}.raw"
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_bytes(modified)

    def open(self, filename):
        self.floppy_file = FileStreamer(E_FOLDER_FLOPPY / f"{filename}.raw")
        self.disk_name = filename
        self.floppy_file.reset(self.DIR_POS)
        directory = self.floppy_file.read_bytes(0x200)
        mapping = self.floppy_file.read_bytes(0x200)
        self.internal_number = mapping[0x1FE:0x200]
        for offset in range(0, 0x200, 4):
            name = directory[offset:offset + 4]
            if name == b"\xFF\xFF\xFF\xFF":
                break
            file_index = offset // 4
            self.files.append({
                "file_name": name.replace(b"\0", b""),
                "index": file_index,
                "sectors": [index for index in range(len(mapping[:0x1FE])) if mapping[index] == file_index],
            })

    def extract_all(self):
        for entry in self.files:
            data = bytearray()
            for sector in entry["sectors"]:
                if sector <= 400:
                    data.extend(self.floppy_file.read_bytes(Const.DISK_SECTOR_SIZE,
                                                             sector * Const.DISK_SECTOR_SIZE))
            directory = E_FOLDER_FILES / self.disk_name
            directory.mkdir(parents=True, exist_ok=True)
            filename = entry["file_name"].decode("cp932", errors="replace")
            (directory / filename).write_bytes(data)
