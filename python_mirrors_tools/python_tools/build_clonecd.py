"""Build a CloneCD set by inserting the Korean Track 2 into the English set."""

from __future__ import annotations

import shutil
from pathlib import Path

from .build_korean_iso import (
    ENGLISH_IMAGE,
    PAYLOAD_OFFSET,
    PAYLOAD_SIZE,
    RAW_SECTOR_SIZE,
    TRACK_SECTORS,
    TRACK_START_LBA,
    TRACK_SIZE,
)
from .paths import PATCHED_ISO_DATATRACK, REPOSITORY_ROOT


ENGLISH_DIR = ENGLISH_IMAGE.parent
ENGLISH_CCD = ENGLISH_DIR / "Mirrors eng v1.0.ccd"
ENGLISH_SUB = ENGLISH_DIR / "Mirrors eng v1.0.sub"
OUTPUT_DIR = REPOSITORY_ROOT / "Temp" / "Mirrors_Korean_500_Test"
OUTPUT_BASE = "Mirrors Korean 500 Test"


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


def ecc_compute(
    source: bytes | bytearray,
    major_count: int,
    minor_count: int,
    major_multiplier: int,
    minor_increment: int,
) -> bytes:
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
    sector[16:16 + PAYLOAD_SIZE] = payload
    sector[2064:2068] = edc(sector[:2064]).to_bytes(4, "little")
    sector[2068:2076] = b"\x00" * 8
    sector[2076:2248] = ecc_compute(sector[12:2076], 86, 24, 2, 86)
    sector[2248:2352] = ecc_compute(sector[12:2248], 52, 43, 86, 88)
    return bytes(sector)


def verify_mode1_sector(raw_sector: bytes) -> bool:
    payload = raw_sector[16:16 + PAYLOAD_SIZE]
    return rebuild_mode1_sector(raw_sector, payload) == raw_sector


def build() -> None:
    if not PATCHED_ISO_DATATRACK.is_file():
        raise FileNotFoundError(f"Missing Track 2 ISO: {PATCHED_ISO_DATATRACK}")
    if PATCHED_ISO_DATATRACK.stat().st_size != TRACK_SIZE:
        raise ValueError("Track 2 ISO has an unexpected size")
    for path in (ENGLISH_IMAGE, ENGLISH_CCD, ENGLISH_SUB):
        if not path.is_file():
            raise FileNotFoundError(f"Missing English CloneCD input: {path}")

    track = PATCHED_ISO_DATATRACK.read_bytes()
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    output_img = OUTPUT_DIR / f"{OUTPUT_BASE}.img"
    output_ccd = OUTPUT_DIR / f"{OUTPUT_BASE}.ccd"
    output_sub = OUTPUT_DIR / f"{OUTPUT_BASE}.sub"
    shutil.copyfile(ENGLISH_IMAGE, output_img)
    shutil.copyfile(ENGLISH_CCD, output_ccd)
    shutil.copyfile(ENGLISH_SUB, output_sub)

    valid_base_sectors = 0
    with ENGLISH_IMAGE.open("rb") as source, output_img.open("r+b") as output:
        for sector_number in range(TRACK_SECTORS):
            source.seek((TRACK_START_LBA + sector_number) * RAW_SECTOR_SIZE)
            original_raw = source.read(RAW_SECTOR_SIZE)
            if len(original_raw) != RAW_SECTOR_SIZE:
                raise ValueError(f"Short source raw sector: {sector_number}")
            if verify_mode1_sector(original_raw):
                valid_base_sectors += 1
            start = sector_number * PAYLOAD_SIZE
            payload = track[start:start + PAYLOAD_SIZE]
            patched_raw = rebuild_mode1_sector(original_raw, payload)
            output.seek((TRACK_START_LBA + sector_number) * RAW_SECTOR_SIZE)
            output.write(patched_raw)

    if valid_base_sectors != TRACK_SECTORS:
        raise ValueError(
            f"English Track 2 has invalid Mode 1 sectors: "
            f"{TRACK_SECTORS - valid_base_sectors}/{TRACK_SECTORS}"
        )

    with output_img.open("rb") as output:
        for sector_number in (0, TRACK_SECTORS // 2, TRACK_SECTORS - 1):
            output.seek((TRACK_START_LBA + sector_number) * RAW_SECTOR_SIZE)
            raw_sector = output.read(RAW_SECTOR_SIZE)
            start = sector_number * PAYLOAD_SIZE
            if raw_sector[16:16 + PAYLOAD_SIZE] != track[start:start + PAYLOAD_SIZE]:
                raise RuntimeError(f"Payload verification failed: sector {sector_number}")
            if not verify_mode1_sector(raw_sector):
                raise RuntimeError(f"EDC/ECC verification failed: sector {sector_number}")

    print(f"Created IMG: {output_img}")
    print(f"Copied CCD: {output_ccd}")
    print(f"Copied SUB: {output_sub}")
    print(f"Patched Track 2 sectors: {TRACK_SECTORS}")
    print("EDC/ECC: regenerated and verified")


if __name__ == "__main__":
    build()
