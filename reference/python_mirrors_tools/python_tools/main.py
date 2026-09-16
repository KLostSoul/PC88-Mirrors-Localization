from .basic_compiler import BasicCompiler
from .basic_decompiler import BasicDecompiler
from .data_exporter import DataExporter
from .data_importer import DataImporter
from .defines import Paths
from .file_streamer import FileStreamer
from .floppy import FloppyMan
from .fontgen import FontGen
from .img_encoder import ImgEncoder
from .util import Util


def main():
    opMode = "import"
    if opMode == "export":
        dataExporter = DataExporter(Paths.Original_ISO_DataTrack)
        dataExporter.export()
    elif opMode == "import":
        dataImporter = DataImporter(True)
        dataImporter.importData()
    elif opMode == "custom":
        pass

