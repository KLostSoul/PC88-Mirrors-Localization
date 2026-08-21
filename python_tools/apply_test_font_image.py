import argparse
import shutil
from pathlib import Path

from .fontgen import FontGen


TRACK_START_SECTOR = 13350
RAW_SECTOR_SIZE = 2352
DATA_PAYLOAD_OFFSET = 16
DATA_SECTOR_SIZE = 2048


def image_offset(data_offset):
    sector = TRACK_START_SECTOR + data_offset // DATA_SECTOR_SIZE
    within_sector = data_offset % DATA_SECTOR_SIZE
    return sector * RAW_SECTOR_SIZE + DATA_PAYLOAD_OFFSET + within_sector


def read_at(handle, offset, size):
    handle.seek(offset)
    return handle.read(size)


def write_at(handle, offset, data):
    handle.seek(offset)
    handle.write(data)


def apply_font_image(source_image: Path, output_image: Path, test_font: Path, force=False):
    if not source_image.is_file():
        raise FileNotFoundError(f"English patch image not found: {source_image}")
    if not test_font.is_file():
        raise FileNotFoundError(f"Test font PNG not found: {test_font}")
    if output_image.exists() and not force:
        raise FileExistsError(f"Output already exists; use --force to replace it: {output_image}")

    expected_size = 551_779_200
    if source_image.stat().st_size != expected_size:
        raise ValueError(f"Unexpected CloneCD image size: {source_image.stat().st_size}")

    # Confirm that the three CSV font locations really correspond to the
    # English patch PNGs before writing anything.
    generator = FontGen()
    reference_root = source_image.parent.parent / "mirrors_tools" / "GFX"
    reference_fonts = [
        (reference_root / "b1-8x16_font.png", 0x11000, 0x11F20),
        (reference_root / "rcopt2-8x16_font.png", 0x12000, 0x12F20),
        (reference_root / "menu.png", 0x13000, 0x13F20),
    ]

    with source_image.open("rb") as handle:
        for reference_png, bytes_offset, widths_offset in reference_fonts:
            widths, glyph_bytes = generator.generate_vwf(reference_png, "verify_" + reference_png.stem)
            if read_at(handle, image_offset(bytes_offset), len(glyph_bytes)) != bytes(glyph_bytes):
                raise ValueError(f"Font location verification failed: {reference_png.name}")
            if read_at(handle, image_offset(widths_offset), len(widths)) != bytes(widths):
                raise ValueError(f"Font width location verification failed: {reference_png.name}")

    test_widths, test_bytes = generator.generate_vwf(test_font, "ganada_test")
    shutil.copyfile(source_image, output_image)

    targets = [
        (0x11000, 0x11F20),  # script
        (0x12000, 0x12F20),  # UI
        (0x13000, 0x13F20),  # menu
    ]
    with output_image.open("r+b") as handle:
        for bytes_offset, widths_offset in targets:
            write_at(handle, image_offset(bytes_offset), bytes(test_bytes))
            write_at(handle, image_offset(widths_offset), bytes(test_widths))

    with output_image.open("rb") as handle:
        for bytes_offset, widths_offset in targets:
            if read_at(handle, image_offset(bytes_offset), len(test_bytes)) != bytes(test_bytes):
                raise ValueError(f"Written glyph verification failed at {bytes_offset:#x}")
            if read_at(handle, image_offset(widths_offset), len(test_widths)) != bytes(test_widths):
                raise ValueError(f"Written width verification failed at {widths_offset:#x}")

    print(f"Created: {output_image}")
    print(f"Patched font banks: script, ui, menu")
    print(f"Glyph bytes: {len(test_bytes)}; width bytes: {len(test_widths)}")


def main():
    repository_root = Path(__file__).resolve().parent.parent
    parser = argparse.ArgumentParser(description="Apply the 가나다라 test font to the English-patched CloneCD image")
    parser.add_argument(
        "--source",
        type=Path,
        default=repository_root / "reference" / "Mirrors PC-8801 MC English translation v1.0 (updated emu)" / "Mirrors eng v1.0.img",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=repository_root / "Temp" / "font_test" / "Mirrors_eng_v1.0_ganada_test.img",
    )
    parser.add_argument(
        "--test-font",
        type=Path,
        default=repository_root / "Temp" / "font_test" / "b1-8x16_ganada_repeat.png",
    )
    parser.add_argument("--force", action="store_true")
    args = parser.parse_args()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    apply_font_image(args.source, args.output, args.test_font, args.force)


if __name__ == "__main__":
    main()
