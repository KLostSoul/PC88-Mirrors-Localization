import hashlib
import sys
from dataclasses import dataclass
from pathlib import Path

from .defines import Paths


SOURCE_IMAGE_SHA256 = {
    "japanese": "258533b4ac5fd8b16170ddf9509dcf2d6c4a0959bac61e999b3d14c9c0b48d65",
    "english": "294ee461a2bea8745394c71ca7eec64960a865673d72f8b60557c0a29a9ca7aa",
}


@dataclass(frozen=True)
class CloneCDSource:
    language: str
    stem: str
    img: Path
    ccd: Path
    cue: Path | None
    sub: Path
    sha256: str

    @property
    def label(self) -> str:
        return self.language.capitalize()


def available_clonecd_sources() -> dict[str, CloneCDSource]:
    known_hashes = {
        digest: language for language, digest in SOURCE_IMAGE_SHA256.items()
    }
    sources = {}
    for image in sorted(Paths.CD_IMAGE_DIR.glob("*.img")):
        digest = hashlib.sha256()
        with image.open("rb") as file:
            while chunk := file.read(1024 * 1024):
                digest.update(chunk)
        image_hash = digest.hexdigest()
        language = known_hashes.get(image_hash)
        if language is None:
            raise ValueError(
                f"Unsupported source image SHA-256: {image}\n{image_hash}"
            )
        if language in sources:
            raise ValueError(
                f"More than one {language} source image matched the known hash: "
                f"{sources[language].img} and {image}"
            )

        stem = image.stem
        ccd = image.with_suffix(".ccd")
        sub = image.with_suffix(".sub")
        missing = [path for path in (ccd, sub) if not path.is_file()]
        if missing:
            raise FileNotFoundError(
                f"Incomplete {language} CloneCD image set; missing:\n"
                + "\n".join(str(path) for path in missing)
            )

        cue = image.with_suffix(".cue")
        sources[language] = CloneCDSource(
            language=language,
            stem=stem,
            img=image,
            ccd=ccd,
            cue=cue if cue.is_file() else None,
            sub=sub,
            sha256=image_hash,
        )
    return sources


def resolve_clonecd_source(
    language: str | None = None,
    sources: dict[str, CloneCDSource] | None = None,
) -> CloneCDSource:
    if sources is None:
        sources = available_clonecd_sources()
    if language is not None:
        key = language.strip().lower()
        if key not in SOURCE_IMAGE_SHA256:
            raise ValueError(
                f"Unknown CD source {language!r}; choose japanese or english"
            )
        if key not in sources:
            raise FileNotFoundError(
                f"No {key} source image with the registered SHA-256 was found "
                f"in {Paths.CD_IMAGE_DIR}"
            )
        return sources[key]

    if len(sources) == 1:
        return next(iter(sources.values()))
    if not sources:
        expected = "\n".join(
            f"{language}: SHA-256 {digest}"
            for language, digest in SOURCE_IMAGE_SHA256.items()
        )
        raise FileNotFoundError(
            "No supported CloneCD source image was found. Expected one of:\n"
            + expected
        )
    if not sys.stdin.isatty():
        raise RuntimeError(
            "Both Japanese and English source images are present. "
            "Select one with --source japanese or --source english."
        )

    print("이번 한글판 빌드에 사용할 입력 이미지를 선택하세요:")
    print(f"  1) 일본판 — SHA-256 {sources['japanese'].sha256}")
    print(f"  2) 영문판 — SHA-256 {sources['english'].sha256}")
    while True:
        try:
            choice = input("선택 (1/2): ").strip()
        except EOFError as exc:
            raise RuntimeError(
                "CD source selection was cancelled; use --source japanese "
                "or --source english."
            ) from exc
        if choice == "1":
            if "japanese" in sources:
                return sources["japanese"]
        elif choice == "2":
            if "english" in sources:
                return sources["english"]
        print("1 또는 2를 입력하세요.")


class CloneCD:
    RAW_SECTOR_SIZE = 2352
    RAW_USER_DATA_OFFSET = 16
    TRACK2_LBA = 13350
    TRACK2_SECTORS = 19800
    LOGICAL_SECTOR_SIZE = 2048
    TRACK2_MAGIC = b"NEC Personal Computer PC-8801 Series CD Type1"

    @classmethod
    def extract_track2(cls, source: Path, destination: Path) -> None:
        if not source.is_file():
            raise FileNotFoundError(
                "Original CloneCD image not found: " + str(source)
            )

        last_raw_offset = (
            (cls.TRACK2_LBA + cls.TRACK2_SECTORS) * cls.RAW_SECTOR_SIZE
        )
        if source.stat().st_size < last_raw_offset:
            raise ValueError(
                "CloneCD image is shorter than the expected Track 2 range: "
                + str(source)
            )

        destination.parent.mkdir(parents=True, exist_ok=True)
        with source.open("rb") as input_file, destination.open("wb") as output_file:
            for sector in range(cls.TRACK2_SECTORS):
                raw_offset = (
                    (cls.TRACK2_LBA + sector) * cls.RAW_SECTOR_SIZE
                    + cls.RAW_USER_DATA_OFFSET
                )
                input_file.seek(raw_offset)
                payload = input_file.read(cls.LOGICAL_SECTOR_SIZE)
                if len(payload) != cls.LOGICAL_SECTOR_SIZE:
                    raise ValueError(
                        "Truncated CloneCD Track 2 sector %d" % sector
                    )
                output_file.write(payload)

        if destination.stat().st_size != (
            cls.TRACK2_SECTORS * cls.LOGICAL_SECTOR_SIZE
        ):
            raise RuntimeError(
                "Extracted Track 2 has an unexpected size: "
                + str(destination)
            )

        with destination.open("rb") as output_file:
            magic = output_file.read(len(cls.TRACK2_MAGIC))
        if magic != cls.TRACK2_MAGIC:
            raise ValueError(
                "Extracted Track 2 does not contain the Mirrors CD Type1 "
                "header: " + str(destination)
            )


def extract_original_track2(source_img: Path | None = None) -> None:
    if source_img is None:
        source_img = resolve_clonecd_source().img
    CloneCD.extract_track2(
        source_img,
        Paths.Original_ISO_DataTrack,
    )
