import re
from pathlib import Path

from .basic_decompiler import BasicDecompiler
from .paths import BASIC_EXT_WORDS, BASIC_RES_WORDS, Const, LINE_TOKENS, TEMP_PATH
from .util import n2b, safe_shift_jis


TOKEN_RE = re.compile(
    r'(".+?")|(-)|(,)|(=)|(:)|(\*)|([A-Z]+?\$)|(&H[0-9A-F]{4})|'
    r'(&H[0-9A-F]{2})|(&H[0-9A-F]{1})|(&O[0-7]{3})|(\s)|\b'
)


class BasicCompiler:
    LINE_LIMIT = 362

    def __init__(self, strings_data=None, patch_data=None, width_data=None):
        self.comp_file = []
        self.reg_ops = {word: chr(index + 0x80) for index, word in enumerate(BASIC_RES_WORDS)}
        self.ext_ops = {word: chr(index + 0x80) for index, word in enumerate(BASIC_EXT_WORDS)}
        self.txt_file = []
        self.strings_data = strings_data
        self.patch_data = patch_data
        self.width_data = width_data
        self.is_data_token = False
        self.is_line_token = False

    def open_file(self, filename):
        self.txt_file = Path(filename).read_text(encoding="utf-8").splitlines(True)

    def check_line_token(self, token):
        self.is_line_token = token in LINE_TOKENS

    @staticmethod
    def is_number(value):
        return re.fullmatch(r"\d+", value) is not None

    @staticmethod
    def patch_statement(statement):
        if len(statement) > 1:
            statement[1] = statement[1].replace("COMMON FM", "COMMON STOP")
            statement[1] = statement[1].replace("COMMON FP", "COMMON STOP:COMMON FP")

    @staticmethod
    def compile_end_string(value):
        return value + '"'

    @staticmethod
    def _line_parts(line):
        parts = re.split(r"\s", line, maxsplit=1)
        if len(parts) == 1:
            parts.append("")
        return parts

    def split_and_compile(self, script, split_array, translate_strings=True):
        new_script = split_array[0]
        sc1nums = [int(split_array[1]), int(split_array[2])]
        sc2nums = [int(split_array[3]), int(split_array[4])]
        sc1 = [line for line in self.txt_file if not (sc2nums[0] <= int(self._line_parts(line)[0]) <= sc2nums[1])]
        sc2 = [line for line in self.txt_file if not (sc1nums[0] <= int(self._line_parts(line)[0]) <= sc1nums[1])]
        sc1.append(f"{int(split_array[2]) + 1} CMD RUN \"{new_script}\" ")
        return [self.compile(sc1, translate_strings, script), self.compile(sc2, translate_strings, new_script)]

    def compile_single(self, translate_strings=True, debug_name=""):
        return self.compile(list(self.txt_file), translate_strings, debug_name)

    def _find_translation(self, original, line_number):
        if not self.strings_data:
            return None
        candidates = [row for row in self.strings_data
                      if row.get("source_text") == original and row.get("basic_line") == line_number]
        if not candidates:
            candidates = [row for row in self.strings_data if row.get("source_text") == original]
        if candidates and candidates[0].get("translation", "") != "":
            return candidates[0]["translation"]
        return None

    def _translate_string(self, token, line_number, translate_strings):
        original = token[1:-1].replace("−", "－").replace("－", "−")
        replacement = self._find_translation(original, line_number) if translate_strings else None
        if replacement is None:
            return token.encode("cp932", errors="ignore")

        if self.width_data is not None:
            new_string = '"'
            temporary = ""
            line_count = 0
            translated_lines = replacement.split("\n")
            for line_index, translated_line in enumerate(translated_lines):
                prepared = translated_line.replace("—", " - ").replace('"', '`')
                for word in prepared.split(" "):
                    word_length = sum(self.width_data[ord(char) - 0x20] for char in word)
                    temporary_length = sum(self.width_data[ord(char) - 0x20] for char in temporary)
                    if (temporary_length + word_length) > self.LINE_LIMIT or (
                            temporary_length > self.LINE_LIMIT and temporary[-2:-1] in {",", ".", "!", "?"}):
                        line_count += 1
                        new_string += temporary.rstrip()
                        temporary = ""
                        if line_count > 2:
                            line_count = 0
                            new_string = self.compile_end_string(new_string)
                            if len(new_string) >= 0xF0:
                                raise ValueError(f"String too long: {new_string}")
                            new_string += "\x3A\x8D\x20\x0E\xEC\x13\x3A\x42\x4D\x24\xF1\""
                        else:
                            new_string += "\\"
                    temporary += word + " "
                new_string += temporary.rstrip()
                if line_index < len(translated_lines) - 1:
                    line_count += 1
                    temporary = ""
                    if line_count > 2:
                        line_count = 0
                        new_string = self.compile_end_string(new_string)
                        if len(new_string) >= 0xF0:
                            raise ValueError(f"String too long: {new_string}")
                        new_string += "\x3A\x8D\x20\x0E\xEC\x13\x3A\x42\x4D\x24\xF1\""
                    else:
                        new_string += "\\"
            new_string = self.compile_end_string(new_string)
        else:
            new_string = '"' + replacement.replace("—", " - ").replace("\r", "").replace('"', '`').replace("\n", "\\") + '"'
        # Ruby String#bytes uses the source string encoding here (UTF-8).
        return new_string.encode("utf-8")

    def compile(self, txt_file, translate_strings=True, debug_name=""):
        lines = list(txt_file)
        if self.patch_data is not None:
            line_numbers = [self._line_parts(line)[0] for line in lines]
            for patch in self.patch_data:
                if str(patch["line"]) not in line_numbers:
                    lines.append(f'{patch["line"]} {patch.get("patchedLine", "")}')
        lines.sort(key=lambda line: int(self._line_parts(line)[0]))

        code = []
        for line_index, raw_line in enumerate(lines):
            statement = self._line_parts(raw_line)
            if self.patch_data is not None:
                matching = [patch for patch in self.patch_data if int(patch["line"]) == int(statement[0])]
                if len(matching) > 1:
                    raise ValueError(f"Duplicate patch lines found for line {statement[0]}")
                if matching:
                    replacement = str(matching[0].get("patchedLine", ""))
                    statement[1] = "" if replacement == "" else replacement + " "
            if statement[1] == "":
                continue

            statement[1] = statement[1].rstrip("\r\n")
            self.patch_statement(statement)
            if int(statement[0]) == 9999 and debug_name != f"{Const.MENU}.bas":
                line_code = [0xD6, 0x20, 0x11, 0x2C, 0x0F, 0x12, 0x3A, 0x91, 0x22] + [0x87] * 0x50 + [0x22, 0x3A, 0x8E]
            else:
                tokens = TOKEN_RE.split(statement[1])
                if tokens and tokens[-1] == "":
                    tokens = tokens[:-1]
                line_code = []
                self.is_data_token = False
                self.is_line_token = False
                for token in tokens:
                    if token is None or token == "":
                        continue
                    if token == "'":
                        line_code += [0x3A, 0x8F, 0xE9]
                        break
                    if token == "DATA":
                        line_code.append(0x84)
                        self.is_data_token = True
                    elif token in BASIC_RES_WORDS and not self.is_data_token:
                        value = BASIC_RES_WORDS.index(token) | 0x80
                        line_code.append(value)
                        self.check_line_token(value)
                    elif token in BASIC_EXT_WORDS and not self.is_data_token:
                        value = BASIC_EXT_WORDS.index(token) | 0x80
                        line_code += [0xFF, value]
                        self.check_line_token(value)
                    elif token.startswith('"'):
                        line_code.extend(self._translate_string(token, statement[0], translate_strings))
                    elif token.startswith("&O"):
                        line_code.append(0x0B)
                        line_code += n2b(int(token[2:], 8), 2)
                    elif token.startswith("&H"):
                        line_code.append(0x0C)
                        line_code += n2b(int(token[2:], 16), 2)
                    elif token.isdigit():
                        value = int(token)
                        if self.is_data_token:
                            line_code.extend(token.encode("ascii"))
                        elif self.is_line_token:
                            line_code.append(0x0E)
                            line_code += n2b(value, 2)
                        elif 0 <= value <= 9:
                            line_code.append(value + 0x11)
                        elif value < 0x100:
                            line_code += [0x0F, value]
                        else:
                            line_code.append(0x1C)
                            line_code += n2b(value, 2)
                    elif token == ":":
                        self.is_line_token = False
                        self.is_data_token = False
                        line_code.append(0x3A)
                    else:
                        for char in token:
                            value = ord(char)
                            if 0x20 <= value < 0x80:
                                line_code.append(value)
                            else:
                                raise ValueError(f"Unexpected symbol {char} at line {line_index}")

            line_code.append(0)
            line_number = n2b(int(statement[0]), 2)
            line_code = line_number + line_code
            next_address = n2b(len(code) + len(line_code) + 3, 2)
            code = code + next_address + line_code

        code += [0, 0, 0, 0]
        if debug_name:
            debug_dir = TEMP_PATH / "basic"
            debug_dir.mkdir(parents=True, exist_ok=True)
            decompiler = BasicDecompiler()
            decompiler.open_memory(code)
            (debug_dir / debug_name).write_text(decompiler.decompile()["mData"], encoding="utf-8")
        return code
