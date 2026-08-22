import argparse

from .data_exporter import DataExporter
from .data_importer import DataImporter
from .fontgen import FontGen
from .paths import (
    ECSV_SCRIPTS, E_FOLDER_BASIC, E_FOLDER_FLOPPY, FONT_MENU, FONT_SCRIPT,
    FONT_UI, ICSV_DISKS, ORIGINAL_ISO_DATATRACK,
)
from .util import csv_hash_array


def require_file(path, purpose):
    if not path.exists():
        raise FileNotFoundError(f"Missing {purpose}: {path}")


def preflight(mode):
    if mode in ("export", "import"):
        require_file(ORIGINAL_ISO_DATATRACK, "extracted original CD data track")
    if mode == "import":
        for disk in {row["disk"] for row in csv_hash_array(ICSV_DISKS)}:
            require_file(E_FOLDER_FLOPPY / f"{disk}.raw", f"exported floppy image {disk}")
        for script in {row["script"] for row in csv_hash_array(ECSV_SCRIPTS)}:
            require_file(E_FOLDER_BASIC / script, f"exported BASIC script {script}")


def main():
    parser = argparse.ArgumentParser(description="Python build tools for PC-8801 Mirrors")
    parser.add_argument("mode", choices=("fonts", "export", "import"))
    parser.add_argument("--no-translate", action="store_true", help="Do not apply translation strings")
    args = parser.parse_args()
    preflight(args.mode)

    if args.mode == "fonts":
        generator = FontGen()
        generator.generate_vwf(FONT_SCRIPT, "script")
        generator.generate_vwf(FONT_UI, "ui")
        generator.generate_vwf(FONT_MENU, "menu")
    elif args.mode == "export":
        DataExporter().export()
    else:
        DataImporter(not args.no_translate).import_data()


if __name__ == "__main__":
    main()
