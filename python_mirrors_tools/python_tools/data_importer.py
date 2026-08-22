import ast
import csv
import math
import subprocess

from .basic_compiler import BasicCompiler
from .defines import Const, Paths
from .floppy import FloppyMan
from .fontgen import FontGen
from .img_encoder import ImgEncoder
from .util import Util


class DataImporter:
    def __init__(self, _translate=True):
        self.initialize(_translate)

    def initialize(self, _translate=True):
        with open(Paths.IData_Scripts, "r", encoding="utf-8-sig",
                  newline="") as handle:
            self.stringsData = list(csv.DictReader(handle, delimiter="\t"))
        for string in self.stringsData:
            string["source_text"] = (
                string["source_text"]
                .replace("−", "－")
                .replace("－", "−")
            )

        self.basicPatch = Util.CSV2hashArray(Paths.IData_BasicPatch)
        self.diskData = Util.CSV2hashArray(Paths.ICSV_Disks)
        self.scriptData = Util.CSV2hashArray(Paths.ECSV_Scripts)
        self.diskMans = {}
        self.enableTranslation = _translate
        self.createDiskMans()

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
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], 10010,
            'CMD SCREEN 1:GOSUB 2400:BN=&HD007:BM$="This story is a work of fiction.":GOSUB 5100',
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
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], _line + 1,
            "POKE &HB401,0:POKE &H92DC,1:BN=&HED93:GOSUB %d" %
            (_line + 40),
        )
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], _line + 5,
            "FOR K1=1 TO LEN(BM$):K$=MID$(BM$,K1,1):IF ASC(K$)=92 THEN GOSUB %d:GOTO %d:ELSE %d:" %
            (_line + 44, _line + 20, _line + 10),
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
            "BN=BN+&H50*14:GOSUB %d:POKE &HB401,0:RETURN" % (_line + 40),
        )
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], _line + 105,
            'BM$=">>>":CMD WIDTH &HF9CD,&H10,7:CMD KANJI BM$',
        )
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], _line + 410,
            "POKE &H92DC,2:BN=&HEF42:CN=0:FOR I=1 TO CM:CMD WIDTH BN,&H40,7:CMD KANJI CM$(I):BN=BN+&H50*11:NEXT:POKE &H92DC,1",
        )
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], _line + 420,
            "LINE(110,154+CN*11)-(512,164+CN*11),7,BF,XOR:CN2=CN",
        )
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], _line + 440,
            "LINE(110,154+CN2*11)-(512,164+CN2*11),7,BF,XOR",
        )

    def basic_applySavePatch(self, _patch, _scdata, _diskData):
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], 10000,
            'BM$="Save game? (press Y or N)":GOSUB 5000',
        )
        self.basic_addPatchLine(
            _patch, _scdata["disk"], _scdata["script"], 10040,
            'BM$="Select slot (1-9, ESC to exit):":GOSUB 5000',
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
            'BM$="Done. Press ENTER to continue.":GOSUB 5100:RETURN',
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
                    'ISET X:COMMON FO:GOSUB 5200:BM$="Press any key to start reading data from CD-ROM.":GOSUB 5100',
                    'COMMON STOP:CMD SCREEN 1:BM$="Reading data...":GOSUB 5000',
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
            comp = BasicCompiler(strings, basicPatch, self.scriptFont[0])
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

    def generateFonts(self):
        customFont = FontGen()
        customFont.generateVWF(Paths.Font_Script, "script")
        self.scriptFont = customFont.generateVWF(Paths.Font_UI, "ui")
        customFont.generateVWF(Paths.Font_Menu, "menu")

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
        self.generateFonts()
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
