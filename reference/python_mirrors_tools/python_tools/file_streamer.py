from .util import Util


class FileStreamer:
    def __init__(self, _file=None, _endianness="LE"):
        self.initialize(_file, _endianness)

    def initialize(self, _file=None, _endianness="LE"):
        self.curOffset = 0
        self.endianness = _endianness
        self.fBytes = []
        if _file is not None:
            self.open(_file)

    def open(self, _file):
        with open(_file, "rb") as handle:
            self.fBytes = list(handle.read())

    def openMemory(self, _data):
        self.fBytes = list(_data)

    def clone(self):
        newStream = FileStreamer()
        newStream.fBytes = list(self.fBytes)
        newStream.endianness = self.endianness
        newStream.curOffset = self.curOffset
        return newStream

    def getAddr(self, _addr):
        return self.curOffset if _addr == -1 else _addr

    def restoreAddr(self, _addr, _curAddr):
        if _addr == -1:
            self.curOffset = _curAddr

    def eof(self):
        return self.curOffset >= len(self.fBytes)

    def offset(self):
        return self.curOffset

    def length(self):
        return len(self.fBytes)

    def reset(self, _offset=0):
        self.curOffset = _offset

    def advance(self, _count):
        self.curOffset += _count

    def peek(self, _offset=0, _failChar=0):
        if not self.eof():
            return self.fBytes[self.curOffset + _offset]
        return _failChar

    def readByte(self, _addr=-1):
        curAddr = self.getAddr(_addr)
        read = self.fBytes[curAddr]
        curAddr += 1
        self.restoreAddr(_addr, curAddr)
        return read & 0xff

    def readWord(self, _addr=-1):
        curAddr = self.getAddr(_addr)
        read = Util.b2n(self.fBytes[curAddr:curAddr + 2],
                        self.endianness == "LE")
        curAddr += 2
        self.restoreAddr(_addr, curAddr)
        return read

    def readLong(self, _addr=-1):
        curAddr = self.getAddr(_addr)
        read = Util.b2n(self.fBytes[curAddr:curAddr + 4],
                        self.endianness == "LE")
        curAddr += 4
        self.restoreAddr(_addr, curAddr)
        return read

    def readBytes(self, count, _addr=-1):
        curAddr = self.getAddr(_addr)
        bytes_ = self.fBytes[curAddr:curAddr + count]
        curAddr += count
        self.restoreAddr(_addr, curAddr)
        return bytes_

    def readString(self, endByte=0, _addr=-1):
        bytes_ = []
        curAddr = self.getAddr(_addr)
        while True:
            bytes_.append(self.fBytes[curAddr])
            curAddr += 1
            if bytes_[-1] == endByte:
                break
            if curAddr >= len(self.fBytes):
                break
        self.restoreAddr(_addr, curAddr)
        return bytes_

    def fetchUntil(self, endByte=0, _addr=-1):
        bytes_ = []
        curAddr = self.getAddr(_addr)
        while True:
            if self.fBytes[curAddr] == endByte:
                break
            bytes_.append(self.fBytes[curAddr])
            curAddr += 1
            if curAddr >= len(self.fBytes):
                break
        self.restoreAddr(_addr, curAddr)
        return bytes_
