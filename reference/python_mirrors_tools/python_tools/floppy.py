from .defines import Const, Paths
from .file_streamer import FileStreamer


class FloppyMan:
    Dir_Pos = 399 * Const.Disk_SectorSize
    FT_Replace = 1
    FT_Add = 2

    def __init__(self):
        self.initialize()

    def initialize(self):
        self.files = []
        self.modFiles = {}
        self.diskName = ""

    def freeFile(self, _name):
        origFile = next((i for i, f in enumerate(self.files)
                         if f["fileName"] == _name), None)
        if origFile is None:
            raise ValueError("File not found: %s" % _name)
        print("Deleting file %s..." % _name)
        self.files.pop(origFile)

    def findFreeSectors(self, _count):
        map_ = [0xff] * 400
        map_[0] = 0xfe
        map_[0x18B] = 0xfe
        for f in self.files:
            for sec in f["sectors"]:
                map_[sec] = f["index"]

        free = []
        nextIndex = 0
        for _i in range(_count):
            try:
                index = map_[nextIndex:].index(0xff)
            except ValueError:
                break
            free.append(index)
            nextIndex = index
        return free

    def addReplaceFile(self, _file, _bytes):
        fileName = _file.encode("shift_jis")
        origFile = next((i for i, f in enumerate(self.files)
                         if f["fileName"] == fileName), None)
        if origFile is None:
            print("Adding %s in disk %s..." % (fileName, self.diskName))
            self.modFiles[fileName] = list(_bytes)
        else:
            print("Replacing %s in disk %s..." % (fileName, self.diskName))
            self.modFiles[fileName] = list(_bytes)
            self.freeFile(fileName)

    def writeFilename(self, _f, _ind, _dir):
        for i in range(4):
            if i >= len(_f):
                c = 0
            else:
                c = _f[i]
                if isinstance(c, str):
                    c = ord(c)
            _dir[_ind * 4 + i] = c

    def writeModSector(self, _disk, _sector, _data):
        if self.writeSector >= 400:
            raise ValueError("Out of disk space")
        for i in range(Const.Disk_SectorSize):
            if i >= len(_data):
                break
            _disk[Const.Disk_SectorSize * _sector + i] = _data[i]
        self.writeSector += 1

    def writeModified(self):
        origFloppy = list((Paths.EFolder_Floppy /
                           (self.diskName + ".raw")).read_bytes())
        modFloppyR = origFloppy.copy()
        modDir = [0xff] * 0x200
        modMap = [0xff] * 0x200
        modFileCount = 0

        self.writeSector = 1
        for ind, f in enumerate(self.files):
            for ns in f["sectors"]:
                modMap[self.writeSector] = ind
                start = Const.Disk_SectorSize * ns
                self.writeModSector(
                    modFloppyR,
                    self.writeSector,
                    origFloppy[start:start + Const.Disk_SectorSize],
                )
            self.writeFilename(f["fileName"], ind, modDir)
            modFileCount += 1

        for file, data in self.modFiles.items():
            self.writeFilename(file, modFileCount, modDir)
            secCount = int((len(data) + Const.Disk_SectorSize - 1) /
                           Const.Disk_SectorSize)
            for s in range(secCount):
                modMap[self.writeSector] = modFileCount
                start = Const.Disk_SectorSize * s
                self.writeModSector(
                    modFloppyR,
                    self.writeSector,
                    data[start:start + Const.Disk_SectorSize],
                )
            modFileCount += 1

        modMap[0] = 0xfe
        for i in range(0x200):
            modFloppyR[self.Dir_Pos + i] = modDir[i]
        for i in range(0x200):
            modFloppyR[self.Dir_Pos + 0x200 + i] = modMap[i]

        freeSectors = 0
        for i, x in enumerate(modMap):
            if i < 400 and x == 0xff:
                freeSectors += 1
        print("Free sectors: %d/400" % freeSectors)
        (Paths.IFolder_Floppy / (self.diskName + ".raw")).write_bytes(
            bytes(modFloppyR)
        )

    def open(self, _fileName):
        self.floppyF = FileStreamer(
            Paths.EFolder_Floppy / (_fileName + ".raw")
        )
        self.diskName = _fileName
        self.floppyF.reset(self.Dir_Pos)
        dir_ = self.floppyF.readBytes(0x200)
        map_ = self.floppyF.readBytes(0x200)
        self.internalNum = map_[0x1fe:0x200]

        for i in range(0, 0x200, 4):
            fCount = i // 4
            if dir_[i:i + 4] == [0xff, 0xff, 0xff, 0xff]:
                break
            fileName = bytes(dir_[i:i + 4]).decode(
                "shift_jis", errors="replace"
            ).replace("\x00", "")
            self.files.append({
                "fileName": fileName.encode("shift_jis"),
                "index": fCount,
                "sectors": [
                    j for j in range(len(map_[:0x1fe]))
                    if map_[j] == fCount
                ],
            })

    def extractAll(self):
        for f in self.files:
            bytes_ = []
            for sec in f["sectors"]:
                if sec <= 400:
                    bytes_ += self.floppyF.readBytes(
                        Const.Disk_SectorSize,
                        sec * Const.Disk_SectorSize,
                    )
            outDir = Paths.EFolder_Files / self.diskName
            outDir.mkdir(parents=True, exist_ok=True)
            (outDir / f["fileName"].decode(
                "shift_jis", errors="replace"
            )).write_bytes(bytes(bytes_))
