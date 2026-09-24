"""Build a CloneCD set from the original image in ``img``."""

from __future__ import annotations

import hashlib
import shutil
import subprocess
import tempfile
from pathlib import Path
import re

from .clonecd import CloneCD
from .defines import Const, Paths


OUTPUT_BASE = "Mirrors_Korean_Mirrors_Tools_Full_Build"
PROJECT_ROOT = Paths.MAIN_PATH.parent
XDELTA_EXE = Paths.TOOLS_PATH / "xdelta.exe"
ENGLISH_BASE_IMG = (
    PROJECT_ROOT
    / "reference"
    / "Mirrors PC-8801 MC English translation v1.0 (updated emu)"
    / "Mirrors eng v1.0.img"
)
PATCH_COMPONENTS = ("ccd", "img", "sub")


def _edc_table() -> list[int]:
    table = []
    for value in range(256):
        result = value
        for _ in range(8):
            result = (result >> 1) ^ (
                0xD8018001 if result & 1 else 0
            )
        table.append(result)
    return table


def _ecc_tables() -> tuple[list[int], list[int]]:
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


EDC_TABLE = _edc_table()
ECC_FORWARD, ECC_BACKWARD = _ecc_tables()


def _edc(data: bytes | bytearray) -> int:
    result = 0
    for value in data:
        result = (result >> 8) ^ EDC_TABLE[(result ^ value) & 0xFF]
    return result


def _ecc_compute(
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


def _rebuild_mode1_sector(raw_sector: bytes, payload: bytes) -> bytes:
    if len(raw_sector) != CloneCD.RAW_SECTOR_SIZE:
        raise ValueError("Invalid raw CD sector size")
    if len(payload) != Const.CD_Sector_Size:
        raise ValueError("Invalid Track 2 payload size")

    sector = bytearray(raw_sector)
    sector[CloneCD.RAW_USER_DATA_OFFSET:
           CloneCD.RAW_USER_DATA_OFFSET + Const.CD_Sector_Size] = payload
    sector[2064:2068] = _edc(sector[:2064]).to_bytes(4, "little")
    sector[2068:2076] = b"\x00" * 8
    sector[2076:2248] = _ecc_compute(
        sector[12:2076], 86, 24, 2, 86
    )
    sector[2248:2352] = _ecc_compute(
        sector[12:2248], 52, 43, 86, 88
    )
    return bytes(sector)


def _verify_mode1_sector(raw_sector: bytes) -> bool:
    payload = raw_sector[
        CloneCD.RAW_USER_DATA_OFFSET:
        CloneCD.RAW_USER_DATA_OFFSET + Const.CD_Sector_Size
    ]
    return _rebuild_mode1_sector(raw_sector, payload) == raw_sector


def _source_paths() -> tuple[Path, Path, Path, Path]:
    source_img = Paths.CLONECD_IMG
    return (
        source_img,
        source_img.with_suffix(".ccd"),
        source_img.with_suffix(".cue"),
        source_img.with_suffix(".sub"),
    )


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as file:
        while chunk := file.read(1024 * 1024):
            digest.update(chunk)
    return digest.hexdigest()


def _build_xdelta_patches(
    target_paths: dict[str, Path],
    japanese_base_img: Path,
) -> list[Path]:
    bases = (
        ("Japanese", japanese_base_img),
        ("English", ENGLISH_BASE_IMG),
    )
    required = [XDELTA_EXE]
    for _, base_img in bases:
        required.extend(
            base_img.with_suffix(f".{ext}") for ext in PATCH_COMPONENTS
        )
    missing = [path for path in required if not path.is_file()]
    if missing:
        raise FileNotFoundError(
            "Missing xdelta build input(s):\n"
            + "\n".join(str(path) for path in missing)
        )

    Paths.TEMP_PATH.mkdir(parents=True, exist_ok=True)
    patches = []
    target_hashes = {
        ext: _sha256(target_paths[ext]) for ext in PATCH_COMPONENTS
    }
    with tempfile.TemporaryDirectory(
        prefix="xdelta-verify-", dir=Paths.TEMP_PATH
    ) as verify_dir:
        verify_dir = Path(verify_dir)
        for label, base_img in bases:
            for ext in PATCH_COMPONENTS:
                base = base_img.with_suffix(f".{ext}")
                target = target_paths[ext]
                patch = Paths.BUILD_OUTPUT / (
                    f"{OUTPUT_BASE}_from_{label}_{ext.upper()}.xdelta"
                )
                restored = verify_dir / f"{label}.{ext}"

                subprocess.run(
                    [
                        str(XDELTA_EXE), "-f", "-e", "-s",
                        str(base), str(target), str(patch),
                    ],
                    check=True,
                )
                subprocess.run(
                    [
                        str(XDELTA_EXE), "-f", "-d", "-s",
                        str(base), str(patch), str(restored),
                    ],
                    check=True,
                )
                if _sha256(restored) != target_hashes[ext]:
                    raise RuntimeError(
                        f"xdelta restoration does not match build output: "
                        f"{label} {ext.upper()}"
                    )
                patches.append(patch)
                print(f"Created and verified: {patch}")

    return patches


def build_clonecd() -> tuple[Path, Path, Path, Path]:
    source_img, source_ccd, source_cue, source_sub = _source_paths()
    patched_track = Paths.Patched_ISO_DataTrack

    for path in (source_img, source_ccd, source_cue, source_sub, patched_track):
        if not path.is_file():
            raise FileNotFoundError(f"Missing CloneCD build input: {path}")

    expected_track_size = (
        CloneCD.TRACK2_SECTORS * Const.CD_Sector_Size
    )
    if patched_track.stat().st_size != expected_track_size:
        raise ValueError("Patched Track 2 has an unexpected size")

    expected_image_size = (
        (CloneCD.TRACK2_LBA + CloneCD.TRACK2_SECTORS)
        * CloneCD.RAW_SECTOR_SIZE
    )
    if source_img.stat().st_size < expected_image_size:
        raise ValueError("Original CloneCD image is too short")

    Paths.BUILD_OUTPUT.mkdir(parents=True, exist_ok=True)
    output_img = Paths.BUILD_OUTPUT / f"{OUTPUT_BASE}.img"
    output_ccd = Paths.BUILD_OUTPUT / f"{OUTPUT_BASE}.ccd"
    output_cue = Paths.BUILD_OUTPUT / f"{OUTPUT_BASE}.cue"
    output_sub = Paths.BUILD_OUTPUT / f"{OUTPUT_BASE}.sub"
    shutil.copyfile(source_img, output_img)
    shutil.copyfile(source_ccd, output_ccd)
    cue_text = source_cue.read_text(encoding="ascii")
    cue_text, replacements = re.subn(
        r'(?im)^FILE\s+"[^"]+"\s+BINARY\s*$',
        f'FILE "{output_img.name}" BINARY',
        cue_text,
        count=1,
    )
    if replacements != 1:
        raise ValueError("Original CUE has no single FILE ... BINARY header")
    output_cue.write_text(cue_text, encoding="ascii", newline="")
    shutil.copyfile(source_sub, output_sub)

    track = patched_track.read_bytes()
    valid_source_sectors = 0
    with source_img.open("rb") as source, output_img.open("r+b") as output:
        for sector_number in range(CloneCD.TRACK2_SECTORS):
            raw_offset = (
                (CloneCD.TRACK2_LBA + sector_number)
                * CloneCD.RAW_SECTOR_SIZE
            )
            source.seek(raw_offset)
            original_raw = source.read(CloneCD.RAW_SECTOR_SIZE)
            if len(original_raw) != CloneCD.RAW_SECTOR_SIZE:
                raise ValueError(
                    f"Short source raw sector: {sector_number}"
                )
            if _verify_mode1_sector(original_raw):
                valid_source_sectors += 1

            start = sector_number * Const.CD_Sector_Size
            payload = track[start:start + Const.CD_Sector_Size]
            patched_raw = _rebuild_mode1_sector(original_raw, payload)
            if not _verify_mode1_sector(patched_raw):
                raise ValueError(
                    f"EDC/ECC verification failed: {sector_number}"
                )
            output.seek(raw_offset)
            output.write(patched_raw)

    if valid_source_sectors != CloneCD.TRACK2_SECTORS:
        raise ValueError(
            "Original Track 2 contains invalid MODE1 sectors: "
            f"{CloneCD.TRACK2_SECTORS - valid_source_sectors}"
        )

    _build_xdelta_patches(
        {
            "ccd": output_ccd,
            "img": output_img,
            "sub": output_sub,
        },
        source_img,
    )

    return output_img, output_ccd, output_cue, output_sub


if __name__ == "__main__":
    for output in build_clonecd():
        print(f"Created: {output}")
