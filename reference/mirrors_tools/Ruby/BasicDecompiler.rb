class BasicDecompiler
  def initialize()
  end

  def openFile(_fileName)
    @bFile = FileStreamer.new(_fileName)
  end

  def openMemory(_data)
    @bFile = FileStreamer.new()
    @bFile.openMemory(_data)
  end

  def readBasicString()
    str = ""
    while true
      if @bFile.peek() == 0x22 || @bFile.peek() == 0
        break
      end
      str += @bFile.readByte().chr
    end
    return str
  end

  def decompile(_withHeader = false)
    basF = @bFile
    outF = String.new
    stringData = Hash.new
    stringCount = 0

    while !basF.eof()
      linkAddr = basF.readWord()
      linkNumber = basF.readWord()
      stringArray = []
      # p "%x, %x, %d" % [basF.offset, linkAddr, linkNumber]
      if linkAddr == 0 || linkNumber >= 20000 # exclude invalid addresses
        break
      end
      outF += "%d " % linkNumber

      loop do
        op = basF.readByte()
        if op == 0x00                            # no-op
          break
        elsif op == 0x0b                         # octal number
          arg = basF.readWord()
          outF += "&O%03o" % arg
        elsif op == 0x0c                         # hex number
          arg = basF.readWord()
          if arg >= 0x100
            outF += "&H%04X" % arg
          else
            outF += "&H%02X" % arg
          end
        elsif op == 0x0e || op == 0x1c           # decimal
          arg = basF.readWord()
          outF += "%d" % arg
        elsif op == 0x0f                         # byte
          arg = basF.readByte()
          outF += "%d" % arg
        elsif op >= 0x11 and op <= 0x1b          # op as decimal
          outF += "%d" % (op - 0x11)
        elsif op == 0x84                         # DATA
          outF += "DATA" % arg
          while true
            data = basF.readByte()
            if data == 0 || data == ':'
              basF.advance(-1)
              break
            end
            if data == 0x22 # string
              outF += "\""
              outF += self.readBasicString().encode('UTF-8', 'Shift_JIS', invalid: :replace, undef: :replace, replace: "  ")
              outF += "\""
              basF.advance(1)
            else
              outF += data.chr
            end
          end
        elsif op == 0x22                         # string
          outF += "\""
          str = self.readBasicString().encode('UTF-8', 'Shift_JIS', invalid: :replace, undef: :replace, replace: "  ")
          outF += str
          stringArray.push [stringCount, str]
          stringCount += 1
          outF += "\""
          if @bFile.peek() == 0x22
            basF.advance(1)
          end

        elsif op == 0x3a                         # next statement
          if basF.peek() == 0x8f                 # comment
            outF += "'"
            basF.advance(2)
            while true
              if basF.peek() == 0
                break
              end
              outF += basF.readByte().chr.encode('UTF-8', 'Shift_JIS', invalid: :replace, undef: :replace, replace: "  ")
            end
          else # if basF.peek() != 0x9f
            outF += op.chr
          end
        elsif op == 0x8f                         # comment
          outF += "%s" % Const::BasicResWords[op & 0x7f]
          while true
            if basF.peek() == 0
              break
            end
            outF += basF.readByte().chr.encode('UTF-8', 'Shift_JIS', invalid: :replace, undef: :replace, replace: "  ")
          end
        else
          if op < 0x80
            outF += op.chr
          elsif op <  0xff
            outF += Const::BasicResWords[op & 0x7f]
          else
            ext = basF.readByte()
            outF += Const::BasicExtWords[ext & 0x7f]
          end
        end
      end
      if stringArray.length > 0
        stringData[linkNumber] = stringArray
      end

      outF += "\n"
      basF.reset(linkAddr + (_withHeader ? 6 : -1))
    end
    return {:mData => outF, :mStrings => stringData}
  end
end
