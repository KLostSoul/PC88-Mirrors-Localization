class BasicCompiler
  LineLimit = 362

  def initialize(_stringsData = nil, _patchData = nil, _widthData = nil)
    @compFile = Array.new
    @regOps = Hash.new
    @extOps = Hash.new
    @txtFile = ""
    Const::BasicResWords.each_with_index do |x, i|
      @regOps[x] = '\x%x' % (i + 0x80)
    end
    Const::BasicExtWords.each_with_index do |x, i|
      @extOps[x] = '\x%x' % (i + 0x80)
    end

    @LineTokens = [
        0x8C,       # RESTORE
        0xA8,       # AUTO
        0xA9,       # RENUM
        0xA7,       # DELETE
        0xA4,       # EDIT
        0xA6,       # RESUME
        0xE4,       # ERL
        0x9F,       # ELSE
        0x8A,       # RUN
        0x93,       # LIST
        0x9C,       # LLIST
        0x89,       # GOTO
        0x8E,       # RETURN
        0xDD,       # THEN
        0x8D,       # GOSUB
    ]

    @stringsData = _stringsData
    @patchData = _patchData
    @widthData = _widthData
  end

  def openFile(_filename)
    @txtFile = File.readlines(_filename)
  end

  def isNumber(_str)
    return /\A\d+\z/.match(_str)
  end

  def checkLineToken(_token)
    if @LineTokens.include?(_token)
      @isLineToken = true
    else
      @isLineToken = false
    end
  end

  # some hardcoded hacks
  def patchStatement(_statement)
    # patch audio CD
    _statement[1].gsub!('COMMON FM', 'COMMON STOP')
    _statement[1].gsub!('COMMON FP', 'COMMON STOP:COMMON FP')
  end

  def splitAndCompile(_script, _splitArray, _translateStrings = true)
    newScript = _splitArray[0]
    sc1nums = [_splitArray[1].to_i,_splitArray[2].to_i]
    sc2nums = [_splitArray[3].to_i,_splitArray[4].to_i]
    sc1 = @txtFile.select { |line|
      linenum = line.split(/\s{1}/, 2)[0].to_i
      linenum < sc2nums[0] || linenum > sc2nums[1]
    }
    sc2 = @txtFile.select { |line|
      linenum = line.split(/\s{1}/, 2)[0].to_i
      linenum < sc1nums[0] || linenum > sc1nums[1]
    }
    sc1.push("%d CMD RUN \"%s\" " % [_splitArray[2].to_i + 1, newScript])
    bin1 = compile(sc1, _translateStrings, _script)
    bin2 = compile(sc2, _translateStrings, newScript)

    return [bin1, bin2]
  end

  def compileSingle(_translateStrings = true, _debugName = "")
    return compile(@txtFile, _translateStrings, _debugName)
  end

  def compile_EndString(_newStr)

    _newStr += '"'
    return _newStr
  end

  def compile(_txtFile, _translateStrings, _debugName)
    if @patchData != nil
      # add new lines
      lineNums = _txtFile.map {|x| x.split(/\s{1}/, 2)[0] }
      toAdd = @patchData.select {|i| !lineNums.include?(i['line']) }
      toAdd.each do |l|
        _txtFile.push(l['line'].to_s + ' ' + l['patchedLine'].to_s)
      end

    end
    _txtFile.sort_by! {|x| x.split(/\s{1}/, 2)[0].to_i }

    binCode = []
    debugName = _debugName
    debugStrings = {}
    @isDataToken = false
    @isLineToken = false

    _txtFile.each_with_index do |l, lnum|
      statement = l.split(/\s{1}/, 2)

      if @patchData != nil
        patched = @patchData.select {|i| i['line'].to_i == statement[0].to_i }
        if !patched.empty?
          if patched.length == 1
            patchStr = patched.first['patchedLine'].to_s
            if patchStr == ""
              statement[1] = ""
            else
              statement[1] = patched.first['patchedLine'].to_s + ' '
            end
          else
            raise "Duplicate patch lines found for line %d" %  statement[0].to_i
          end

        end
      end

      if statement[1] == "" # skip line
        next
      end

      #p 'Line %d' % statement[0]
      #p l
      #statement[1].encode!('Shift_JIS', 'UTF-8', invalid: :replace, undef: :replace, replace: "")
      regex = %r{
        (\".+?\")              # quoted strings
        |(\-)
        |(\,)
        |(\=)
        |(\:)
        |(\*)
        |([A-Z]+?\$)           # string variables
        |(&H[0-9A-F]{4})       # hex numbers
        |(&H[0-9A-F]{2})       # hex numbers
        |(&H[0-9A-F]{1})       # hex numbers
        |(&O[0-7]{3})          # octal numbers
        |(\s)                  # spaces
        |\b                    # word boundaries
      }x

      patchStatement(statement)
      if statement[0].to_i == 9999 && debugName != Const::Const_Menu + '.bas'
        # hack for masking graphics (line 9999)
        binLine = [0xD6,0x20,0x11,0x2C,0x0F,0x12,0x3A,0x91,0x22,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x87,0x22,0x3A,0x8E]
      else
        tokens = statement[1].split(regex)
        binLine = []
        commentIndex = -1
        @isDataToken = false
        @isLineToken = false
        tokens[0..-2].each_with_index do |t, i|
          if t == ""                               # skip
            next
          elsif t == "'"                             # comment
            binLine.push 0x3a
            binLine.push 0x8f
            binLine.push 0xe9
            commentIndex = i + 1
            break
            # cut off comments to reduce size
          elsif t == "DATA"                             # DATA
            binLine.push 0x84
            @isDataToken = true
            next
          elsif Const::BasicResWords.include?(t) && !@isDataToken
            token = Const::BasicResWords.find_index(t) | 0x80
            binLine.push token
            checkLineToken(token)
            next
          elsif Const::BasicExtWords.include?(t) && !@isDataToken
            binLine.push 0xff
            binLine.push Const::BasicExtWords.find_index(t) | 0x80
            checkLineToken(token)
            next
          elsif t.start_with?("\"")
            str = t
            origStr = str[1, str.length-2]
            origStr.gsub!('−', '－')
            origStr.gsub!('－', '−')
            newStr = ""

            if @stringsData != nil && _translateStrings
              replace = @stringsData.select {|s| s['source_text'] == origStr && s['basic_line'] == statement[0] }
              if replace.empty?
                replace = @stringsData.select {|s| s['source_text'] == origStr  }
              end
              if !replace.empty? && replace.first['translation'] != ""
                trStr = replace.first['translation']

                # split long lines
                if !@widthData.nil? # script messages
                  newStr += '"'
                  tmpString = ""
                  trLines = trStr.split("\n")
                  lineCount = 0
                  trLines.each_with_index { |tr, ind|
                    prepStr = tr.gsub('—', ' - ').gsub("\"", '`')
                    splitStr = prepStr.split(' ')

                    splitStr.each do |word|
                      wordLength = word.chars.map {|l| @widthData[l.ord-0x20]}.inject(0){|sum,x| sum + x }
                      tmpStringLength = tmpString.chars.map {|l| @widthData[l.ord-0x20]}.inject(0){|sum,x| sum + x }
                      if (tmpStringLength + wordLength) > LineLimit ||
                          ((tmpStringLength > LineLimit) && ((tmpString[-2] == ",") || (tmpString[-2] == ".") || (tmpString[-2] == "!") || (tmpString[-2] == "?")))
                        lineCount += 1
                        newStr += tmpString.rstrip
                        tmpString = ""
                        if lineCount > 2
                          lineCount = 0
                          newStr = compile_EndString(newStr)
                          if newStr.length >= 0xF0
                            raise "String too long: %s" % newStr
                          end
                          newStr += "\x3A\x8D\x20\x0E\xEC\x13\x3A\x42\x4D\x24\xF1"
                          newStr += '"'
                        else
                          newStr += "\\"
                        end
                      end
                      tmpString += word + " "
                    end
                    newStr += tmpString.rstrip
                    if ind < trLines.length - 1
                      lineCount += 1
                      tmpString = ""
                      if lineCount > 2
                        lineCount = 0
                        newStr = compile_EndString(newStr)
                        if newStr.length >= 0xF0
                          raise "String too long: %s" % newStr
                        end
                        newStr += "\x3A\x8D\x20\x0E\xEC\x13\x3A\x42\x4D\x24\xF1"
                        newStr += '"'
                      else
                        newStr += "\\"
                      end
                    end
                  }
                  newStr = compile_EndString(newStr)
                else
                  newStr += '"'
                  newStr += trStr.gsub('—', ' - ').gsub("\r", "").gsub("\"", '`').gsub("\n", "\\")
                  newStr = compile_EndString(newStr)
                end
              else
                newStr = str.encode('Shift_JIS', 'UTF-8', invalid: :replace, undef: :replace, replace: "")
              end
            else
              newStr = str.encode('Shift_JIS', 'UTF-8', invalid: :replace, undef: :replace, replace: "")
            end
            binLine += newStr.bytes
          elsif t.start_with?("&O")
            binLine.push 0x0b
            binLine += Util.n2b(t[2..-1].to_i(8), 2)
          elsif t.start_with?("&H")
            binLine.push 0x0c
            binLine += Util.n2b(t[2..-1].to_i(16), 2)
          elsif t =~ /\A\d+\z/
            if @isDataToken
              binLine += t.bytes
            elsif @isLineToken
              binLine.push 0x0e
              binLine += Util.n2b(t.to_i, 2)
            elsif t.to_i >= 0 && t.to_i <=9
              binLine.push (t.to_i + 0x11)
            elsif t.to_i < 0x100
              binLine.push 0x0f
              binLine.push t.to_i
            else
              binLine.push 0x1c
              binLine += Util.n2b(t.to_i, 2)
            end
          elsif t == ":"
            @isLineToken = false
            @isDataToken = false
            binLine.push 0x3a
          else
            t.each_char { |c|
              if (c.ord >= 0x20 && c.ord < 0x80)
                binLine.push c.ord
              else
                raise "Unexpected symbol %s at line %d" % [c, lnum]
              end
            }
          end
        end
        #if (commentIndex != -1)
        #  tokens[commentIndex..-2].each_with_index do |t, i|
        #    t.each_char { |c|
        #      binLine.push c.ord
        #   }
        #  end
        #end
      end

      binLine.push (0)       # finish line
      # encode line number
      lineNum = Util.n2b(statement[0].to_i, 2)
      binLine.unshift(lineNum[0], lineNum[1])
      # encode next line address
      lineAddr = Util.n2b(binCode.length + binLine.length + 3, 2)
      binLine.unshift(lineAddr[0], lineAddr[1])
      #p statement[1].split( regex );
      #p binLine.pack("c*").unpack("H*")
      binCode += binLine

    end
    # finish script
    binCode.push (0)
    binCode.push (0)
    binCode.push (0)
    binCode.push (0)

    if (debugName != "")
      basicDec = BasicDecompiler.new
      basicDec.openMemory(binCode)
      decomp = basicDec.decompile()
      IO.binwrite(Paths::TEMP_PATH + '/basic/' + debugName, decomp[:mData])
    end

    return binCode
  end
end