import codecs

from .defines import Const
from .file_streamer import FileStreamer


def _ruby_shift_jis_error(exception):
    return "  ", exception.end


codecs.register_error("ruby_shift_jis", _ruby_shift_jis_error)


def _decode_shift_jis(data):
    return bytes(data).decode("shift_jis", errors="ruby_shift_jis")


class BasicDecompiler:
    def __init__(self):
        self.initialize()

    def initialize(self):
        pass

    def openFile(self, _fileName):
        self.bFile = FileStreamer(_fileName)

    def openMemory(self, _data):
        self.bFile = FileStreamer()
        self.bFile.openMemory(_data)

    def readBasicString(self):
        data = []
        while True:
            if self.bFile.peek() == 0x22 or self.bFile.peek() == 0:
                break
            data.append(self.bFile.readByte())
        return data

    def decompile(self, _withHeader=False):
        basF = self.bFile
        outF = ""
        stringData = {}
        stringCount = 0

        while not basF.eof():
            linkAddr = basF.readWord()
            linkNumber = basF.readWord()
            stringArray = []
            if linkAddr == 0 or linkNumber >= 20000:
                break
            outF += "%d " % linkNumber

            while True:
                op = basF.readByte()
                if op == 0x00:
                    break
                if op == 0x0b:
                    arg = basF.readWord()
                    outF += "&O%03o" % arg
                elif op == 0x0c:
                    arg = basF.readWord()
                    if arg >= 0x100:
                        outF += "&H%04X" % arg
                    else:
                        outF += "&H%02X" % arg
                elif op == 0x0e or op == 0x1c:
                    arg = basF.readWord()
                    outF += "%d" % arg
                elif op == 0x0f:
                    arg = basF.readByte()
                    outF += "%d" % arg
                elif 0x11 <= op <= 0x1b:
                    outF += "%d" % (op - 0x11)
                elif op == 0x84:
                    outF += "DATA"
                    while True:
                        data = basF.readByte()
                        if data == 0 or data == ord(":"):
                            basF.advance(-1)
                            break
                        if data == 0x22:
                            outF += '"'
                            outF += _decode_shift_jis(self.readBasicString())
                            outF += '"'
                            basF.advance(1)
                        else:
                            outF += chr(data)
                elif op == 0x22:
                    outF += '"'
                    string = _decode_shift_jis(self.readBasicString())
                    outF += string
                    stringArray.append([stringCount, string])
                    stringCount += 1
                    outF += '"'
                    if basF.peek() == 0x22:
                        basF.advance(1)
                elif op == 0x3a:
                    if basF.peek() == 0x8f:
                        outF += "'"
                        basF.advance(2)
                        while True:
                            if basF.peek() == 0:
                                break
                            outF += _decode_shift_jis([basF.readByte()])
                    else:
                        outF += chr(op)
                elif op == 0x8f:
                    outF += Const.BasicResWords[op & 0x7f]
                    while True:
                        if basF.peek() == 0:
                            break
                        outF += _decode_shift_jis([basF.readByte()])
                else:
                    if op < 0x80:
                        outF += chr(op)
                    elif op < 0xff:
                        outF += Const.BasicResWords[op & 0x7f]
                    else:
                        ext = basF.readByte()
                        outF += Const.BasicExtWords[ext & 0x7f]

            if len(stringArray) > 0:
                stringData[linkNumber] = stringArray

            outF += "\n"
            basF.reset(linkAddr + (6 if _withHeader else -1))

        return {"mData": outF, "mStrings": stringData}
