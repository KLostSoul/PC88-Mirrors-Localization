require_relative 'defines.rb'
require_relative 'file_streamer.rb'
require_relative 'util.rb'

require_relative 'BasicCompiler.rb'
require_relative 'BasicDecompiler.rb'

require_relative 'FloppyMan.rb'


require_relative 'DataExporter.rb'


require_relative 'FontGen.rb'
require_relative 'ImgEncoder.rb'


require_relative 'DataImporter.rb'



def main()
	opMode = "import"
	if opMode == "export"
		dataExporter = DataExporter.new(Paths::Original_ISO_DataTrack)
		dataExporter.export
	elsif opMode == "import"
		dataImporter = DataImporter.new(true)
		dataImporter.importData
	elsif opMode == "custom"
		#basDecomp = BasicDecompiler.new()
		#basDecomp.openFile(Paths::TEMP_PATH + '/' + "vwfBasic")
		#basic = basDecomp.decompile()
		#IO.binwrite(Paths::TEMP_PATH + '/tfgdg.raw', basic[:mData])



		#(32..127).each do |i|
		#	print i.chr
		#end
		#comp = BasicCompiler.new
		#comp.openFile(Paths::EFolder_Basic + '/' + "intro.bas")
		#bin = comp.compile
		#IO.binwrite(Paths::TEMP_PATH + '/test.raw', bin.pack('C*'))
	end


end

main