from .file_streamer import FileStreamer
from .paths import BASIC_RES_WORDS, BASIC_EXT_WORDS


def decode_sjis(data):
    return bytes(data).decode("cp932", errors="replace")


class BasicDecompiler:
    def __init__(self):
        self.file = None

    def open_file(self, filename):
        self.file = FileStreamer(filename)

    def open_memory(self, data):
        self.file = FileStreamer()
        self.file.open_memory(data)

    def read_basic_string(self):
        result = bytearray()
        while True:
            if self.file.peek() in (0x22, 0):
                break
            result.append(self.file.read_byte())
        return bytes(result)

    def decompile(self, with_header=False):
        stream = self.file
        output = []
        string_data = {}
        string_count = 0

        while not stream.eof():
            link_addr = stream.read_word()
            line_number = stream.read_word()
            string_array = []
            if link_addr == 0 or line_number >= 20000:
                break
            output.append(f"{line_number} ")

            while True:
                op = stream.read_byte()
                if op == 0x00:
                    break
                if op == 0x0B:
                    output.append(f"&O{stream.read_word():03o}")
                elif op == 0x0C:
                    value = stream.read_word()
                    output.append(f"&H{value:04X}" if value >= 0x100 else f"&H{value:02X}")
                elif op in (0x0E, 0x1C):
                    output.append(str(stream.read_word()))
                elif op == 0x0F:
                    output.append(str(stream.read_byte()))
                elif 0x11 <= op <= 0x1B:
                    output.append(str(op - 0x11))
                elif op == 0x84:
                    output.append("DATA")
                    while True:
                        value = stream.read_byte()
                        if value in (0, 0x3A):
                            stream.advance(-1)
                            break
                        if value == 0x22:
                            output.append('"')
                            output.append(decode_sjis(self.read_basic_string()))
                            output.append('"')
                            stream.advance(1)
                        else:
                            output.append(chr(value))
                elif op == 0x22:
                    output.append('"')
                    text = decode_sjis(self.read_basic_string())
                    output.append(text)
                    string_array.append([string_count, text])
                    string_count += 1
                    output.append('"')
                    if stream.peek() == 0x22:
                        stream.advance(1)
                elif op == 0x3A:
                    if stream.peek() == 0x8F:
                        output.append("'")
                        stream.advance(2)
                        while stream.peek() != 0:
                            output.append(chr(stream.read_byte()))
                    else:
                        output.append(":")
                elif op == 0x8F:
                    output.append(BASIC_RES_WORDS[op & 0x7F])
                    while stream.peek() != 0:
                        output.append(chr(stream.read_byte()))
                else:
                    if op < 0x80:
                        output.append(chr(op))
                    elif op < 0xFF:
                        output.append(BASIC_RES_WORDS[op & 0x7F])
                    else:
                        ext = stream.read_byte()
                        output.append(BASIC_EXT_WORDS[ext & 0x7F])

            if string_array:
                string_data[line_number] = string_array
            output.append("\n")
            stream.reset(link_addr + (6 if with_header else -1))

        return {"mData": "".join(output), "mStrings": string_data}
