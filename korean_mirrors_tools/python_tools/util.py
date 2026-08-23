import csv


class Util:
    @staticmethod
    def CSV2hashArray(_csvFile):
        with open(_csvFile, "r", encoding="utf-8-sig", newline="") as handle:
            return list(csv.DictReader(handle, delimiter=";"))

    @staticmethod
    def JIS0208_SJIS(byte1, byte2):
        sjis = [0, 0]
        sjis[0] = ((byte1 + 1) >> 1) + (0x70 if byte1 <= 0x5e else 0xb0)
        if byte1 % 2 == 1:
            sjis[1] = byte2 + (0x1f if byte2 < 0x60 else 0x20)
        else:
            sjis[1] = byte2 + 0x7e
        return Util.b2n(sjis, False)

    @staticmethod
    def b2n(bytes_, isLE=True):
        num = 0
        if isLE:
            counter = list(range(len(bytes_)))
        else:
            counter = list(range(len(bytes_) - 1, -1, -1))
        for t in range(len(bytes_)):
            num += bytes_[t] << (counter[t] * 8)
        return num

    @staticmethod
    def n2b(num, count, isLE=True):
        bytes_ = []
        if isLE:
            counter = list(range(count))
        else:
            counter = list(range(count - 1, -1, -1))
        for t in range(len(counter)):
            bytes_.append((num >> (counter[t] * 8)) & 0xff)
        return bytes_

