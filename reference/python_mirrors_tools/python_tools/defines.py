from pathlib import Path


class Paths:
    MAIN_PATH = Path(__file__).resolve().parent.parent
    TEMP_PATH = MAIN_PATH / "Temp"
    GFX_PATH = MAIN_PATH / "GFX"
    DATA_PATH = MAIN_PATH / "Data"
    EXPORT_PATH = MAIN_PATH / "Export"
    IMPORT_PATH = MAIN_PATH / "Import"
    TOOLS_PATH = MAIN_PATH / "Tools"

    EFolder_ASM = EXPORT_PATH / "ASM"
    EFolder_ISO = EXPORT_PATH / "ISO"
    EFolder_Floppy = EXPORT_PATH / "Floppy"
    EFolder_Basic = EXPORT_PATH / "BASIC"
    EFolder_Data = EXPORT_PATH / "Data"
    EFolder_Files = EXPORT_PATH / "Files"
    EFolder_Strings = EXPORT_PATH / "Strings"

    IFolder_Basic = IMPORT_PATH / "BASIC"
    IFolder_Data = IMPORT_PATH / "Data"
    IFolder_Floppy = IMPORT_PATH / "Floppy"
    IFolder_Strings = IMPORT_PATH / "Strings"
    IFolder_ISO = IMPORT_PATH / "ISO"
    IFolder_Files = IMPORT_PATH / "Files"

    ECSV_CDData = DATA_PATH / "e_cddata.csv"
    ECSV_Scripts = DATA_PATH / "e_scripts.csv"
    EData_Scripts = EFolder_Strings / "stringsExport.csv"

    ICSV_CDData = DATA_PATH / "i_cddata.csv"
    ICSV_Disks = DATA_PATH / "i_disks.csv"
    ICSV_GFX = DATA_PATH / "i_gfx.csv"
    ICSV_ASM = DATA_PATH / "asm.csv"

    IData_Scripts = IFolder_Strings / "stringsImport.csv"
    IData_BasicPatch = DATA_PATH / "patchBasic.csv"

    Original_ISO_DataTrack = EFolder_ISO / "02 MIRR.iso"
    Patched_ISO_DataTrack = IFolder_ISO / "02 MIRR.iso"

    Font_Script = GFX_PATH / "b1-8x16_font.png"
    Font_UI = GFX_PATH / "rcopt2-8x16_font.png"
    Font_Menu = GFX_PATH / "menu.png"

    ASM_Exe = TOOLS_PATH / "vasmz80_std.exe"
    DASM_Exe = TOOLS_PATH / "yazd.exe"

    IASM_Source = IMPORT_PATH / "ASM_Source"
    IASM_Bin = IMPORT_PATH / "ASM"

    ISO_ORIGINAL = MAIN_PATH / "ISO_Original"
    ISO_PATCHED = MAIN_PATH / "ISO_Patched"
    DISKS_PATH_PATCHED = MAIN_PATH / "Disks_Patched"

    D88EXT = ".d88"


class Const:
    Disk_SectorSize = 0x400
    Disk_ImgSize = Disk_SectorSize * 400
    Disk_2HD_ImgSize = Disk_SectorSize * 1200

    Const_Intro = "intro"
    Const_Menu = "menu"

    CD_Sector_DataStart = 13350
    CD_Sector_Size = 2048

    BasicResWords = [
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

    BasicExtWords = [
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

