class DataExporter
  def initialize(_fileName)
    @cdFile = FileStreamer.new(_fileName)
  end

  def readSectors(_secNum, _count = 1)
    @cdFile.readBytes(_count * Const::CD_Sector_Size, _secNum * Const::CD_Sector_Size)
  end

  def readData(_offset, _size)
    @cdFile.readBytes(_size, _offset)
  end

  def exportStrings(_disk, _script, _strData)
    _strData.each do |line, strs|
      strs.each { |s|
        exportData = []
        exportData << _disk << _script << line << s[0] << s[1] << ""
        @stringCSV << exportData
      }
    end
  end

  def extractData()
    cdData = Util.CSV2hashArray(Paths::ECSV_CDData)
    cdData.each do |d|
      raw = readData(d['offset'].to_i(16), d['size'].to_i(16))
      fileName = Paths::EXPORT_PATH + '/' + d['path'] + '/' + d['filename'] + '.raw'
      IO.binwrite(fileName, raw.pack('c*'))
      if d['type'] == 'basic' # decompile it
        basic = BasicDecompiler.new
        basic.openMemory(raw)
        decomp = basic.decompile()
        IO.binwrite(Paths::EFolder_Basic + d['filename'] + '.bas', decomp[:mData])
        exportStrings(d['filename'], d['filename'], decomp[:mStrings])
      elsif d['type'] == 'asm' # disassemble it
        asmName = Paths::EFolder_ASM + d['filename'] + '.asm'
        Open3.popen3('"' + Paths::DASM_Exe + '" "' + fileName + '" "' + asmName + '" --hex:x --xref --lowercase --addr:' + d['loadAddr'])
      end
    end
  end

  def exportFloppyData()
    floppyDisks = Util.CSV2hashArray(Paths::ECSV_CDData).select { |i| i['type'] == 'floppy' }
    floppyDisks.each do |f|
      floppyMan = FloppyMan.new()
      floppyMan.open(f['filename'])
      floppyMan.extractAll
    end
  end

  def exportBasicScripts
    basicScripts = Util.CSV2hashArray(Paths::ECSV_Scripts)
    basicScripts.each do |b|
      basicFile = BasicDecompiler.new()
      basicRaw = IO.binread(Paths::EFolder_Files + b['disk'] + '/' + b['script']).bytes
      p 'Decompiling ' + b['script']
      fileSize = Util.b2n(basicRaw[4, 2])
      basicFile.openMemory(basicRaw[7, fileSize])

      decompData = basicFile.decompile()
      IO.binwrite(Paths::EFolder_Basic + b['script'], decompData[:mData])
      exportStrings(b['disk'], b['script'], decompData[:mStrings])
    end
  end

  def export()
    headers = ["disk_num", "script_num", "basic_line", "string_num", "source_text", "translation"]
    @stringCSV = CSV.open(Paths::EData_Scripts, "w", :write_headers => true, :headers => headers, :force_quotes => true, :col_sep => ";", :encoding => "bom|utf-8")
    extractData
    exportFloppyData
    exportBasicScripts
    @stringCSV.close
  end
end