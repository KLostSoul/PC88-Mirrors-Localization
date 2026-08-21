require "csv"
require "pp"
require 'open3'
require 'fileutils'
require "chunky_png"

module Paths
  MAIN_PATH = File.expand_path(__dir__ + '/..')
  TEMP_PATH = File.expand_path(__dir__ + '/../Temp')
  GFX_PATH = File.expand_path(__dir__ + '/../GFX')
  DATA_PATH = File.expand_path(__dir__ + '/../Data')
  EXPORT_PATH = File.expand_path(__dir__ + '/../Export')
  IMPORT_PATH = File.expand_path(__dir__ + '/../Import')
  TOOLS_PATH = File.expand_path(__dir__ + '/../Tools')

  EFolder_ASM = EXPORT_PATH + '/ASM/'
  EFolder_ISO = EXPORT_PATH + '/ISO/'
  EFolder_Floppy = EXPORT_PATH + '/Floppy/'
  EFolder_Basic = EXPORT_PATH + '/BASIC/'
  EFolder_Data = EXPORT_PATH + '/Data/'
  EFolder_Files = EXPORT_PATH + '/Files/'
  EFolder_Strings = EXPORT_PATH + '/Strings/'

  IFolder_Basic = IMPORT_PATH + '/BASIC/'
  IFolder_Data = IMPORT_PATH + '/Data/'
  IFolder_Floppy = IMPORT_PATH + '/Floppy/'
  IFolder_Strings = IMPORT_PATH + '/Strings/'
  IFolder_ISO = IMPORT_PATH + '/ISO/'
  IFolder_Files = IMPORT_PATH + '/Files/'

  # Export control CSVs
  ECSV_CDData = DATA_PATH + '/' + 'e_cddata.csv'
  ECSV_Scripts = DATA_PATH + '/' + 'e_scripts.csv'

  # Exported strings
  EData_Scripts = EFolder_Strings + 'stringsExport.csv'

  ICSV_CDData = DATA_PATH + '/' + 'i_cddata.csv'
  ICSV_Disks = DATA_PATH + '/' + 'i_disks.csv'
  ICSV_GFX = DATA_PATH + '/' + 'i_gfx.csv'

  ICSV_ASM = DATA_PATH + '/' + 'asm.csv'


  # Imported strings
  IData_Scripts = IFolder_Strings + 'stringsImport.csv'
  IData_BasicPatch = DATA_PATH + '/' + 'patchBasic.csv'

  Original_ISO_DataTrack = EFolder_ISO + "02 MIRR.iso"
  Patched_ISO_DataTrack = IFolder_ISO + "02 MIRR.iso"

  Font_Script = GFX_PATH + '/b1-8x16_font.png'
  Font_UI = GFX_PATH + '/rcopt2-8x16_font.png'
  Font_Menu = GFX_PATH + '/menu.png'

  ASM_Exe = TOOLS_PATH + '/' + 'vasmz80_std.exe'
  DASM_Exe = TOOLS_PATH + '/' + 'yazd.exe'

  IASM_Source = IMPORT_PATH + '/ASM_Source/'
  IASM_Bin = IMPORT_PATH + '/ASM/'

  ISO_ORIGINAL = File.expand_path(__dir__ + '/../ISO_Original')
  ISO_PATCHED = File.expand_path(__dir__ + '/../ISO_Patched')
  DISKS_PATH_PATCHED = File.expand_path(__dir__ + '/../Disks_Patched')

  D88EXT = '.d88'

  # Data files
end

module Const
  Disk_SectorSize = 0x400
  Disk_ImgSize = Disk_SectorSize * 400
  Disk_2HD_ImgSize = Disk_SectorSize * 1200

  # Fixed Basic scripts
  Const_Intro = 'intro'
  Const_Menu = 'menu'

  CD_Sector_DataStart = 13350
  CD_Sector_Size = 2048

  BasicResWords = [
      '(ERR80)' , 'END' ,		 		'FOR' ,		 	'NEXT' ,        # 0x80
      'DATA' ,		'INPUT' ,	 		'DIM' ,		 	'READ' ,
      'LET' ,		 	'GOTO' ,			'RUN' ,		 	'IF' ,
      'RESTORE' ,	'GOSUB' ,	 		'RETURN' ,	'REM' ,
      'STOP' ,		'PRINT' ,	 		'CLEAR' ,	 	'LIST' ,        # 0x90
      'NEW' ,		  'ON' ,		 		'WAIT' ,	 	'DEF' ,
      'POKE' ,		'CONT' ,			'OUT' ,		 	'LPRINT' ,
      'LLIST' ,		'CONSOLE' ,		'WIDTH' ,	 	'ELSE' ,
      'TRON' ,		'TROFF' ,	 		'SWAP' ,		'ERASE' ,       # 0xa0
      'EDIT' ,		'ERROR' ,	 		'RESUME' ,	'DELETE' ,
      'AUTO' , 		'RENUM' , 		'DEFSTR' , 	'DEFINT',
      'DEFSNG' ,	'DEFDBL' ,		'LINE' ,		'WHILE' ,
      'WEND' ,		'CALL' ,			'(ERRb2)' ,	'(ERRb3)' ,     # 0xb0
      '(ERRb4)' ,	'WRITE' ,	 		'COMMON' ,	'CHAIN' ,
      'OPTION' ,	'RANDOMIZE',	'DSKO$' ,	 	'OPEN' ,
      'FIELD' ,	 	'GET' ,		 		'PUT' ,		 	'SET' ,
      'CLOSE' ,	 	'LOAD' ,			'MERGE' ,	 	'FILES' ,        # 0xc0
      'NAME' ,		'KILL' ,			'LSET' ,		'RSET' ,
      'SAVE' ,		'LFILES' ,		'MON' ,		 	'COLOR' ,
      'CIRCLE' ,	'COPY' ,			'CLS' ,		 	'PSET' ,
      'PRESET' ,	'PAINT' ,	 		'TERM' ,	 	'SCREEN' ,       # 0xd0
      'BLOAD' ,	 	'BSAVE' ,	 		'LOCATE', 	'BEEP' ,
      'ROLL' ,		'HELP' ,			'(ERRda)' ,	'KANJI' ,
      'TO' ,		 	'THEN' ,			'TAB(' ,		'STEP' ,
      'USR' ,		 	'FN' ,		 		'SPC(' ,		'NOT' ,        	# 0xe0
      'ERL' ,		 	'ERR' ,		 		'STRING$' ,	'USING' ,
      'INSTR' ,	 	'\'' ,		 		'VARPTR' ,	'ATTR$' ,
      'DSKI$' ,	 	'SRQ' ,		 		'OFF' ,			'INKEY$' ,
      '>' ,		 	 	'=' ,		 			'<' ,		 		'+' ,            # 0xf0
      '-' ,		 	 	'*' ,		 			'/' ,		 		'^' ,
      'AND' ,		 	'OR' ,		 		'XOR' ,		 	'EQV' ,
      'IMP' ,		 	'MOD' ,		 	  '\\' ,      '(ERRFF)' ,
  ].freeze
  # Extended
  BasicExtWords = [
      '(ERR80)' ,	'LEFT$' ,	  'RIGHT$' ,	 	'MID$' ,        # 0x80
      'SGN' ,		 	'INT' ,		 	'ABS' ,		 		'SQR' ,
      'RND' ,		 	'SIN' ,		 	'LOG' ,		 		'EXP' ,
      'COS' ,		 	'TAN' ,		 	'ATN' ,		 		'FRE' ,
      'INP' ,		 	'POS' ,		 	'LEN' ,		 		'STR$' ,        # 0x90
      'VAL' ,		 	'ASC' ,		 	'CHR$' ,		 	'PEEK' ,
      'SPACE$' ,	'OCT$' ,		'HEX$' ,		 	'LPOS' ,
      'CINT' ,		'CSNG' ,		'CDBL' ,		 	'FIX' ,
      'CVI' ,		 	'CVS' ,		 	'CVD' ,		 		'EOF' ,         # 0xa0
      'LOC' ,		 	'LOF' ,		 	'FPOS' ,		 	'MKI$' ,
      'MKS$' ,		'MKD$' ,		'(ERRaa)' ,		'(ERRab)' ,
      '(ERRac)' ,	'(ERRad)',  '(ERRae)' ,   '(ERRaf)' ,
      '(ERRb0)' ,	'(ERRb1)',  '(ERRb2)' ,   '(ERRb3)' ,            # 0xb0
      '(ERRb4)' ,	'(ERRb5)',  '(ERRb6)' ,   '(ERRb7)' ,
      '(ERRb8)' ,	'(ERRb9)',  '(ERRba)' ,   '(ERRbb)' ,
      '(ERRbc)' ,	'(ERRbd)',  '(ERRbe)' ,   '(ERRbf)' ,
      '(ERRc0)' ,	'(ERRc1)',  '(ERRc2)' ,   '(ERRc3)' ,            # 0xc0
      '(ERRc4)' ,	'(ERRc5)',  '(ERRc6)' ,   '(ERRc7)' ,
      '(ERRc8)' ,	'(ERRc9)',  '(ERRca)' ,   '(ERRcb)' ,
      '(ERRcc)' ,	'(ERRcb)',  '(ERRcc)' ,   '(ERRcf)' ,
      'DSKF' ,		'VIEW' ,		'WINDOW' ,	 	'POINT' ,        # 0xd0
      'CSRLIN' ,	'MAP' ,		 	'SEARCH' ,	 	'MOTOR' ,
      'PEN' ,		 	'DATE$' ,	 	'COM' ,		 	  'KEY' ,
      'TIME$' ,	  'WBYTE' ,	 	'RBYTE' ,	  	'POLL' ,
      'ISET' ,		'IEEE' ,		'IRESET' ,	 	'STATUS' ,       # 0xe0
      'CMD' ,		 	'(ERRe5)' , '(ERRe6)' ,	  '(ERRe7)' ,
      '(ERRe8)' , '(ERRe9)' , '(ERRea)' ,	  '(ERReb)' ,
      '(ERRec)' , '(ERRed)' , '(ERRee)' ,	  '(ERRef)' ,
      '(ERRf0)' , '(ERRf1)' , '(ERRf2)' ,	  '(ERRf3)' ,            # 0xf0
      '(ERRf4)' , '(ERRf5)' , '(ERRf6)' ,	  '(ERRf7)' ,
      '(ERRf8)' , '(ERRf9)' , '(ERRfa)' ,	  '(ERRfb)' ,
      '(ERRfc)' , '(ERRfd)' , '(ERRfe)' ,	  '(ERRff)' ,
  ].freeze
end


