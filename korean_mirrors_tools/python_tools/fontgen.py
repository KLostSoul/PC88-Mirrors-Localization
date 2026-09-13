from PIL import Image

from .defines import Paths


class FontGen:
    def __init__(self):
        self.initialize()

    def initialize(self):
        pass

    def generateVWF(self, _fontFile, _name):
        img = Image.open(_fontFile).convert("RGBA")
        charWidth = 8
        charHeight = 16

        tileBytes = []
        tileWidths = []
        leftMargin = []
        rightMargin = []

        for y in range(6):
            for x in range(16):
                part = img.crop((x * charWidth, (y + 2) * charHeight,
                                 x * charWidth + charWidth,
                                 (y + 2) * charHeight + charHeight))
                leftX = 0
                rightX = charWidth - 1
                letterWidth = 4

                if x > 0 or y > 0:
                    for _r in range(4):
                        leftColumn = [part.getpixel((leftX, yy))
                                      for yy in range(16)]
                        rightColumn = [part.getpixel((rightX, yy))
                                       for yy in range(16)]
                        if len(set(leftColumn)) == 1:
                            leftX += 1
                        if len(set(rightColumn)) == 1:
                            rightX -= 1

                    letterWidth = rightX - leftX + 1
                    picWidth = letterWidth
                    if picWidth < 4:
                        picWidth = 4
                    part = part.crop((leftX, 0, leftX + picWidth, charHeight))

                for line in range(charHeight):
                    bs = ""
                    for pixel in range(charWidth):
                        if pixel < part.width:
                            rgba = part.getpixel((pixel, line))
                            value = ((rgba[0] << 24) |
                                     (rgba[1] << 16) |
                                     (rgba[2] << 8) |
                                     rgba[3])
                            bs += "1" if value > 0xff else "0"
                        else:
                            bs += "0"
                    tileBytes.append(int(bs, 2))

                tileWidths.append(letterWidth - 1)

        tileWidths.pop(0)
        tileWidths.insert(0, 0x02)
        Paths.IFolder_Data.mkdir(parents=True, exist_ok=True)
        (Paths.IFolder_Data / (_name + "_bytes.raw")).write_bytes(bytes(tileBytes))
        (Paths.IFolder_Data / (_name + "_widths.raw")).write_bytes(bytes(tileWidths))
        print("Font %s generated" % _fontFile)
        return [tileWidths, tileBytes]

    def generateKoreanFixed8x16(self, _fontFile, _outputFile):
        """Convert the 1280-slot production sheet to 0x5000 raw bytes."""
        img = Image.open(_fontFile).convert("1")
        charWidth = 8
        charHeight = 16
        columns = 16
        rows = 80
        expectedSize = (columns * charWidth, rows * charHeight)
        if img.size != expectedSize:
            raise ValueError(
                "Korean font image must be %dx%d, got %dx%d" %
                (expectedSize[0], expectedSize[1], img.width, img.height)
            )

        tileBytes = bytearray()
        for glyphY in range(rows):
            for glyphX in range(columns):
                x0 = glyphX * charWidth
                y0 = glyphY * charHeight
                for line in range(charHeight):
                    value = 0
                    for pixel in range(charWidth):
                        value <<= 1
                        if img.getpixel((x0 + pixel, y0 + line)) != 0:
                            value |= 1
                    tileBytes.append(value)

        if len(tileBytes) != 0x5000:
            raise RuntimeError(
                "Korean font raw size is %d, expected 0x5000" % len(tileBytes)
            )
        _outputFile.parent.mkdir(parents=True, exist_ok=True)
        _outputFile.write_bytes(tileBytes)
        print("Korean font %s generated (%d bytes)" %
              (_fontFile, len(tileBytes)))
        return list(tileBytes)
