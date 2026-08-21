import os
from pathlib import Path


REPOSITORY_ROOT = Path(__file__).resolve().parent.parent
# The Python port works in its own source tree.  This keeps the Ruby source
# under reference/ untouched while allowing the tree to be pointed elsewhere
# for comparisons through MIRRORS_TOOLS_ROOT.
SOURCE_ROOT = Path(os.environ.get(
    "MIRRORS_TOOLS_ROOT",
    str(REPOSITORY_ROOT / "python_mirrors_tools"),
)).resolve()
TEMP_PATH = SOURCE_ROOT / "Temp"
GFX_PATH = SOURCE_ROOT / "GFX"
DATA_PATH = SOURCE_ROOT / "Data"
EXPORT_PATH = SOURCE_ROOT / "Export"
IMPORT_PATH = SOURCE_ROOT / "Import"
TOOLS_PATH = SOURCE_ROOT / "Tools"

E_FOLDER_ASM = EXPORT_PATH / "ASM"
E_FOLDER_ISO = EXPORT_PATH / "ISO"
E_FOLDER_FLOPPY = EXPORT_PATH / "Floppy"
E_FOLDER_BASIC = EXPORT_PATH / "BASIC"
E_FOLDER_DATA = EXPORT_PATH / "Data"
E_FOLDER_FILES = EXPORT_PATH / "Files"
E_FOLDER_STRINGS = EXPORT_PATH / "Strings"

I_FOLDER_BASIC = IMPORT_PATH / "BASIC"
I_FOLDER_DATA = IMPORT_PATH / "Data"
I_FOLDER_FLOPPY = IMPORT_PATH / "Floppy"
I_FOLDER_STRINGS = IMPORT_PATH / "Strings"
I_FOLDER_ISO = IMPORT_PATH / "ISO"
I_FOLDER_FILES = IMPORT_PATH / "Files"

ECSV_CDDATA = DATA_PATH / "e_cddata.csv"
ECSV_SCRIPTS = DATA_PATH / "e_scripts.csv"
EDATA_SCRIPTS = E_FOLDER_STRINGS / "stringsExport.csv"
ICSV_CDDATA = DATA_PATH / "i_cddata.csv"
ICSV_DISKS = DATA_PATH / "i_disks.csv"
ICSV_GFX = DATA_PATH / "i_gfx.csv"
ICSV_ASM = DATA_PATH / "asm.csv"
IDATA_SCRIPTS = I_FOLDER_STRINGS / "stringsImport.csv"
IDATA_BASICPATCH = DATA_PATH / "patchBasic.csv"

ORIGINAL_ISO_DATATRACK = E_FOLDER_ISO / "02 MIRR.iso"
PATCHED_ISO_DATATRACK = I_FOLDER_ISO / "02 MIRR.iso"

FONT_SCRIPT = GFX_PATH / "b1-8x16_font.png"
FONT_UI = GFX_PATH / "rcopt2-8x16_font.png"
FONT_MENU = GFX_PATH / "menu.png"

ASM_EXE = TOOLS_PATH / "vasmz80_std.exe"
DASM_EXE = TOOLS_PATH / "yazd.exe"
IASM_SOURCE = IMPORT_PATH / "ASM_Source"
IASM_BIN = IMPORT_PATH / "ASM"


class Const:
    DISK_SECTOR_SIZE = 0x400
    DISK_IMG_SIZE = DISK_SECTOR_SIZE * 400
    DISK_2HD_IMG_SIZE = DISK_SECTOR_SIZE * 1200
    INTRO = "intro"
    MENU = "menu"
    CD_SECTOR_DATA_START = 13350
    CD_SECTOR_SIZE = 2048
    BASIC_LINE_LIMIT = 362


BASIC_RES_WORDS = [
    "(ERR80)", "END", "FOR", "NEXT", "DATA", "INPUT", "DIM", "READ",
    "LET", "GOTO", "RUN", "IF", "RESTORE", "GOSUB", "RETURN", "REM",
    "STOP", "PRINT", "CLEAR", "LIST", "NEW", "ON", "WAIT", "DEF",
    "POKE", "CONT", "OUT", "LPRINT", "LLIST", "CONSOLE", "WIDTH", "ELSE",
    "TRON", "TROFF", "SWAP", "ERASE", "EDIT", "ERROR", "RESUME", "DELETE",
    "AUTO", "RENUM", "DEFSTR", "DEFINT", "DEFSNG", "DEFDBL", "LINE", "WHILE",
    "WEND", "CALL", "(ERRb2)", "(ERRb3)", "(ERRb4)", "WRITE", "COMMON", "CHAIN",
    "OPTION", "RANDOMIZE", "DSKO$", "OPEN", "FIELD", "GET", "PUT", "SET",
    "CLOSE", "LOAD", "MERGE", "FILES", "NAME", "KILL", "LSET", "RSET",
    "SAVE", "LFILES", "MON", "COLOR", "CIRCLE", "COPY", "CLS", "PSET",
    "PRESET", "PAINT", "TERM", "SCREEN", "BLOAD", "BSAVE", "LOCATE", "BEEP",
    "ROLL", "HELP", "(ERRda)", "KANJI", "TO", "THEN", "TAB(", "STEP",
    "USR", "FN", "SPC(", "NOT", "ERL", "ERR", "STRING$", "USING",
    "INSTR", "'", "VARPTR", "ATTR$", "DSKI$", "SRQ", "OFF", "INKEY$",
    ">", "=", "<", "+", "-", "*", "/", "^", "AND", "OR", "XOR", "EQV",
    "IMP", "MOD", "\\", "(ERRFF)",
]

# Keep the extended token table in the same order as the reference source.
BASIC_EXT_WORDS = [
    "(ERR80)", "LEFT$", "RIGHT$", "MID$", "SGN", "INT", "ABS", "SQR",
    "RND", "SIN", "LOG", "EXP", "COS", "TAN", "ATN", "FRE", "INP", "POS",
    "LEN", "STR$", "VAL", "ASC", "CHR$", "PEEK", "SPACE$", "OCT$", "HEX$",
    "LPOS", "CINT", "CSNG", "CDBL", "FIX", "CVI", "CVS", "CVD", "EOF",
    "LOC", "LOF", "FPOS", "MKI$", "MKS$", "MKD$", "(ERRaa)", "(ERRab)",
    "(ERRac)", "(ERRad)", "(ERRae)", "(ERRaf)", "(ERRb0)", "(ERRb1)",
    "(ERRb2)", "(ERRb3)", "(ERRb4)", "(ERRb5)", "(ERRb6)", "(ERRb7)",
    "(ERRb8)", "(ERRb9)", "(ERRba)", "(ERRbb)", "(ERRbc)", "(ERRbd)",
    "(ERRbe)", "(ERRbf)", "(ERRc0)", "(ERRc1)", "(ERRc2)", "(ERRc3)",
    "(ERRc4)", "(ERRc5)", "(ERRc6)", "(ERRc7)", "(ERRc8)", "(ERRc9)",
    "(ERRca)", "(ERRcb)", "(ERRcc)", "(ERRcb)", "(ERRcc)", "(ERRcf)",
    "DSKF", "VIEW", "WINDOW", "POINT", "CSRLIN", "MAP", "SEARCH", "MOTOR",
    "PEN", "DATE$", "COM", "KEY", "TIME$", "WBYTE", "RBYTE", "POLL", "ISET",
    "IEEE", "IRESET", "STATUS", "CMD", "(ERRe5)", "(ERRe6)", "(ERRe7)",
    "(ERRe8)", "(ERRe9)", "(ERRea)", "(ERReb)", "(ERRec)", "(ERRed)",
    "(ERRee)", "(ERRef)", "(ERRf0)", "(ERRf1)", "(ERRf2)", "(ERRf3)",
    "(ERRf4)", "(ERRf5)", "(ERRf6)", "(ERRf7)", "(ERRf8)", "(ERRf9)",
    "(ERRfa)", "(ERRfb)", "(ERRfc)", "(ERRfd)", "(ERRfe)", "(ERRff)",
]

LINE_TOKENS = [
    0x8C, 0xA8, 0xA9, 0xA7, 0xA4, 0xA6, 0xE4, 0x9F,
    0x8A, 0x93, 0x9C, 0x89, 0x8E, 0xDD, 0x8D,
]
