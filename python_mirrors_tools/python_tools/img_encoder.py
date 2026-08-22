from pathlib import Path

from PIL import Image

from .util import n2b


class ImgEncoder:
    def convert_pattern(self, pattern, shift):
        result = 0
        mask = 1 << shift
        for index, value in enumerate(pattern):
            result += ((value & mask) >> shift) << (7 - index)
        return result

    def _write_chunk(self, stream, chunk):
        stream.append(len(chunk) + 0x80)
        stream.extend(chunk)
        chunk.clear()

    def img_encode(self, png_path: Path, is_mono: bool):
        source = Image.open(png_path)
        width, height = source.size
        if height > 200:
            raise ValueError("Image height is greater than 200")
        if width % 8:
            raise ValueError("Image width must be divisible by 8")

        # ChunkyPNG obtains every value through the PNG PLTE chunk.  The Ruby
        # encoder has no true-colour fallback, so neither does the port.
        if source.mode != "P":
            raise ValueError("Image does not contain a PNG palette")
        pixels = list(source.getdata())

        pattern_data = []
        cursor = 0
        plane = 0
        plane_count = 1 if is_mono else 3
        while True:
            pattern = []
            for _ in range(8):
                pattern.append(pixels[cursor])
                cursor += 1
                if cursor >= width * height:
                    cursor = 0
                    plane += 1
                    if plane >= plane_count:
                        break
            pattern_data.append(self.convert_pattern(pattern, plane))
            if plane >= plane_count:
                break

        out = [width // 8, height, 0x07 if is_mono else 0]
        repeat_count = 0
        chunk = []
        for index, current in enumerate(pattern_data):
            following = pattern_data[index + 1] if index + 1 < len(pattern_data) else current
            if current == following:
                if not chunk:
                    repeat_count += 1
                    if repeat_count >= 0x7F or index == len(pattern_data) - 1:
                        out.extend([repeat_count, current])
                        repeat_count = 0
                else:
                    self._write_chunk(out, chunk)
                    repeat_count = 1
            else:
                if repeat_count == 0:
                    if len(chunk) < 0x7F:
                        chunk.append(current)
                    else:
                        self._write_chunk(out, chunk)
                        repeat_count = 0
                else:
                    repeat_count += 1
                    out.extend([repeat_count, current])
                    repeat_count = 0

        # Ruby calls Util.n2b(0xc000, 2) without an endianness argument.
        return n2b(0xC000, 2) + out
