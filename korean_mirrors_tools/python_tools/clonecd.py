from pathlib import Path

from .defines import Paths


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


def extract_original_track2() -> None:
    CloneCD.extract_track2(
        Paths.CLONECD_IMG,
        Paths.Original_ISO_DataTrack,
    )
