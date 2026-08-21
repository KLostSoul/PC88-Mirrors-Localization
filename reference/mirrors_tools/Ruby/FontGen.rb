class FontGen
  def initialize

  end

  def generateVWF(_fontFile, _name)
    tileBytes = Array.new

    img = ChunkyPNG::Image.from_file(_fontFile)
    charWidth = 8
    charHeight = 16

    tileBytes = Array.new
    tileWidths = Array.new
    leftMargin = Array.new
    rightMargin = Array.new
    6.times do |y|
      16.times do |x|
        part = img.crop(x * charWidth, (y + 2) * charHeight, charWidth, charHeight)
        leftX = 0
        rightX = charWidth - 1
        letterWidth = 4
        if x > 0 || y > 0
          4.times do |r|
            leftColumn = Array.new
            rightColumn = Array.new
            16.times do |y|
              leftColumn.push part.get_pixel(leftX, y)
              rightColumn.push part.get_pixel(rightX, y)
            end
            leftX += 1 if leftColumn.uniq.size == 1
            rightX -= 1 if rightColumn.uniq.size == 1
          end
          letterWidth = rightX - leftX + 1
          picWidth = letterWidth
          picWidth = 4 if picWidth < 4
          part.crop!(leftX, 0, picWidth, charHeight)
          #letterWidth += 1
        end
        0.step(charHeight - 1, 1) do |line|
          bs = String.new
          charWidth.times do |pixel|
            if pixel < part.width
              if part[pixel, line] > 0xff
                bs += "1"
              else
                bs += "0"
              end
            else
              bs += "0"
            end
          end
          #puts bs.to_i(2)
          tileBytes.push bs.to_i(2)
        end
        tileWidths.push letterWidth - 1
        #leftMargin.push leftX
        #rightMargin.push rightX - 1
        #part.save((Paths::TEMP_PATH + '/' + "letter_"+y.to_s+"x"+x.to_s+".png"), :interlace => true)
      end
    end
    tileWidths.shift
    tileWidths.unshift 0x02
    IO.binwrite(Paths::IFolder_Data + '/' + _name + "_bytes.raw", tileBytes.pack('c*'))
    #IO.binwrite(Paths::IFolder_Data + '/' + "leftMargin.raw", leftMargin.pack('c*'))
    #IO.binwrite(Paths::IFolder_Data + '/' + "rightMargin.raw", rightMargin.pack('c*'))
    IO.binwrite(Paths::IFolder_Data + '/' + _name + "_widths.raw", tileWidths.pack('c*'))
    p "Font %s generated" % _fontFile
    return [tileWidths, tileBytes]
  end
end