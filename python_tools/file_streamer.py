from pathlib import Path

from .util import b2n


class FileStreamer:
    def __init__(self, path=None, endianness="LE"):
        self._offset = 0
        self.endianness = endianness
        self.data = b""
        if path is not None:
            self.open(path)

    def open(self, path):
        self.data = Path(path).read_bytes()
        self._offset = 0

    def open_memory(self, data):
        self.data = bytes(data)
        self._offset = 0

    def clone(self):
        # FileStreamer#clone in the reference calls the undefined StreamFile
        # constant.  It is not used by the build, but must not acquire new
        # behaviour in the port.
        raise NameError("uninitialized constant StreamFile")

    def get_addr(self, address):
        return self._offset if address == -1 else address

    def restore_addr(self, address, current_address):
        if address == -1:
            self._offset = current_address

    def eof(self):
        return self._offset >= len(self.data)

    def offset(self):
        return self._offset

    def length(self):
        return len(self.data)

    def reset(self, offset=0):
        self._offset = offset

    def advance(self, count):
        self._offset += count

    def peek(self, offset=0, fail_char="\0"):
        if self.eof():
            return fail_char
        position = self._offset + offset
        return self.data[position] if 0 <= position < len(self.data) else None

    def _position(self, address):
        return self._offset if address == -1 else address

    def _restore(self, address, position):
        if address == -1:
            self._offset = position

    def read_byte(self, address=-1):
        position = self._position(address)
        value = self.data[position]
        self._restore(address, position + 1)
        return value & 0xFF

    def read_word(self, address=-1):
        position = self._position(address)
        value = b2n(self.data[position:position + 2], self.endianness == "LE")
        self._restore(address, position + 2)
        return value

    def read_long(self, address=-1):
        position = self._position(address)
        value = b2n(self.data[position:position + 4], self.endianness == "LE")
        self._restore(address, position + 4)
        return value

    def read_bytes(self, count, address=-1):
        position = self._position(address)
        values = self.data[position:position + count]
        self._restore(address, position + count)
        return values

    def read_string(self, end_byte=0, address=-1):
        position = self._position(address)
        result = bytearray()
        while position < len(self.data):
            value = self.data[position]
            result.append(value)
            position += 1
            if value == end_byte:
                break
        self._restore(address, position)
        return bytes(result)

    def fetch_until(self, end_byte=0, address=-1):
        position = self._position(address)
        result = bytearray()
        while position < len(self.data) and self.data[position] != end_byte:
            result.append(self.data[position])
            position += 1
        self._restore(address, position)
        return bytes(result)
