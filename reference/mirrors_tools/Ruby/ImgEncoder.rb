class ImgEncoder
  def convertPattern(_pat, _shift)
    num = 0
    mask = 1 << _shift
    8.times { |i|
      num += ((_pat[i] & mask) >> _shift) << (7-i);
    }
    return num
  end

  def writeChunk(_stream, _chunk)
    count = _chunk.length
    count += 0x80
    _stream.push(count)
    _chunk.each do |c|
      _stream.push c
    end

    _chunk.clear
  end

  def imgEncode(_pngImg, _isMono)
    origImg = ChunkyPNG::Image.from_file(_pngImg)
    imgData = ChunkyPNG::Datastream.from_file(_pngImg)
    width = origImg.width
    height = origImg.height
    if height > 200
      raise "Image height is greater than 200"
    end

    pixels = origImg.pixels
    outStream = []
    pattern = []
    patternData = []
    c = 0
    plane = 0
    exit = false

    indexPal = ChunkyPNG::Palette.from_chunks(imgData.palette_chunk ).to_a
    while !exit
      8.times do |k|
        pattern.push(indexPal.index(pixels[c]))
        #print ("%d " % indexPal.index(pixels[c]))
        c += 1
        if c >= width * height

          c = 0
          plane += 1
          if (plane >= (_isMono ? 1 : 3))
            exit = true
            break
          end
        end
      end
      p = convertPattern(pattern, plane)
      patternData.push(p)
      pattern.clear
    end

    outStream.push(width / 8)
    outStream.push(height)
    outStream.push(_isMono ? 0x07 : 0)

    c = 0
    chunk = []
    patternData.length.times do |i|
      it = patternData[i]
      if (i + 1 >= patternData.length)
        n = patternData[i]
      else
        n = patternData[i + 1]
      end
      if (it == n)
        if chunk.empty?
          c += 1
          if (c >= 0x7f || i == (patternData.length - 1))
            outStream.push(c)
            outStream.push(it)
            c = 0
          end
        else
          writeChunk(outStream, chunk)
          c = 1
        end
      else
        if (c == 0)
          if chunk.length < 0x7f
            chunk.push(it)
          else
            writeChunk(outStream, chunk)
            c = 0
          end
        else
          c += 1
          outStream.push(c)
          outStream.push(it)
          c = 0
        end
      end
    end
    fSize = outStream.length
    header = Util.n2b(0xc000, 2)
    result = header + outStream
    return result
  end
end

