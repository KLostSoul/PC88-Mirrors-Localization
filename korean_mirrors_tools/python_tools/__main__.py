import argparse

from .main import main


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Build the Korean Mirrors CD")
    parser.add_argument(
        "--source",
        choices=("japanese", "english"),
        help="source image to translate; when omitted, a sole image is selected automatically",
    )
    main(parser.parse_args().source)
