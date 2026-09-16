import re

from .defines import Const, Paths
from .util import Util


class BasicCompiler:
    LineLimit = 362

    def __init__(self, _stringsData=None, _patchData=None, _widthData=None):
        self.initialize(_stringsData, _patchData, _widthData)

    def initialize(self, _stringsData=None, _patchData=None, _widthData=None):
        self.compFile = []
        self.regOps = {}
        self.extOps = {}
        self.txtFile = ""

        for i, x in enumerate(Const.BasicResWords):
            self.regOps[x] = r"\x%x" % (i + 0x80)
        for i, x in enumerate(Const.BasicExtWords):
            self.extOps[x] = r"\x%x" % (i + 0x80)

        self.LineTokens = [
            0x8C, 0xA8, 0xA9, 0xA7, 0xA4, 0xA6, 0xE4, 0x9F,
            0x8A, 0x93, 0x9C, 0x89, 0x8E, 0xDD, 0x8D,
        ]

        self.stringsData = _stringsData
        self.patchData = _patchData
        self.widthData = _widthData

    def openFile(self, _filename):
        with open(_filename, "r", encoding="utf-8") as handle:
            self.txtFile = handle.readlines()

    def isNumber(self, _str):
        return re.fullmatch(r"\d+", _str)

    def checkLineToken(self, _token):
        self.isLineToken = _token in self.LineTokens

    def patchStatement(self, _statement):
        _statement[1] = _statement[1].replace("COMMON FM", "COMMON STOP")
        _statement[1] = _statement[1].replace(
            "COMMON FP", "COMMON STOP:COMMON FP"
        )

    def _line_number(self, line):
        return re.split(r"\s{1}", line, maxsplit=1)[0].strip()

    def _ruby_split(self, text, regex):
        tokens = []
        last = 0
        for match in regex.finditer(text):
            tokens.append(text[last:match.start()])
            for group in match.groups():
                if group is not None:
                    tokens.append(group)
            last = match.end()
        # Ruby String#split drops a trailing empty field. The caller then
        # follows the original tokens[0..-2] behavior, which removes the
        # final captured whitespace/boundary token as well.
        if last < len(text):
            tokens.append(text[last:])
        return tokens

    def splitAndCompile(self, _script, _splitArray, _translateStrings=True):
        newScript = _splitArray[0]
        sc1nums = [int(_splitArray[1]), int(_splitArray[2])]
        sc2nums = [int(_splitArray[3]), int(_splitArray[4])]
        sc1 = [
            line for line in self.txtFile
            if (
                int(self._line_number(line)) < sc2nums[0]
                or int(self._line_number(line)) > sc2nums[1]
            )
        ]
        sc2 = [
            line for line in self.txtFile
            if (
                int(self._line_number(line)) < sc1nums[0]
                or int(self._line_number(line)) > sc1nums[1]
            )
        ]
        sc1.append("%d CMD RUN \"%s\" " %
                   (int(_splitArray[2]) + 1, newScript))
        bin1 = self.compile(sc1, _translateStrings, _script)
        bin2 = self.compile(sc2, _translateStrings, newScript)
        return [bin1, bin2]

    def compileSingle(self, _translateStrings=True, _debugName=""):
        return self.compile(self.txtFile, _translateStrings, _debugName)

    def compile_EndString(self, _newStr):
        return _newStr + '"'

    def _lookup_translation(self, original, line):
        if self.stringsData is None:
            return None
        replace = [
            s for s in self.stringsData
            if s.get("source_text") == original
            and s.get("basic_line") == line
        ]
        if not replace:
            replace = [
                s for s in self.stringsData
                if s.get("source_text") == original
            ]
        if replace and replace[0].get("translation", "") != "":
            return replace[0].get("translation", "")
        return None

    def _font_width(self, text):
        return sum(self.widthData[ord(char) - 0x20] for char in text)

    def _encode_shift_jis(self, text):
        # Ruby uses replace: "" for invalid/undefined characters here.
        return list(text.encode("shift_jis", errors="ignore"))

    def _encode_ruby_string_bytes(self, text):
        """Encode a Ruby string that may contain literal BASIC byte escapes.

        Ruby changes the encoding of the literal control-byte fragment used
        by the VWF line splitter to ASCII-8BIT.  Python must preserve those
        bytes instead of UTF-8 expanding them (for example, 0x8D -> C2 8D).
        Other Unicode characters remain UTF-8, matching Ruby's String#bytes
        for the translation text.
        """
        raw_bytes = {0x0E, 0x13, 0x8D, 0xEC, 0xF1}
        encoded = bytearray()
        for char in text:
            code = ord(char)
            if code in raw_bytes:
                encoded.append(code)
            else:
                encoded.extend(char.encode("utf-8"))
        return list(encoded)

    def _compile_string(self, token, line, translateStrings):
        original = token[1:-1]
        original = original.replace("−", "－").replace("－", "−")
        newStr = ""

        translation = None
        if self.stringsData is not None and translateStrings:
            translation = self._lookup_translation(original, line)

        if translation is not None:
            if self.widthData is not None:
                newStr += '"'
                tmpString = ""
                trLines = translation.split("\n")
                lineCount = 0
                for ind, tr in enumerate(trLines):
                    prepStr = tr.replace("—", " - ").replace('"', chr(96))
                    splitStr = prepStr.split()
                    for word in splitStr:
                        wordLength = self._font_width(word)
                        tmpStringLength = self._font_width(tmpString)
                        punctuation = (
                            len(tmpString) >= 2
                            and tmpString[-2] in ",.!?"
                        )
                        if (
                            (tmpStringLength + wordLength) > self.LineLimit
                            or (
                                tmpStringLength > self.LineLimit
                                and punctuation
                            )
                        ):
                            lineCount += 1
                            newStr += tmpString.rstrip()
                            tmpString = ""
                            if lineCount > 2:
                                lineCount = 0
                                newStr = self.compile_EndString(newStr)
                                if len(newStr) >= 0xF0:
                                    raise ValueError("String too long: %s" %
                                                     newStr)
                                newStr += (
                                    "\x3a\x8d\x20\x0e\xec\x13"
                                    "\x3a\x42\x4d\x24\xf1"
                                )
                                newStr += '"'
                            else:
                                newStr += "\\"
                        tmpString += word + " "

                    newStr += tmpString.rstrip()
                    if ind < len(trLines) - 1:
                        lineCount += 1
                        tmpString = ""
                        if lineCount > 2:
                            lineCount = 0
                            newStr = self.compile_EndString(newStr)
                            if len(newStr) >= 0xF0:
                                raise ValueError("String too long: %s" %
                                                 newStr)
                            newStr += (
                                "\x3a\x8d\x20\x0e\xec\x13"
                                "\x3a\x42\x4d\x24\xf1"
                            )
                            newStr += '"'
                        else:
                            newStr += "\\"
                newStr = self.compile_EndString(newStr)
            else:
                newStr += '"'
                newStr += (
                    translation.replace("—", " - ")
                    .replace("\r", "")
                    .replace('"', chr(96))
                    .replace("\n", "\\")
                )
                newStr = self.compile_EndString(newStr)
        else:
            return self._encode_shift_jis(token)

        return self._encode_ruby_string_bytes(newStr)

    def compile(self, _txtFile, _translateStrings, _debugName):
        if self.patchData is not None:
            lineNums = [self._line_number(x) for x in _txtFile]
            for patch in self.patchData:
                if patch.get("line") not in lineNums:
                    _txtFile.append(
                        patch.get("line", "") + " "
                        + str(patch.get("patchedLine", ""))
                    )

        indexed = list(enumerate(_txtFile))
        indexed.sort(
            key=lambda item: (int(self._line_number(item[1])), -item[0])
        )
        _txtFile[:] = [line for _index, line in indexed]

        binCode = []
        debugName = _debugName
        debugStrings = {}
        self.isDataToken = False
        self.isLineToken = False

        regex = re.compile(
            r"""
            (\".+?\")
            |(\-)
            |(\,)
            |(\=)
            |(\:)
            |(\*)
            |([A-Z]+?\$)
            |(&H[0-9A-F]{4})
            |(&H[0-9A-F]{2})
            |(&H[0-9A-F]{1})
            |(&O[0-7]{3})
            |(\s)
            |\b
            """,
            re.X,
        )

        for lnum, line in enumerate(_txtFile):
            statement = re.split(r"\s{1}", line, maxsplit=1)
            if self.patchData is not None:
                patched = [
                    i for i in self.patchData
                    if int(i.get("line", 0)) == int(statement[0])
                ]
                if patched:
                    if len(patched) == 1:
                        patchStr = str(patched[0].get("patchedLine", ""))
                        if patchStr == "":
                            statement[1] = ""
                        else:
                            statement[1] = patchStr + " "
                    else:
                        raise ValueError(
                            "Duplicate patch lines found for line %d" %
                            int(statement[0])
                        )

            if statement[1] == "":
                continue

            self.patchStatement(statement)
            if (
                int(statement[0]) == 9999
                and debugName != Const.Const_Menu + ".bas"
            ):
                binLine = [
                    0xD6, 0x20, 0x11, 0x2C, 0x0F, 0x12, 0x3A, 0x91,
                    0x22,
                ] + [0x87] * 0x50 + [0x22, 0x3A, 0x8E]
            else:
                tokens = self._ruby_split(statement[1], regex)
                binLine = []
                commentIndex = -1
                self.isDataToken = False
                self.isLineToken = False

                for i, token in enumerate(tokens[:-1]):
                    if token == "":
                        continue
                    if token == "'":
                        binLine += [0x3A, 0x8F, 0xE9]
                        commentIndex = i + 1
                        break
                    if token == "DATA":
                        binLine.append(0x84)
                        self.isDataToken = True
                        continue
                    if token in Const.BasicResWords and not self.isDataToken:
                        tokenValue = Const.BasicResWords.index(token) | 0x80
                        binLine.append(tokenValue)
                        self.checkLineToken(tokenValue)
                        continue
                    if token in Const.BasicExtWords and not self.isDataToken:
                        extValue = Const.BasicExtWords.index(token) | 0x80
                        binLine += [0xFF, extValue]
                        self.checkLineToken(extValue)
                        continue
                    if token.startswith('"'):
                        binLine += self._compile_string(
                            token, statement[0], _translateStrings
                        )
                        continue
                    if token.startswith("&O"):
                        binLine.append(0x0B)
                        binLine += Util.n2b(int(token[2:], 8), 2)
                        continue
                    if token.startswith("&H"):
                        binLine.append(0x0C)
                        binLine += Util.n2b(int(token[2:], 16), 2)
                        continue
                    if re.fullmatch(r"\d+", token):
                        number = int(token)
                        if self.isDataToken:
                            binLine += list(token.encode())
                        elif self.isLineToken:
                            binLine.append(0x0E)
                            binLine += Util.n2b(number, 2)
                        elif 0 <= number <= 9:
                            binLine.append(number + 0x11)
                        elif number < 0x100:
                            binLine += [0x0F, number]
                        else:
                            binLine.append(0x1C)
                            binLine += Util.n2b(number, 2)
                        continue
                    if token == ":":
                        self.isLineToken = False
                        self.isDataToken = False
                        binLine.append(0x3A)
                        continue

                    for char in token:
                        if 0x20 <= ord(char) < 0x80:
                            binLine.append(ord(char))
                        else:
                            raise ValueError(
                                "Unexpected symbol %s at line %d" %
                                (char, lnum)
                            )

            binLine.append(0)
            lineNum = Util.n2b(int(statement[0]), 2)
            binLine[0:0] = lineNum
            lineAddr = Util.n2b(len(binCode) + len(binLine) + 3, 2)
            binLine[0:0] = lineAddr
            binCode += binLine

        binCode += [0, 0, 0, 0]

        if debugName != "":
            from .basic_decompiler import BasicDecompiler

            basicDec = BasicDecompiler()
            basicDec.openMemory(binCode)
            decomp = basicDec.decompile()
            debugPath = Paths.TEMP_PATH / "basic" / debugName
            debugPath.parent.mkdir(parents=True, exist_ok=True)
            debugPath.write_text(decomp["mData"], encoding="utf-8")

        return binCode
