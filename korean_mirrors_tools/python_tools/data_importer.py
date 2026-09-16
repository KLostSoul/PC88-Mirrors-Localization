import ast
import csv
import math
import re
import subprocess

from .basic_compiler import (
    ASCII_WIDTHS,
    BasicCompiler,
    KOREAN_TOKEN_CONTROL_BYTES,
    KOREAN_TOKEN_LEADS,
)
from .defines import Const, Paths
from .floppy import FloppyMan
from .img_encoder import ImgEncoder
from .util import Util


class DataImporter:
    REQUIRED_HARDCODED_STRINGS = {
        "opening_fiction",
        "output_marker",
        "save_prompt",
        "save_slot_prompt",
        "save_done",
        "cd_read_prompt",
        "cd_reading",
        "asm_save_slot_prompt",
    }

    def __init__(self, _translate=True):
        self.initialize(_translate)

    def initialize(self, _translate=True):
        with open(Paths.IData_Scripts, "r", encoding="utf-8-sig",
                  newline="") as handle:
            self.stringsData = list(csv.DictReader(handle, delimiter="\t"))
        for string in self.stringsData:
            string["source_text"] = (
                (string.get("source_text") or "")
                .replace("−", "－")
                .replace("－", "−")
            )

        self.basicPatch = Util.CSV2hashArray(Paths.IData_BasicPatch)
        self.loadHardcodedStrings()
        self.diskData = Util.CSV2hashArray(Paths.ICSV_Disks)
        self.scriptData = Util.CSV2hashArray(Paths.ECSV_Scripts)
        self.diskMans = {}
        self.enableTranslation = _translate
        self.asciiWidths = ASCII_WIDTHS
        self.createDiskMans()

    def loadHardcodedStrings(self):
        rows = Util.CSV2hashArray(Paths.IData_HardcodedStrings)
        keys = [row.get("key", "") for row in rows]
        if len(keys) != len(set(keys)):
            raise RuntimeError("Duplicate hardcoded string key")
        missing = self.REQUIRED_HARDCODED_STRINGS - set(keys)
        if missing:
            raise RuntimeError(
                "Missing hardcoded strings: " + ", ".join(sorted(missing))
            )
        self.hardcodedStrings = {
            row["key"]: (
                row.get("translation", "")
                if row.get("translation", "") != ""
                else row.get("source_text", "")
            )
            for row in rows
        }

    def hardcodedText(self, key):
        if key not in self.hardcodedStrings:
            raise RuntimeError("Unknown hardcoded string key: " + key)
        return (
            self.hardcodedStrings[key]
            .replace('"', "`")
            .replace("\r", "")
            .replace("\n", "\\")
        )

    def createDiskMans(self):
        for d in self.diskData:
            if d["disk"] not in self.diskMans:
                diskMan = FloppyMan()
                diskMan.open(d["disk"])
                self.diskMans[d["disk"]] = diskMan

    def basic_addPatchLine(self, _patch, _disk, _script, _line, _code):
        _patch.append({
            "disk": _disk,
            "script": _script,
            "line": str(_line),
            "patchedLine": _code,
        })

    def convertCDoffset_toAbsolute(self, _offset):
        return _offset // 0x800 + Const.CD_Sector_DataStart

    def basic_applyVWFHandler_Opening(self, _patch, _scdata):
        opening_text = self.hardcodedText("opening_fiction")
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], 10010,
            'CMD SCREEN 1:GOSUB 2400:BN=&HD007:BM$="%s":GOSUB 5100' %
            opening_text,
        )
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], 5100,
            "CMD WIDTH BN,&H40,7:CMD KANJI BM$:BN=BN+&H0640:RETURN",
        )
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], 5120,
            "GOSUB 2400:CMD WIDTH &HD504,&H60,7:CMD KANJI BM$",
        )
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], 5130,
            "CMD WIDTH &HDF04,&H60,7:CMD KANJI BM2$:GOSUB 5110:RETURN",
        )
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], 5140,
            "GOSUB 2400:CMD WIDTH &HD50A,&H60,6:CMD KANJI BM$",
        )
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], 5150,
            "CMD WIDTH &HDC90,&H60,7:CMD KANJI BM2$",
        )
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], 5160,
            "CMD WIDTH &HE417,&H60,7:CMD KANJI BM3$:GOSUB 5110:RETURN",
        )

    def basic_applyVWFHandler(self, _patch, _scdata, _line=5000):
        # The compiler emits self-describing two-byte Hangul tokens whose
        # lead bytes are KOREAN_TOKEN_LEADS.  The old Ruby patch used the
        # former E0-E5 namespace; leaving that test here splits every new
        # Hangul token into two one-byte glyphs before CMD KANJI receives it.
        token_condition = (
            "KA>=%d AND KA<=%d" %
            (min(KOREAN_TOKEN_LEADS), max(KOREAN_TOKEN_LEADS))
            + "".join(
                " AND KA<>%d" % value
                for value in sorted(KOREAN_TOKEN_CONTROL_BYTES)
                if 0x80 <= value <= 0xD7
            )
        )
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], _line + 1,
            "A=&HCA4F:CALL A:BN=&HEE83:GOSUB %d" %
            (_line + 40),
        )
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], _line + 5,
            "FOR K1=1 TO LEN(BM$):K$=MID$(BM$,K1,1):KA=ASC(K$):IF KA=92 THEN GOSUB %d:GOTO %d:ELSE %d:" %
            (_line + 44, _line + 20, _line + 7),
        )
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], _line + 7,
            "IF %s THEN K$=MID$(BM$,K1,2):K1=K1+1" % token_condition,
        )
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], _line + 10,
            "CMD WIDTH BN,&H60,7:POKE &HB400,1:CMD KANJI K$:KN=KN+1:",
        )
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], _line + 20,
            "GOSUB %d:FOR L=1 TO PEEK(&HE3FF):NEXT:NEXT:RETURN" %
            (_line + 41),
        )
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], _line + 40,
            "POKE &HB40B,(BN\\256)AND 255:POKE &HB40A,BN AND 255:KN=BN:RETURN",
        )
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], _line + 41,
            "SZ=PEEK(&HE3FE):IF SZ=0 THEN POLL P,&H0410,&HD214:RETURN",
        )
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], _line + 42,
            "IF SZ=1 THEN FOR K2=0 TO 2:BEEP 1:BEEP 0:NEXT:RETURN",
        )
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], _line + 43,
            "RETURN",
        )
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], _line + 44,
            "BN=BN+&H50*16:GOSUB %d:POKE &HB401,0:RETURN" % (_line + 40),
        )
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], _line + 105,
            'BM$="%s":CMD WIDTH &HF9CD,&H10,7:CMD KANJI BM$' %
            self.hardcodedText("output_marker"),
        )
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], _line + 410,
            "BN=&HEF42:CN=0:FOR I=1 TO CM:CMD WIDTH BN,&H60,7:CMD KANJI CM$(I):BN=BN+&H50*16:NEXT",
        )
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], _line + 420,
            "LINE(110,150+CN*16)-(512,165+CN*16),7,BF,XOR:CN2=CN",
        )
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], _line + 440,
            "LINE(110,150+CN2*16)-(512,165+CN2*16),7,BF,XOR",
        )

    def basic_applySavePatch(self, _patch, _scdata, _diskData):
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], 10000,
            'BM$="%s":GOSUB 5000' % self.hardcodedText("save_prompt"),
        )
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], 10040,
            'BM$="%s":GOSUB 5000' %
            self.hardcodedText("save_slot_prompt"),
        )
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], 10049,
            'S$=INKEY$:IF S$="" THEN 10049',
        )
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], 10050,
            "IF S$=CHR$(27) THEN RETURN",
        )
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], 10060,
            "TH=VAL(S$):IF TH>=1 AND TH<=9 THEN 10070:ELSE 10049",
        )
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], 10070,
            "POKE &HE302,%d:POKE &HE303,%d:" %
            (int(_diskData["scriptN"]), int(_diskData["scribtSub"])),
        )
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], 10080,
            "TU=&H31:TU=TU+TH:CMD WRITE &H00,TU,&H01,&HE300",
        )
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], 10090,
            'BM$="%s":GOSUB 5100:RETURN' % self.hardcodedText("save_done"),
        )
        for line in [10110, 10120, 10130, 10140, 10150]:
            self.basic_addPatchLine(
                _patch, _scdata["disk"], _scdata["script"], line, ""
            )

    def _ruby_eval_load_lines(self, value):
        return ast.literal_eval(value)

    def basic_applyCDswitchPatch(self, _sc, _basicPatch, _diskData):
        loadData = self._ruby_eval_load_lines(_diskData["loadLineNum"])
        nextScript = _diskData["nextScript"].split(",")
        if loadData is None or len(loadData) != len(nextScript):
            raise ValueError("Wrong load data for %s" % _sc["script"])

        for ind, nscr in enumerate(nextScript):
            nscrData = next(
                item for item in self.diskData if item["script"] == nscr
            )
            if nscrData["diskNum"] != _diskData["diskNum"]:
                patchLines = [
                    'ISET X:COMMON FO:GOSUB 5200:BM$="%s":GOSUB 5100' %
                    self.hardcodedText("cd_read_prompt"),
                    'COMMON STOP:CMD SCREEN 1:BM$="%s":GOSUB 5000' %
                    self.hardcodedText("cd_reading"),
                    "COMMON COPY &H01,%d" %
                    self.convertCDoffset_toAbsolute(
                        int(nscrData["trackCD"], 16)
                    ),
                    'POKE &H9089,%d:CMD SET:CMD SCREEN 0:CMD RUN"%s"' %
                    (int(nscrData["subDisk"]), nscrData["script"]),
                ]
                for lind, ldLine in enumerate(loadData[ind]):
                    self.basic_addPatchLine(
                        _basicPatch, _sc["disk"], _sc["script"],
                        ldLine, patchLines[lind],
                    )
            elif nscrData["subDisk"] != _diskData["subDisk"]:
                patchLines = [
                    "ISET X:COMMON FO:GOSUB 5200:FOR I=0 TO 3000:NEXT",
                    "COMMON STOP",
                    "'",
                    'POKE &H9089,%d:CMD SET:CMD SCREEN 0:CMD RUN"%s"' %
                    (int(nscrData["subDisk"]), nscrData["script"]),
                ]
                for lind, ldLine in enumerate(loadData[ind]):
                    self.basic_addPatchLine(
                        _basicPatch, _sc["disk"], _sc["script"],
                        ldLine, patchLines[lind],
                    )

    def basic_addHeader(self, _basic):
        binSize = len(_basic)
        header = [0]
        header += Util.n2b(binSize, 2, False)
        header += [0, 0, math.ceil(binSize / Const.Disk_SectorSize), 1]
        for x in header:
            _basic.insert(0, x)
        print("Compiled size: %d/12288 (%3.2f %%)" %
              (binSize, binSize * 100.0 / 12288))
        if binSize > 12288:
            print("WARNING: exceeding maximum size")
        return _basic

    def translateBasicScripts(self):
        for sc in self.scriptData:
            strings = [
                item for item in self.stringsData
                if item["script_num"] == sc["script"]
            ]
            basicPatch = [
                item for item in self.basicPatch
                if item["script"] == sc["script"]
            ]
            diskData = next(
                item for item in self.diskData
                if item["script"] == sc["script"]
            )

            if self.enableTranslation and sc["script"] == "NO0":
                self.basic_applyVWFHandler(basicPatch, sc, 9000)
                self.basic_applyVWFHandler_Opening(basicPatch, sc)
            elif self.enableTranslation and sc["commonPatch"] == "true":
                self.basic_applyVWFHandler(basicPatch, sc)

            if sc["allowSave"] == "true":
                self.basic_applySavePatch(basicPatch, sc, diskData)
            if diskData["loadLineNum"] != "-1":
                self.basic_applyCDswitchPatch(sc, basicPatch, diskData)

            outDir = Paths.IFolder_Files / sc["disk"]
            outDir.mkdir(parents=True, exist_ok=True)
            comp = BasicCompiler(strings, basicPatch, self.asciiWidths)
            print("Compiling BASIC script " + sc["script"])
            comp.openFile(Paths.EFolder_Basic / sc["script"])

            if sc.get("splitPoints") is None or sc["splitPoints"] == "-1":
                bin_ = comp.compileSingle(
                    self.enableTranslation, sc["script"]
                )
                self.basic_addHeader(bin_)
                (outDir / sc["script"]).write_bytes(bytes(bin_))
            else:
                splitArray = sc["splitPoints"].split(",")
                bins = comp.splitAndCompile(
                    sc["script"], splitArray, self.enableTranslation
                )
                if bins is None or len(bins) != 2:
                    raise ValueError("Compile error for %s" % sc["script"])
                print("Script is splitted into %s and %s" %
                      (sc["script"], splitArray[0]))
                self.basic_addHeader(bins[0])
                self.basic_addHeader(bins[1])
                self.diskMans[sc["disk"]].addReplaceFile(
                    splitArray[0], bins[1]
                )
                (outDir / sc["script"]).write_bytes(bytes(bins[0]))
                (outDir / splitArray[0]).write_bytes(bytes(bins[1]))

    def createPackFloppyImages(self):
        for d in self.diskData:
            if int(d["diskNum"]) > 0:
                basic = list(
                    (Paths.IFolder_Files / d["disk"] / d["script"]).read_bytes()
                )
                self.diskMans[d["disk"]].addReplaceFile(d["script"], basic)

        for disk, man in self.diskMans.items():
            print("Writing disk %s" % disk)
            man.writeModified()

        groups = {}
        for item in self.diskData:
            groups.setdefault(item["disk2HD"], []).append(item)
        for disk, group2HD in sorted(groups.items()):
            toPackDisks = {}
            for item in group2HD:
                toPackDisks.setdefault(item["disk"], []).append(item)
            diskInfo = next(iter(toPackDisks.values()))[0]
            trackCD = int(diskInfo["trackCD"], 16)
            for i in range(Const.Disk_2HD_ImgSize):
                self.cdImage[trackCD + i] = 0

            self.cdImage[trackCD + 0x12C002] = int(diskInfo["diskNum"])
            self.cdImage[trackCD + 0x12C003] = 0xC9
            print("Packing 2HD disk %s at offset %x" % (disk, trackCD))

            for diskName, diskEntries in toPackDisks.items():
                ind = int(diskEntries[0]["subDisk"])
                offset = trackCD + Const.Disk_ImgSize * ind
                diskFile = list(
                    (Paths.IFolder_Floppy /
                     (diskName + ".raw")).read_bytes()
                )
                for i in range(Const.Disk_ImgSize):
                    self.cdImage[offset + i] = diskFile[i]

    def compileASM(self):
        Paths.IASM_Bin.mkdir(parents=True, exist_ok=True)
        self.asmData = Util.CSV2hashArray(Paths.ICSV_ASM)
        for asm in self.asmData:
            asmSource = Paths.IASM_Source / (asm["asmFile"] + ".asm")
            asmSource = self.prepareEditableASMSource(
                asmSource, asm["asmFile"]
            )
            asmBinary = Paths.IASM_Bin / (asm["asmFile"] + ".raw")
            asmList = Paths.IASM_Bin / (asm["asmFile"] + ".lst")
            print("Compiling ASM file %s" % asmSource)
            cmdLine = (
                '"%s" -L "%s" -Fbin -o "%s" "%s"' %
                (Paths.ASM_Exe, asmList, asmBinary, asmSource)
            )
            print(cmdLine)
            process = subprocess.Popen(
                cmdLine,
                shell=True,
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
            )
            _stdout, errors = process.communicate()
            if errors != "":
                raise RuntimeError("ASM compilation error for " +
                                   str(asmSource) + ": " + errors)
            if asm["compileOnly"] == "true":
                origSize = int(asm["fileSize"], 16)
                if origSize > 0 and origSize != asmBinary.stat().st_size:
                    raise RuntimeError(
                        "Image size mismatch for %s! %d(orig) != %d(mod)" %
                        (asm["asmFile"], origSize, asmBinary.stat().st_size)
                    )

    def prepareEditableASMSource(self, asmSource, asmName):
        if asmName != "asmmain":
            return asmSource

        message = (
            self.hardcodedStrings["asm_save_slot_prompt"]
            .replace("\r", "")
            .replace("\n", "\\")
        )
        compiler = BasicCompiler()
        encoded = compiler._encode_ruby_string_bytes(message)
        slot_size = 29
        if len(encoded) > slot_size:
            raise RuntimeError(
                "asm_save_slot_prompt uses %d bytes, maximum is %d" %
                (len(encoded), slot_size)
            )
        length_with_sentinel = len(encoded) + 1
        padded = encoded + [0] * (slot_size - len(encoded))

        source = asmSource.read_text(encoding="utf-8")
        length_pattern = re.compile(
            r"(?m)^(\s*)ld\s+a,0x[0-9A-Fa-f]{2}"
            r"\s*;\s*23 ASCII bytes \+ existing length sentinel\s*$"
        )
        source, length_count = length_pattern.subn(
            lambda match: (
                f"{match.group(1)}ld      a,0x{length_with_sentinel:02X}"
                "          ; editable message bytes + existing length sentinel"
            ),
            source,
            count=1,
        )
        if length_count != 1:
            raise RuntimeError("Unable to locate LC053 message length patch")

        byte_lines = []
        for offset in range(0, slot_size, 8):
            chunk = padded[offset:offset + 8]
            prefix = "LC053:  .byte   " if offset == 0 else "        .byte   "
            byte_lines.append(
                prefix + ",".join("0x%02X" % value for value in chunk)
            )
        block_pattern = re.compile(
            r"(?ms)^LC053:\s+\.byte.*?(?=^\s*ld\s+d,d\s*$)"
        )
        replacement = (
            "; LBF6A direct VWF message generated from "
            "Data/hardcoded_strings.csv.\n"
            + "\n".join(byte_lines)
            + "\n"
        )
        source, block_count = block_pattern.subn(replacement, source, count=1)
        if block_count != 1:
            raise RuntimeError("Unable to locate LC053 fixed message slot")

        output = Paths.TEMP_PATH / "editable_asm" / asmSource.name
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(source, encoding="utf-8")
        return output

    def importIntroScript(self):
        introData = [
            item for item in self.stringsData
            if item["disk_num"] == Const.Const_Intro
        ]
        basicPatch = [
            item for item in self.basicPatch
            if item["disk"] == Const.Const_Intro
        ]
        comp = BasicCompiler(introData, basicPatch)
        comp.openFile(Paths.IFolder_Basic / (Const.Const_Intro + ".bas"))
        bin_ = comp.compileSingle(True, Const.Const_Intro + ".bas")
        offset = int(next(
            item for item in Util.CSV2hashArray(Paths.ECSV_CDData)
            if item["filename"] == Const.Const_Intro
        )["offset"], 16)
        for i, x in enumerate(bin_):
            self.cdImage[offset + i] = x

    def menu_insertNewDiskData(self, _data):
        groups = {}
        for item in self.diskData:
            groups.setdefault(item["disk2HD"], []).append(item)
        basicLine = 6010
        onFLine = ""
        for _disk, group2HD in sorted(groups.items()):
            diskInfo = group2HD[0]
            if int(diskInfo["diskNum"]) > 0:
                trackCD = int(diskInfo["trackCD"], 16)
                self.basic_addPatchLine(
                    _data, Const.Const_Menu, Const.Const_Menu, basicLine,
                    "COMMON COPY &H1,%d:RETURN " %
                    self.convertCDoffset_toAbsolute(trackCD),
                )
                onFLine += str(basicLine) + ","
                basicLine += 10

        onFLine = onFLine[:-1] + ":RETURN "
        onFLine = "ON C GOSUB " + onFLine
        self.basic_addPatchLine(
            _data, Const.Const_Menu, Const.Const_Menu, 6000, onFLine
        )

        basicLine = 7000
        for script in self.diskData[1:]:
            if script["scriptN"] != "-1":
                self.basic_addPatchLine(
                    _data, Const.Const_Menu, Const.Const_Menu, basicLine,
                    "DATA %d,%d, %d, %d, %s " %
                    (
                        int(script["scriptN"]),
                        int(script["scribtSub"]),
                        int(script["diskNum"]),
                        int(script["subDisk"]),
                        script["script"],
                    ),
                )
                basicLine += 5

    def importMenuScript(self):
        introData = [
            item for item in self.stringsData
            if item["disk_num"] == Const.Const_Menu
        ]
        basicPatch = [
            item for item in self.basicPatch
            if item["disk"] == Const.Const_Menu
        ]
        self.menu_insertNewDiskData(basicPatch)
        comp = BasicCompiler(introData, basicPatch)
        comp.openFile(Paths.IFolder_Basic / (Const.Const_Menu + ".bas"))
        bin_ = comp.compileSingle(self.enableTranslation, "menu.bas")
        Paths.IFolder_Data.mkdir(parents=True, exist_ok=True)
        (Paths.IFolder_Data / (Const.Const_Menu + ".raw")).write_bytes(
            bytes(bin_)
        )
        offset = int(next(
            item for item in Util.CSV2hashArray(Paths.ECSV_CDData)
            if item["filename"] == Const.Const_Menu
        )["offset"], 16)
        for i, x in enumerate(bin_):
            self.cdImage[offset + i] = x

    def deleteUnusedData(self):
        self.diskMans["disk52"].freeFile("ﾘﾝR".encode("shift_jis"))

    def replaceImages(self):
        gfxData = Util.CSV2hashArray(Paths.ICSV_GFX)
        for gfx in gfxData:
            print("Converting image %s" % gfx["origFile"])
            imgEncoder = ImgEncoder()
            convData = imgEncoder.imgEncode(
                Paths.GFX_PATH / gfx["origFile"],
                gfx["isMono"] == "true",
            )
            header = []
            header += Util.n2b(len(convData), 2, False)
            header += Util.n2b(int(gfx["loadAddr"], 16), 2, False)
            header += [math.ceil(len(convData) / Const.Disk_SectorSize), 2]
            for x in header:
                convData.insert(0, x)

            outDir = Paths.IFolder_Files / gfx["disk"]
            outDir.mkdir(parents=True, exist_ok=True)
            (outDir / gfx["file"]).write_bytes(bytes(convData))
            self.diskMans[gfx["disk"]].addReplaceFile(
                gfx["file"], convData
            )

    def importData(self):
        self.cdImage = list(Paths.Original_ISO_DataTrack.read_bytes())
        self.replaceImages()
        self.compileASM()
        self.importIntroScript()
        self.importMenuScript()
        self.deleteUnusedData()
        self.translateBasicScripts()
        self.createPackFloppyImages()

        importCsv = Util.CSV2hashArray(Paths.ICSV_CDData)
        for file in importCsv:
            iFile = list(
                (Paths.IMPORT_PATH / file["path"] /
                 (file["filename"] + ".raw")).read_bytes()
            )
            offset = int(file["offset"], 16)
            for i in range(int(file["size"], 16)):
                if i >= len(iFile):
                    break
                self.cdImage[offset + i] = iFile[i]

        Paths.Patched_ISO_DataTrack.parent.mkdir(parents=True, exist_ok=True)
        Paths.Patched_ISO_DataTrack.write_bytes(bytes(self.cdImage))
