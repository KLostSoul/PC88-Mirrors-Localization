import math
import struct
import sys

from PIL import Image


if len(sys.argv) < 3:
    print("Usage: imgdecode file type hSize vSize")
    raise SystemExit(1)

imageformat = sys.argv[2]
palettedata = [
    0, 0, 0, 32, 32, 32, 64, 64, 64, 96, 96, 96,
    128, 128, 128, 160, 160, 160, 192, 192, 192, 224, 224, 224,
]

try:
    with open(sys.argv[1], "rb") as file:
        buf = file.read()
        if imageformat == "raw":
            hSize = int(sys.argv[3])
            vSize = int(sys.argv[4])
            hOff = 6
            imgBytes = bytearray(vSize * hSize)
            vPost = vSize // 8
            hPost = math.ceil(hSize / 8)

            for i in range(8):
                for j in range(vPost):
                    for k in range(3):
                        for l in range(hPost):
                            b = struct.unpack_from(
                                "B",
                                buf,
                                hOff + i * (vPost * hPost * 3)
                                + j * (hPost * 3)
                                + k * hPost
                                + l,
                            )
                            for m in range(8):
                                x = l * 8 + m
                                y = j * 8 + i
                                if x >= hSize:
                                    break
                                imgBytes[y * hSize + x] |= (
                                    ((b[0] >> (7 - m)) & 0x01) << k
                                )
        elif imageformat == "rle":
            header = struct.unpack_from("BBHHHBBB", buf, 0)
            fSize = header[3]
            hPost = header[5]
            vPost = header[6]
            maxK = 1 if header[7] == 7 else 3
            hSize = hPost * 8
            vSize = vPost
            imgBytes = bytearray(vSize * hSize)
            c = 0x0B
            k = 0
            exit_ = False
            destC = 0
            while not exit_:
                command = struct.unpack_from("B", buf, c)
                c += 1
                if command[0] & 0x80 > 0:
                    repeat = command[0] - 0x80
                    for _i in range(repeat):
                        pattern = struct.unpack_from("B", buf, c)
                        c += 1
                        for m in range(8):
                            imgBytes[destC] |= (
                                ((pattern[0] >> (7 - m)) & 0x01) << k
                            )
                            destC += 1
                            if destC >= vSize * hSize:
                                k += 1
                                destC = 0
                                if k >= maxK:
                                    exit_ = True
                                    break
                        if exit_:
                            break
                else:
                    pattern = struct.unpack_from("B", buf, c)
                    c += 1
                    for _i in range(command[0]):
                        for m in range(8):
                            imgBytes[destC] |= (
                                ((pattern[0] >> (7 - m)) & 0x01) << k
                            )
                            destC += 1
                            if destC >= vSize * hSize:
                                k += 1
                                destC = 0
                                if k >= maxK:
                                    exit_ = True
                                    break
                        if exit_:
                            break

        im = Image.frombytes("P", (hSize, vSize), bytes(imgBytes))
        im.putpalette(palettedata * 32)
        im.save(sys.argv[1] + "conv.png", format="png")
except FileNotFoundError:
    print("Failed to open " + sys.argv[1])

