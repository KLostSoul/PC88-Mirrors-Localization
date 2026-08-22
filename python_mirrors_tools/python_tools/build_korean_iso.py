"""Build the Korean test Track 2 image from the released English Track 2.

This creates only the logical 2048-byte-sector ``02 MIRR.iso``. It does not
create or modify CloneCD IMG/CCD/SUB files.
"""

from __future__ import annotations

import hashlib
from dataclasses import dataclass
from pathlib import Path

from .paths import I_FOLDER_DATA, IASM_BIN, PATCHED_ISO_DATATRACK, REPOSITORY_ROOT


TRACK_START_LBA = 13_350
RAW_SECTOR_SIZE = 2_352
PAYLOAD_OFFSET = 16
PAYLOAD_SIZE = 2_048
TRACK_SECTORS = 19_800
TRACK_SIZE = TRACK_SECTORS * PAYLOAD_SIZE
ENGLISH_TRACK_SHA256 = "447d3f23d81897e040919b89b949814977effefe8ac89252dcf4f51553f411c2"

ENGLISH_IMAGE = (
    REPOSITORY_ROOT
    / "reference"
    / "Mirrors PC-8801 MC English translation v1.0 (updated emu)"
    / "Mirrors eng v1.0.img"
)


@dataclass(frozen=True)
class Overlay:
    name: str
    offset: int
    maximum_size: int
    source: Path
    exact_size: int | None = None


OVERLAYS = (
    Overlay("intro BASIC", 0x02000, 0x00800, I_FOLDER_DATA / "intro.raw"),
    Overlay("asmbasic", 0x03000, 0x01000, IASM_BIN / "asmbasic.raw"),
    Overlay("menu BASIC", 0x08000, 0x07000, I_FOLDER_DATA / "menu.raw"),
    Overlay("Korean VWF", 0x10000, 0x01000, IASM_BIN / "vwf.raw"),
    Overlay("Korean 500-glyph font", 0x11000, 0x01F40,
            I_FOLDER_DATA / "korean_500_bytes.raw", exact_size=0x01F40),
)


def sha256(data: bytes | bytearray) -> str:
    return hashlib.sha256(data).hexdigest()


def extract_english_track() -> bytearray:
    if not ENGLISH_IMAGE.is_file():
        raise FileNotFoundError(f"Missing English patched image: {ENGLISH_IMAGE}")

    track = bytearray(TRACK_SIZE)
    with ENGLISH_IMAGE.open("rb") as image:
        for sector in range(TRACK_SECTORS):
            image.seek((TRACK_START_LBA + sector) * RAW_SECTOR_SIZE + PAYLOAD_OFFSET)
            data = image.read(PAYLOAD_SIZE)
            if len(data) != PAYLOAD_SIZE:
                raise ValueError(f"Short Track 2 sector read: {sector}")
            start = sector * PAYLOAD_SIZE
            track[start:start + PAYLOAD_SIZE] = data

    actual_hash = sha256(track)
    if actual_hash != ENGLISH_TRACK_SHA256:
        raise ValueError(
            "English Track 2 hash mismatch: "
            f"expected {ENGLISH_TRACK_SHA256}, got {actual_hash}"
        )
    return track


def build() -> None:
    base = extract_english_track()
    output = bytearray(base)
    allowed = bytearray(TRACK_SIZE)

    for overlay in OVERLAYS:
        if not overlay.source.is_file():
            raise FileNotFoundError(f"Missing compiled {overlay.name}: {overlay.source}")
        data = overlay.source.read_bytes()
        if overlay.exact_size is not None and len(data) != overlay.exact_size:
            raise ValueError(
                f"{overlay.name} size mismatch: expected {overlay.exact_size:#x}, "
                f"got {len(data):#x}"
            )
        if len(data) > overlay.maximum_size:
            raise ValueError(
                f"{overlay.name} exceeds allocation: {len(data):#x} > "
                f"{overlay.maximum_size:#x}"
            )
        end = overlay.offset + len(data)
        output[overlay.offset:end] = data
        allowed[overlay.offset:overlay.offset + overlay.maximum_size] = b"\x01" * overlay.maximum_size
        print(
            f"Overlay {overlay.name}: {overlay.offset:#08x}-{end - 1:#08x} "
            f"({len(data):#x} bytes)"
        )

    outside_changes = sum(
        1 for index, (before, after) in enumerate(zip(base, output))
        if before != after and not allowed[index]
    )
    if outside_changes:
        raise RuntimeError(f"Unexpected changes outside overlay ranges: {outside_changes}")

    for overlay in OVERLAYS:
        data = overlay.source.read_bytes()
        actual = output[overlay.offset:overlay.offset + len(data)]
        if actual != data:
            raise RuntimeError(f"Overlay verification failed: {overlay.name}")

    if len(output) != TRACK_SIZE:
        raise RuntimeError(f"Track 2 size changed: {len(output)}")

    PATCHED_ISO_DATATRACK.parent.mkdir(parents=True, exist_ok=True)
    PATCHED_ISO_DATATRACK.write_bytes(output)

    changed = sum(before != after for before, after in zip(base, output))
    print(f"Created: {PATCHED_ISO_DATATRACK}")
    print(f"Track 2 size: {len(output)} bytes")
    print(f"Changed bytes from English Track 2: {changed}")
    print(f"Outside allowed ranges: {outside_changes}")
    print(f"SHA-256: {sha256(output)}")


if __name__ == "__main__":
    build()
