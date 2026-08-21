class FloppyMan
  Dir_Pos = 399 * Const::Disk_SectorSize
  FT_Replace = 1
  FT_Add = 2

  def initialize()
    @files = []
    @modFiles = {}
    @diskName = ""
  end

  def freeFile(_name)
    origFile = @files.find_index { |f| f[:fileName] == _name }
    if origFile.nil?
      raise "File not found: %s" % _name
    end
    p "Deleting file %s..." % _name
    @files.delete_at(origFile)
  end

  def findFreeSectors(_count)
    map = Array.new(400, 0xff)
    # hardcoded indices
    map[0] = 0xfe
    map[0x18B] = 0xfe
    @files.each do |f|
      f[:sectors].each { |sec|
        map[sec] = f[:index]
      }
    end
    free = []
    nextIndex = 0
    _count.times do |i|
      index = map.drop(nextIndex).find_index(0xff)
      if index == nil
        break
      end
      free.push(index)
      nextIndex = index
    end
    return free
  end


  def addReplaceFile(_file, _bytes)
    fileName = _file.encode('Shift_JIS')
    origFile = @files.find_index { |f| f[:fileName] == fileName }
    if origFile.nil?
      p "Adding %s in disk %s..." % [fileName, @diskName]
      @modFiles[fileName] = _bytes
    else
      p "Replacing %s in disk %s..." % [fileName, @diskName]
      @modFiles[fileName] = _bytes
      freeFile(fileName)
    end


  end

  def writeFilename(_f, _ind, _dir)
    4.times { |i|
      if _f[i] == nil
        c = 0
      else
        c = _f[i].ord
      end
      _dir[_ind * 4 + i] = c
    }
  end

  def writeModSector(_disk, _sector, _data)
    if @writeSector >= 400
      raise "Out of disk space"
    end
    Const::Disk_SectorSize.times { |i|
      if _data[i] == nil
        break
      end
      _disk[Const::Disk_SectorSize * _sector + i] = _data[i]
    }
    @writeSector += 1
  end

  def writeModified()
    origFloppy = IO.binread(Paths::EFolder_Floppy + '/' + @diskName + '.raw').bytes

    # create new structures for modified disk
    modFloppyR = origFloppy.clone
    modDir = Array.new(0x200, 0xff)
    modMap = Array.new(0x200, 0xff)
    modFileCount = 0

    # copy original files
    @writeSector = 1
    @files.each_with_index do |f, ind|
     f[:sectors].each do |ns|
        modMap[@writeSector] = ind
        writeModSector(modFloppyR, @writeSector, origFloppy[Const::Disk_SectorSize * ns, Const::Disk_SectorSize])
      end
      writeFilename(f[:fileName], ind, modDir)
      modFileCount += 1
    end

    @modFiles.each do |file, data|
      writeFilename(file, modFileCount, modDir)

      secCount = (data.length * 1.0 / Const::Disk_SectorSize).ceil
      secCount.times do |s|
        modMap[@writeSector] = modFileCount
        writeModSector(modFloppyR, @writeSector, data[Const::Disk_SectorSize * s, Const::Disk_SectorSize])
      end
      modFileCount += 1
    end

    modMap[0] = 0xFE # IPLD
    0x200.times { |i|
      modFloppyR[Dir_Pos + i] = modDir[i]
    }
    0x200.times { |i|
      modFloppyR[Dir_Pos + 0x200 + i] = modMap[i]
    }

    freeSectors = 0
    modMap.each_with_index do |x, i|
      if i < 400 && x == 0xFF
        freeSectors += 1
      end
    end
    p "Free sectors: %d/400" % freeSectors
    IO.binwrite(Paths::IFolder_Floppy + '/' + @diskName + '.raw', modFloppyR.pack('c*'))
  end

  def open(_fileName)
    @floppyF = FileStreamer.new(Paths::EFolder_Floppy + '/' + _fileName + '.raw')
    @diskName = _fileName
    @floppyF.reset(Dir_Pos)
    dir = @floppyF.readBytes(0x200)
    map = @floppyF.readBytes(0x200)
    @internalNum = map[0x1fe, 2]
    0.step(0x200, 4) do |i|
      fCount = i / 4
      if dir[i, 4] == [0xff, 0xff, 0xff, 0xff]
        break
      end
      @files.push({
                      :fileName => dir[i, 4].pack('c*').force_encoding('shift_jis').delete("\000"),
                      :index => fCount,
                      :sectors => map[0, 0x1fe].size.times.select { |i| map[i] == fCount }
                  })
    end
  end

  def extractAll()
    @files.each do |f|
      bytes = []
      f[:sectors].each do |sec|
        if sec <= 400
          bytes += @floppyF.readBytes(Const::Disk_SectorSize, (sec) * Const::Disk_SectorSize)
        end
      end
      FileUtils.mkdir_p(Paths::EFolder_Files + @diskName)
      IO.binwrite(Paths::EFolder_Files + @diskName + '/' + f[:fileName], bytes.pack('c*'))
    end
  end
end