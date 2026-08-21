class DataImporter
  def initialize(_translate = true)
    @stringsData = CSV.read(Paths::IData_Scripts, :encoding => "utf-8", :quote_char => '"', :headers => true, :col_sep => "\t").map { |p| p.to_h }
    @stringsData.each do |str|
      str['source_text'].gsub!('−', '－')
      str['source_text'].gsub!('－', '−')
    end
    @basicPatch = Util.CSV2hashArray(Paths::IData_BasicPatch)
    @diskData = Util.CSV2hashArray(Paths::ICSV_Disks)
    @scriptData = Util.CSV2hashArray(Paths::ECSV_Scripts)
    @diskMans = {}

    @enableTranslation = _translate

    createDiskMans()
  end

  def createDiskMans()
    @diskData.each do |d|
      if @diskMans[d['disk']] == nil
        diskMan = FloppyMan.new
        diskMan.open(d['disk'])
        @diskMans[d['disk']] = diskMan
      end
    end
  end

  def basic_addPatchLine(_patch, _disk, _script, _line, _code)
    _patch.push ({
        "disk" => _disk,
        "script" => _script,
        "line" => _line.to_s,
        "patchedLine" => _code
    })
  end

  def convertCDoffset_toAbsolute(_offset)
    return _offset / 0x800 + Const::CD_Sector_DataStart
  end

  def basic_applyVWFHandler_Opening(_patch, _scdata)
    basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],
                       10010,
                       "CMD SCREEN 1:GOSUB 2400:BN=&HD007:BM$=\"This story is a work of fiction.\":GOSUB 5100")
    basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],
                       5100,
                       "CMD WIDTH BN,&H40,7:CMD KANJI BM$:BN=BN+&H0640:RETURN")
    basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],
                       5120,
                       "GOSUB 2400:CMD WIDTH &HD504,&H60,7:CMD KANJI BM$")
    basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],
                       5130,
                       "CMD WIDTH &HDF04,&H60,7:CMD KANJI BM2$:GOSUB 5110:RETURN")
    basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],
                       5140,
                       "GOSUB 2400:CMD WIDTH &HD50A,&H60,6:CMD KANJI BM$")
    basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],
                       5150,
                       "CMD WIDTH &HDC90,&H60,7:CMD KANJI BM2$")
    basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],
                       5160,
                       "CMD WIDTH &HE417,&H60,7:CMD KANJI BM3$:GOSUB 5110:RETURN")
  end

  def basic_applyVWFHandler(_patch, _scdata, _line = 5000)
    #basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],
    #                   1,
    #                   "")
    basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],
                       _line + 1,
                       "POKE &HB401,0:POKE &H92DC,1:BN=&HED93:GOSUB %d" % [_line + 40])
    basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],
                       _line + 5,
                       "FOR K1=1 TO LEN(BM$):K$=MID$(BM$,K1,1):IF ASC(K$)=92 THEN GOSUB %d:GOTO %d:ELSE %d:" % [_line + 44, _line + 20, _line + 10])
    basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],
                       _line + 10,
                       "CMD WIDTH BN,&H60,7:POKE &HB400,1:CMD KANJI K$:KN=KN+1:")
    basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],
                       _line + 20,
                       "GOSUB %d:FOR L=1 TO PEEK(&HE3FF):NEXT:NEXT:RETURN" % [_line + 41])
    basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],
                       _line + 40,
                       "POKE &HB40B,(BN\\256)AND 255:POKE &HB40A,BN AND 255:KN=BN:RETURN")
    basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],
                       _line + 41,
                       "SZ=PEEK(&HE3FE):IF SZ=0 THEN POLL P,&H0410,&HD214:RETURN")
    basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],
                       _line + 42,
                       "IF SZ=1 THEN FOR K2=0 TO 2:BEEP 1:BEEP 0:NEXT:RETURN")
    basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],
                       _line + 43,
                       "RETURN")
    basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],
                       _line + 44,
                       "BN=BN+&H50*14:GOSUB %d:POKE &HB401,0:RETURN" %[_line + 40])
    basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],
                       _line + 105,
                       "BM$=\">>>\":CMD WIDTH &HF9CD,&H10,7:CMD KANJI BM$")
    basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],
                       _line + 410,
                       "POKE &H92DC,2:BN=&HEF42:CN=0:FOR I=1 TO CM:CMD WIDTH BN,&H40,7:CMD KANJI CM$(I):BN=BN+&H50*11:NEXT:POKE &H92DC,1")
    basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],
                       _line + 420,
                       "LINE(110,154+CN*11)-(512,164+CN*11),7,BF,XOR:CN2=CN")
    basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],
                       _line + 440,
                       "LINE(110,154+CN2*11)-(512,164+CN2*11),7,BF,XOR")
  end

  def basic_applySavePatch(_patch, _scdata, _diskData)
    # modify save system to remove the need for Save disk
    basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],
                       10000,
                       "BM$=\"Save game? (press Y or N)\":GOSUB 5000")
    basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],
                       10040,
                       "BM$=\"Select slot (1-9, ESC to exit):\":GOSUB 5000")
    basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],
                       10049,
                       "S$=INKEY$:IF S$=\"\" THEN 10049")
    basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],
                       10050,
                       "IF S$=CHR$(27) THEN RETURN")
    basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],
                       10060,
                       "TH=VAL(S$):IF TH>=1 AND TH<=9 THEN 10070:ELSE 10049")
    basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],
                       10070,
                       "POKE &HE302,%d:POKE &HE303,%d:" % [_diskData['scriptN'], _diskData['scribtSub']])
    basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],
                       10080,
                       "TU=&H31:TU=TU+TH:CMD WRITE &H00,TU,&H01,&HE300")
    basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],
                       10090,
                       "BM$=\"Done. Press ENTER to continue.\":GOSUB 5100:RETURN")
    basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],10110,"")
    basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],10120,"")
    basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],10130,"")
    basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],10140,"")
    basic_addPatchLine(_patch, _scdata['disk'], _scdata['script'],10150,"")


  end
  
  def basic_applyCDswitchPatch(_sc, _basicPatch, _diskData)
    loadData = eval(_diskData['loadLineNum'])
    nextScript = _diskData['nextScript'].split(',')
    raise "Wrong load data for %s" % _sc['script'] if loadData.nil? || (loadData.length != nextScript.length)
    nextScript.each_with_index { |nscr, ind|
      nscrData = @diskData.select { |i| i['script'] == nscr }.first
      if (nscrData['diskNum'] != _diskData['diskNum']) # load new disk
        patchLines = [
            "ISET X:COMMON FO:GOSUB 5200:BM$=\"Press any key to start reading data from CD-ROM.\":GOSUB 5100",
            "COMMON STOP:CMD SCREEN 1:BM$=\"Reading data...\":GOSUB 5000",
            "COMMON COPY &H01,%d" % convertCDoffset_toAbsolute(nscrData['trackCD'].to_i(16)),
            "POKE &H9089,%d:CMD SET:CMD SCREEN 0:CMD RUN\"%s\"" % [nscrData['subDisk'], nscrData['script']]

        ]
        loadData[ind].each_with_index { |ldLine, lind|
          basic_addPatchLine(_basicPatch, _sc['disk'], _sc['script'],
                             ldLine,
                             patchLines[lind])
        }
      elsif (nscrData['subDisk'] != _diskData['subDisk']) # switch disk subimage
        patchLines = [
            "ISET X:COMMON FO:GOSUB 5200:FOR I=0 TO 3000:NEXT",
            "COMMON STOP",
            "'",
            "POKE &H9089,%d:CMD SET:CMD SCREEN 0:CMD RUN\"%s\"" % [nscrData['subDisk'], nscrData['script']]

        ]
        loadData[ind].each_with_index { |ldLine, lind|
          basic_addPatchLine(_basicPatch, _sc['disk'], _sc['script'],
                             ldLine,
                             patchLines[lind])
        }
      end
    }
  end

  def basic_addHeader(_basic)
    binSize = _basic.length
    header = []
    header.push 0 # dummy byte
    header += Util.n2b(binSize, 2, false)

    header.push 0
    header.push 0 # load address
    header.push (binSize * 1.0 / Const::Disk_SectorSize).ceil
    header.push 1

    header.each { |x| _basic.unshift(x) }
    p 'Compiled size: %d/12288 (%3.2f %%)' % [binSize, binSize * 100.0 / 12288]
    if binSize > 12288
      p 'WARNING: exceeding maximum size'
    end
    return _basic
  end

  def translateBasicScripts()
    @scriptData.each do |sc|
      strings = @stringsData.select { |i| i['script_num'] == sc['script'] }
      basicPatch = @basicPatch.select { |i| i['script'] == sc['script'] }
      diskData = @diskData.select { |i| i['script'] == sc['script'] }.first

      if @enableTranslation && sc['script'] == 'NO0' # hack for opening script
        basic_applyVWFHandler(basicPatch, sc, 9000)
        basic_applyVWFHandler_Opening(basicPatch, sc)
      elsif @enableTranslation && sc['commonPatch'] == 'true'
        basic_applyVWFHandler(basicPatch, sc)
      end
      if sc['allowSave'] == 'true'
        basic_applySavePatch(basicPatch, sc, diskData)
      end
      if diskData['loadLineNum'] != '-1'
        basic_applyCDswitchPatch(sc, basicPatch, diskData)
      end

      FileUtils.mkdir_p(Paths::IFolder_Files + sc['disk'])
      comp = BasicCompiler.new(strings, basicPatch, @scriptFont[0])
      p 'Compiling BASIC script ' + sc['script']
      comp.openFile(Paths::EFolder_Basic + sc['script'])

      if (sc['splitPoints'].nil? || sc['splitPoints'] == '-1')
        bin = comp.compileSingle(@enableTranslation, sc['script'])
        basic_addHeader(bin)
        IO.binwrite(Paths::IFolder_Files + sc['disk'] + '/' + sc['script'], bin.pack('C*'))
      else
        splitArray = sc['splitPoints'].split(',')
        bins = comp.splitAndCompile(sc['script'],splitArray, @enableTranslation)
        raise "Compile error for %s" % sc['script'] if bins.nil? || bins.length != 2
        p "Script is splitted into %s and %s" % [sc['script'], splitArray[0]]
        basic_addHeader(bins[0])
        basic_addHeader(bins[1])
        @diskMans[sc['disk']].addReplaceFile(splitArray[0], bins[1])
        IO.binwrite(Paths::IFolder_Files + sc['disk'] + '/' + sc['script'], bins[0].pack('C*'))
        IO.binwrite(Paths::IFolder_Files + sc['disk'] + '/' + splitArray[0], bins[1].pack('C*'))
      end
    end
  end

  def createPackFloppyImages()
    # pack patched BASIC scripts
    @diskData.each do |d|
      if d['diskNum'].to_i > 0 # skip main disk
        basic = IO.binread(Paths::IFolder_Files + d['disk'] + '/' + d['script']).bytes
        @diskMans[d['disk']].addReplaceFile(d['script'], basic)
      end
    end
    @diskMans.each do |disk, man|
      p "Writing disk %s" % disk
      man.writeModified()
    end
    disks2HD = @diskData.group_by { |d| d['disk2HD'] }.sort
    disks2HD.each do |disk, group2HD|
      toPackDisks = group2HD.group_by { |_d| _d['disk'] }
      diskInfo = toPackDisks.first[1].first
      trackCD = diskInfo['trackCD'].to_i(16)
      # clean image
      Const::Disk_2HD_ImgSize.times { |i| @cdImage[trackCD + i] = 0 }

      @cdImage[trackCD + 0x12C002] = diskInfo['diskNum'].to_i
      @cdImage[trackCD + 0x12C003] = 0xC9 # magic number
      p 'Packing 2HD disk %s at offset %x' % [disk, trackCD]

      toPackDisks.each do |(d, p)|
        ind = p.first['subDisk'].to_i
        offset = trackCD + Const::Disk_ImgSize * ind
        diskFile = IO.binread(Paths::IFolder_Floppy + d + '.raw').bytes
        Const::Disk_ImgSize.times { |i|
          @cdImage[offset + i] = diskFile[i]
        }
      end
    end
  end

  def compileASM
    @asmData = Util.CSV2hashArray(Paths::ICSV_ASM)
    @asmData.each do |asm|
      asmSource = Paths::IASM_Source + asm['asmFile'] + '.asm'
      asmBinary = Paths::IASM_Bin + '/' + asm['asmFile'] + '.raw'
      asmList = Paths::IASM_Bin + '/' + asm['asmFile'] + '.lst'
      p 'Compiling ASM file %s' % asmSource
      cmdLine = '"' + Paths::ASM_Exe + '" -L "' + asmList + '" -Fbin -o "' + asmBinary + '" "' + asmSource + '"'
      p cmdLine
      stdin, stdout, stderr, wait_thr = Open3.popen3(cmdLine)
      pid = wait_thr[:pid]
      errors = stderr.read

      raise "ASM compilation error for " + asmSource + ": " + errors if !errors.empty?
      if asm['compileOnly'] == 'true'

        origSize = asm['fileSize'].to_i(16)
        if origSize > 0
          # origBin = Paths::EFolder_Data + asm['asmFile'] + '.raw'
          raise "Image size mismatch for %s! %d(orig) != %d(mod)" % [asm['asmFile'], origSize, File.size(asmBinary)] if origSize != File.size(asmBinary)
        end

      end
    end
  end

  def importIntroScript
    introData = @stringsData.select { |i| i['disk_num'] == Const::Const_Intro }
    basicPatch = @basicPatch.select { |i| i['disk'] == Const::Const_Intro }
    comp = BasicCompiler.new(introData, basicPatch)
    comp.openFile(Paths::IFolder_Basic + '/' + Const::Const_Intro + ".bas")
    bin = comp.compileSingle(true, Const::Const_Intro + ".bas")
    offset = Util.CSV2hashArray(Paths::ECSV_CDData).select { |x| x['filename'] == Const::Const_Intro }.first['offset'].to_i(16)
    bin.each_with_index do |x, i|
      @cdImage[offset + i] = x
    end
  end

  def menu_insertNewDiskData(_data)
    extraData = Array.new

    disks2HD = @diskData.group_by { |d| d['disk2HD'] }.sort
    basicLine = 6010
    onFLine = "" # BASIC disk selector
    disks2HD.each do |disk, group2HD|
      diskInfo = group2HD[0]
      if diskInfo['diskNum'].to_i > 0
        trackCD = diskInfo['trackCD'].to_i(16)
        basic_addPatchLine(_data, Const::Const_Menu, Const::Const_Menu,
                           basicLine,
                           "COMMON COPY &H1,%d:RETURN " % convertCDoffset_toAbsolute(trackCD))

        onFLine += basicLine.to_s
        onFLine += ','
        basicLine += 10
      end
    end
    onFLine[-1] = ':'
    onFLine += 'RETURN '
    onFLine = "ON C GOSUB " + onFLine
    basic_addPatchLine(_data, Const::Const_Menu, Const::Const_Menu,
                       6000,
                       "%s" % onFLine)

    basicLine = 7000
    @diskData.drop(1).each do |script|
      if script['scriptN'] != "-1"
        basic_addPatchLine(_data, Const::Const_Menu, Const::Const_Menu,
                           basicLine,
                           "DATA %d,%d, %d, %d, %s " % [script['scriptN'], script['scribtSub'], script['diskNum'], script['subDisk'], script['script']])
        basicLine += 5
      end
    end
  end


  def importMenuScript
    introData = @stringsData.select { |i| i['disk_num'] == Const::Const_Menu }
    basicPatch = @basicPatch.select { |i| i['disk'] == Const::Const_Menu }

    menu_insertNewDiskData(basicPatch)

    comp = BasicCompiler.new(introData, basicPatch)
    comp.openFile(Paths::IFolder_Basic + '/' + Const::Const_Menu + ".bas")
    bin = comp.compileSingle(@enableTranslation, 'menu.bas')
    IO.binwrite(Paths::IFolder_Data + '/' + Const::Const_Menu + ".raw", bin.pack('c*'))
    offset = Util.CSV2hashArray(Paths::ECSV_CDData).select { |x| x['filename'] == Const::Const_Menu }.first['offset'].to_i(16)
    bin.each_with_index do |x, i|
      @cdImage[offset + i] = x
    end
  end

  def deleteUnusedData()
    # delete ﾘﾝR in disk52
    @diskMans['disk52'].freeFile('ﾘﾝR'.encode('Shift_JIS'))
  end

  def generateFonts
    customFont = FontGen.new
    customFont.generateVWF(Paths::Font_Script, 'script')
    @scriptFont = customFont.generateVWF(Paths::Font_UI, 'ui')
    customFont.generateVWF(Paths::Font_Menu, 'menu')
  end

  def replaceImages
    gfxData = Util.CSV2hashArray(Paths::ICSV_GFX)
    gfxData.each do |gfx|
      p 'Converting image %s' % gfx['origFile']

      imgEncoder = ImgEncoder.new
      convData = imgEncoder.imgEncode(Paths::GFX_PATH + '/' + gfx['origFile'], gfx['isMono'] == 'true')

      header = []
      header += Util.n2b(convData.length, 2, false)
      header += Util.n2b(gfx['loadAddr'].to_i(16), 2, false)

      header.push((convData.length * 1.0 / Const::Disk_SectorSize).ceil)
      header.push 2
      header.each { |x| convData.unshift(x) }

      FileUtils.mkdir_p(Paths::IFolder_Files + gfx['disk'])

      IO.binwrite(Paths::IFolder_Files + gfx['disk'] + '/' + gfx['file'], convData.pack('C*'))
      @diskMans[gfx['disk']].addReplaceFile(gfx['file'], convData)
    end
  end

  def importData
    # copy CD image
    @cdImage = IO.binread(Paths::Original_ISO_DataTrack).bytes

    generateFonts()
    replaceImages()

    # Patch BASIC intro script
    compileASM()
    importIntroScript()
    importMenuScript()
    deleteUnusedData()
    translateBasicScripts()
    createPackFloppyImages()

    importCsv = Util.CSV2hashArray(Paths::ICSV_CDData)
    importCsv.each do |file|
      iFile = IO.binread(Paths::IMPORT_PATH + '/' + file['path'] + '/' + file['filename'] + '.raw').bytes
      offset = file['offset'].to_i(16)
      file['size'].to_i(16).times { |i|
        if iFile[i] == nil
          break
        end
        @cdImage[offset + i] = iFile[i]
      }
    end

    IO.binwrite(Paths::Patched_ISO_DataTrack, @cdImage.pack('C*'))
  end


end