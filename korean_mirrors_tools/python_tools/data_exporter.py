import csv
import subprocess

from .basic_decompiler import BasicDecompiler
from .defines import Const, Paths
from .file_streamer import FileStreamer
from .floppy import FloppyMan
from .util import Util


class DataExporter:
    def __init__(self, _fileName):
        self.initialize(_fileName)

    def initialize(self, _fileName):
        self.cdFile = FileStreamer(_fileName)

    def readSectors(self, _secNum, _count=1):
        return self.cdFile.readBytes(
            _count * Const.CD_Sector_Size,
            _secNum * Const.CD_Sector_Size,
        )

    def readData(self, _offset, _size):
        return self.cdFile.readBytes(_size, _offset)

    def exportStrings(self, _disk, _script, _strData):
        for line, strs in _strData.items():
            for string in strs:
                exportData = [_disk, _script, line, string[0], string[1], ""]
                self.stringCSV.writerow(exportData)

    def extractData(self):
        cdData = Util.CSV2hashArray(Paths.ECSV_CDData)
        for d in cdData:
            raw = self.readData(int(d["offset"], 16), int(d["size"], 16))
            fileName = Paths.EXPORT_PATH / d["path"] / (d["filename"] + ".raw")
            fileName.parent.mkdir(parents=True, exist_ok=True)
            fileName.write_bytes(bytes(raw))

            if d["type"] == "basic":
                basic = BasicDecompiler()
                basic.openMemory(raw)
                decomp = basic.decompile()
                basicPath = Paths.EFolder_Basic / (d["filename"] + ".bas")
                basicPath.parent.mkdir(parents=True, exist_ok=True)
                basicPath.write_text(decomp["mData"], encoding="utf-8")
                self.exportStrings(
                    d["filename"], d["filename"], decomp["mStrings"]
                )
            elif d["type"] == "asm":
                asmName = Paths.EFolder_ASM / (d["filename"] + ".asm")
                command = [
                    str(Paths.DASM_Exe),
                    str(fileName),
                    str(asmName),
                    "--hex:x",
                    "--xref",
                    "--lowercase",
                    "--addr:" + d["loadAddr"],
                ]
                subprocess.Popen(
                    command,
                    stdin=subprocess.PIPE,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                )

    def exportFloppyData(self):
        floppyDisks = [
            item for item in Util.CSV2hashArray(Paths.ECSV_CDData)
            if item["type"] == "floppy"
        ]
        for f in floppyDisks:
            floppyMan = FloppyMan()
            floppyMan.open(f["filename"])
            floppyMan.extractAll()

    def exportBasicScripts(self):
        basicScripts = Util.CSV2hashArray(Paths.ECSV_Scripts)
        for b in basicScripts:
            basicFile = BasicDecompiler()
            basicRaw = list(
                (Paths.EFolder_Files / b["disk"] / b["script"]).read_bytes()
            )
            print("Decompiling " + b["script"])
            fileSize = Util.b2n(basicRaw[4:6])
            basicFile.openMemory(basicRaw[7:7 + fileSize])
            decompData = basicFile.decompile()
            outPath = Paths.EFolder_Basic / b["script"]
            outPath.parent.mkdir(parents=True, exist_ok=True)
            outPath.write_text(decompData["mData"], encoding="utf-8")
            self.exportStrings(b["disk"], b["script"], decompData["mStrings"])

    def export(self):
        headers = [
            "disk_num", "script_num", "basic_line",
            "string_num", "source_text", "translation",
        ]
        output = Paths.EData_Scripts
        output.parent.mkdir(parents=True, exist_ok=True)
        with open(output, "w", encoding="utf-8", newline="") as handle:
            self.stringCSV = csv.writer(
                handle,
                delimiter=";",
                quotechar='"',
                quoting=csv.QUOTE_ALL,
                lineterminator="\n",
            )
            self.stringCSV.writerow(headers)
            self.extractData()
            self.exportFloppyData()
            self.exportBasicScripts()
