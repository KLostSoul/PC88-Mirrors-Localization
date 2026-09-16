from PIL import Image

from .defines import Const
from .util import Util


class ImgEncoder:
    def convertPattern(self, _pat, _shift):
        num = 0
        mask = 1 << _shift
        for i in range(8):
            num += ((_pat[i] & mask) >> _shift) << (7 - i)
        return num

    def writeChunk(self, _stream, _chunk):
        count = len(_chunk)
        count += 0x80
        _stream.append(count)
        for c in _chunk:
            _stream.append(c)
        _chunk.clear()

    def imgEncode(self, _pngImg, _isMono):
        image = Image.open(_pngImg).convert("P")
        width, height = image.size
        if height > 200:
            raise ValueError("Image height is greater than 200")

        pixels = list(image.getdata())
        pattern = []
        patternData = []
        c = 0
        plane = 0
        exit_ = False

        while not exit_:
            for _k in range(8):
                pattern.append(pixels[c])
                c += 1
                if c >= width * height:
                    c = 0
                    plane += 1
                    if plane >= (1 if _isMono else 3):
                        exit_ = True
                        break
            patternData.append(self.convertPattern(pattern, plane))
            pattern.clear()

        outStream = [width // 8, height, 0x07 if _isMono else 0]
        c = 0
        chunk = []
        for i in range(len(patternData)):
            it = patternData[i]
            if i + 1 >= len(patternData):
                n = patternData[i]
            else:
                n = patternData[i + 1]

            if it == n:
                if len(chunk) == 0:
                    c += 1
                    if c >= 0x7f or i == len(patternData) - 1:
                        outStream.append(c)
                        outStream.append(it)
                        c = 0
                else:
                    self.writeChunk(outStream, chunk)
                    c = 1
            else:
                if c == 0:
                    if len(chunk) < 0x7f:
                        chunk.append(it)
                    else:
                        self.writeChunk(outStream, chunk)
                        c = 0
                else:
                    c += 1
                    outStream.append(c)
                    outStream.append(it)
                    c = 0

        return Util.n2b(0xc000, 2) + outStream

