import argparse
import hashlib
from pathlib import Path


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def compare_trees(left: Path, right: Path, relative_files):
    failed = False
    for relative in relative_files:
        left_file = left / relative
        right_file = right / relative
        if not left_file.exists() or not right_file.exists():
            print(f"MISSING {relative}: {left_file.exists()} / {right_file.exists()}")
            failed = True
            continue
        same = left_file.read_bytes() == right_file.read_bytes()
        print(f"{'OK' if same else 'DIFF'} {relative} ({digest(left_file)} / {digest(right_file)})")
        failed |= not same
    return not failed


def main():
    parser = argparse.ArgumentParser(description="Compare Python and reference build artifacts")
    parser.add_argument("left", type=Path)
    parser.add_argument("right", type=Path)
    parser.add_argument("files", nargs="+", help="Relative paths to compare")
    args = parser.parse_args()
    raise SystemExit(0 if compare_trees(args.left, args.right, args.files) else 1)


if __name__ == "__main__":
    main()
