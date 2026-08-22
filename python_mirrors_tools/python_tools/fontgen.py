from pathlib import Path

from PIL import Image

from .paths import I_FOLDER_DATA


class FontGen:
    """Byte-compatible port of Ruby FontGen#generateVWF."""

    def generate_vwf(self, font_file: Path, name: str):
        image = Image.open(font_file).convert("RGBA")
        tile_bytes = []
        tile_widths = []

        for row in range(6):
            for column in range(16):
                # The source intentionally skips the first two atlas rows.
                left = column * 8
                top = (row + 2) * 16
                pixels = image.crop((left, top, left + 8, top + 16))
                left_x = 0
                right_x = 7
                letter_width = 4

                if column > 0 or row > 0:
                    for _ in range(4):
                        left_column = [pixels.getpixel((left_x, y)) for y in range(16)]
                        right_column = [pixels.getpixel((right_x, y)) for y in range(16)]
                        if len(set(left_column)) == 1:
                            left_x += 1
                        if len(set(right_column)) == 1:
                            right_x -= 1
                    letter_width = right_x - left_x + 1
                    picture_width = max(letter_width, 4)
                    pixels = pixels.crop((left_x, 0, left_x + picture_width, 16))

                for y in range(16):
                    value = 0
                    for x in range(8):
                        if x < pixels.width:
                            r, g, b, a = pixels.getpixel((x, y))
                            # ChunkyPNG's RGBA integer is > 0xff for any visible
                            # white pixel and 0 for black in these atlases.
                            rgba = (r << 24) | (g << 16) | (b << 8) | a
                            if rgba > 0xFF:
                                value |= 1 << (7 - x)
                    tile_bytes.append(value)
                tile_widths.append(letter_width - 1)

        tile_widths = [0x02] + tile_widths[1:]
        I_FOLDER_DATA.mkdir(parents=True, exist_ok=True)
        (I_FOLDER_DATA / f"{name}_bytes.raw").write_bytes(bytes(tile_bytes))
        (I_FOLDER_DATA / f"{name}_widths.raw").write_bytes(bytes(tile_widths))
        print(f"Font {font_file} generated")
        return tile_widths, tile_bytes
