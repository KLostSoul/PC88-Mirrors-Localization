"""Create and verify the CloneCD set for the Korean 500-glyph test ISO."""

from __future__ import annotations

import hashlib
import shutil
from pathlib import Path


TEST_ROOT = Path(__file__).resolve().parents[1]
KOREAN_ROOT = Path(__file__).resolve().parents[3]
REPOSITORY_ROOT = Path(__file__).resolve().parents[4]
ENGLISH_DIR = REPOSITORY_ROOT / "reference" / (
    "Mirrors PC-8801 MC English translation v1.0 (updated emu)"
)
ENGLISH_IMG = ENGLISH_DIR / "Mirrors eng v1.0.img"
ENGLISH_CCD = ENGLISH_DIR / "Mirrors eng v1.0.ccd"
ENGLISH_SUB = ENGLISH_DIR / "Mirrors eng v1.0.sub"
TEST_ISO = TEST_ROOT / "build" / "Mirrors_korean_500_intro_menu_safe_tokens_test.iso"
OUTPUT_DIR = TEST_ROOT / "clonecd"
OUTPUT_BASE = "Mirrors_korean_500_intro_menu_safe_tokens_test"
OUTPUT_IMG = OUTPUT_DIR / f"{OUTPUT_BASE}.img"
OUTPUT_CCD = OUTPUT_DIR / f"{OUTPUT_BASE}.ccd"
OUTPUT_SUB = OUTPUT_DIR / f"{OUTPUT_BASE}.sub"

TRACK_START_LBA = 13_350
TRACK_SECTORS = 19_800
RAW_SECTOR_SIZE = 2_352
PAYLOAD_OFFSET = 16
PAYLOAD_SIZE = 2_048
TRACK_SIZE = TRACK_SECTORS * PAYLOAD_SIZE


def make_edc_lut() -> list[int]:
    table = []
    for value in range(256):
        result = value
        for _ in range(8):
            result = (result >> 1) ^ (0xD8018001 if result & 1 else 0)
        table.append(result)
    return table


def make_ecc_tables() -> tuple[list[int], list[int]]:
    forward = []
    for value in range(256):
        result = value << 1
        if result & 0x100:
            result ^= 0x11D
        forward.append(result & 0xFF)
    backward = [0] * 256
    for value, result in enumerate(forward):
        backward[value ^ result] = value
    return forward, backward


EDC_LUT = make_edc_lut()
ECC_FORWARD, ECC_BACKWARD = make_ecc_tables()


def edc(data: bytes | bytearray) -> int:
    result = 0
    for value in data:
        result = (result >> 8) ^ EDC_LUT[(result ^ value) & 0xFF]
    return result


def ecc_compute(source: bytes | bytearray, major_count: int,
                minor_count: int, major_multiplier: int,
                minor_increment: int) -> bytes:
    size = major_count * minor_count
    output = bytearray(major_count * 2)
    for major in range(major_count):
        index = (major >> 1) * major_multiplier + (major & 1)
        ecc_a = 0
        ecc_b = 0
        for _ in range(minor_count):
            value = source[index]
            index += minor_increment
            if index >= size:
                index -= size
            ecc_a ^= value
            ecc_b ^= value
            ecc_a = ECC_FORWARD[ecc_a]
        ecc_a = ECC_BACKWARD[ECC_FORWARD[ecc_a] ^ ecc_b]
        output[major] = ecc_a
        output[major + major_count] = ecc_a ^ ecc_b
    return bytes(output)


def rebuild_mode1_sector(raw_sector: bytes, payload: bytes) -> bytes:
    if len(raw_sector) != RAW_SECTOR_SIZE or len(payload) != PAYLOAD_SIZE:
        raise ValueError("Invalid Mode 1 sector or payload size")
    sector = bytearray(raw_sector)
    sector[PAYLOAD_OFFSET:PAYLOAD_OFFSET + PAYLOAD_SIZE] = payload
    sector[2064:2068] = edc(sector[:2064]).to_bytes(4, "little")
    sector[2068:2076] = b"\x00" * 8
    sector[2076:2248] = ecc_compute(sector[12:2076], 86, 24, 2, 86)
    sector[2248:2352] = ecc_compute(sector[12:2248], 52, 43, 86, 88)
    return bytes(sector)


def verify_mode1_sector(raw_sector: bytes) -> bool:
    return rebuild_mode1_sector(
        raw_sector,
        raw_sector[PAYLOAD_OFFSET:PAYLOAD_OFFSET + PAYLOAD_SIZE],
    ) == raw_sector


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def build() -> None:
    for path in (ENGLISH_IMG, ENGLISH_CCD, ENGLISH_SUB, TEST_ISO):
        if not path.is_file():
            raise FileNotFoundError(path)
    if TEST_ISO.stat().st_size != TRACK_SIZE:
        raise ValueError("Test ISO has an unexpected Track 2 size")
    if ENGLISH_IMG.stat().st_size % RAW_SECTOR_SIZE != 0:
        raise ValueError("English IMG is not aligned to raw sectors")

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(ENGLISH_IMG, OUTPUT_IMG)
    shutil.copyfile(ENGLISH_CCD, OUTPUT_CCD)
    shutil.copyfile(ENGLISH_SUB, OUTPUT_SUB)

    valid_base = 0
    patched = 0
    with ENGLISH_IMG.open("rb") as source, TEST_ISO.open("rb") as payloads, \
            OUTPUT_IMG.open("r+b") as output:
        for sector_number in range(TRACK_SECTORS):
            source.seek((TRACK_START_LBA + sector_number) * RAW_SECTOR_SIZE)
            raw_sector = source.read(RAW_SECTOR_SIZE)
            payload = payloads.read(PAYLOAD_SIZE)
            if len(raw_sector) != RAW_SECTOR_SIZE or len(payload) != PAYLOAD_SIZE:
                raise ValueError(f"Short Track 2 input at sector {sector_number}")
            if verify_mode1_sector(raw_sector):
                valid_base += 1
            patched_sector = rebuild_mode1_sector(raw_sector, payload)
            if patched_sector != raw_sector:
                patched += 1
            output.seek((TRACK_START_LBA + sector_number) * RAW_SECTOR_SIZE)
            output.write(patched_sector)

    if valid_base != TRACK_SECTORS:
        raise RuntimeError(f"Invalid English base sectors: {TRACK_SECTORS - valid_base}")

    output_valid = 0
    payload_match = 0
    with OUTPUT_IMG.open("rb") as image, TEST_ISO.open("rb") as payloads:
        for sector_number in range(TRACK_SECTORS):
            image.seek((TRACK_START_LBA + sector_number) * RAW_SECTOR_SIZE)
            raw_sector = image.read(RAW_SECTOR_SIZE)
            expected_payload = payloads.read(PAYLOAD_SIZE)
            if verify_mode1_sector(raw_sector):
                output_valid += 1
            if raw_sector[PAYLOAD_OFFSET:PAYLOAD_OFFSET + PAYLOAD_SIZE] == expected_payload:
                payload_match += 1

    if output_valid != TRACK_SECTORS or payload_match != TRACK_SECTORS:
        raise RuntimeError(
            f"Output verification failed: EDC/ECC {output_valid}/{TRACK_SECTORS}, "
            f"payload {payload_match}/{TRACK_SECTORS}"
        )

    if OUTPUT_IMG.stat().st_size != ENGLISH_IMG.stat().st_size:
        raise RuntimeError("CloneCD IMG size changed")
    if sha256(OUTPUT_CCD) != sha256(ENGLISH_CCD):
        raise RuntimeError("CCD metadata was not copied unchanged")
    if sha256(OUTPUT_SUB) != sha256(ENGLISH_SUB):
        raise RuntimeError("SUB channel data was not copied unchanged")

    print(f"IMG: {OUTPUT_IMG}")
    print(f"CCD: {OUTPUT_CCD}")
    print(f"SUB: {OUTPUT_SUB}")
    print(f"Base Track 2 sectors checked: {valid_base}")
    print(f"Patched Track 2 sectors: {patched}")
    print(f"Output Track 2 sectors checked: {output_valid}")
    print(f"Payload sectors matched: {payload_match}")
    print("CCD metadata and SUB channel data: unchanged")


if __name__ == "__main__":
    build()
