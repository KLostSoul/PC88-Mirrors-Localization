import csv
from pathlib import Path


def csv_hash_array(path: Path, delimiter=";"):
    # Ruby: CSV.read(..., :encoding => "utf-8").  Do not silently strip a
    # BOM here: a BOM is part of the input as far as the reference tool is
    # concerned.
    with path.open("r", encoding="utf-8", newline="") as handle:
        return list(csv.DictReader(handle, delimiter=delimiter))


def b2n(values, little_endian=True):
    data = list(values)
    if little_endian:
        return sum(value << (index * 8) for index, value in enumerate(data))
    return sum(value << ((len(data) - 1 - index) * 8) for index, value in enumerate(data))


def n2b(number, count, little_endian=True):
    order = range(count) if little_endian else range(count - 1, -1, -1)
    return [(number >> (index * 8)) & 0xFF for index in order]


def jis0208_sjis(byte1, byte2):
    first = ((byte1 + 1) >> 1) + (0x70 if byte1 <= 0x5E else 0xB0)
    second = byte2 + ((0x1F if byte2 < 0x60 else 0x20) if byte1 % 2 else 0x7E)
    return b2n([first, second], little_endian=False)


def safe_shift_jis(text):
    # Ruby String#encode('Shift_JIS', 'UTF-8', replace: "")
    return text.encode("shift_jis", errors="ignore")
