import struct


class D88:
    """Create blank PC-8801 2HD D88 disk images.

    The game formats these disks on first use.  The image therefore only
    needs a valid 2HD D88 container and blank sector payloads.
    """

    HEADER_SIZE = 0x2B0
    TRACK_COUNT = 160  # 80 cylinders, two sides
    SECTORS_PER_TRACK = 8
    SECTOR_SIZE = 0x400
    SECTOR_RECORD_SIZE = 0x10 + SECTOR_SIZE
    TRACK_SIZE = SECTORS_PER_TRACK * SECTOR_RECORD_SIZE
    DISK_SIZE = HEADER_SIZE + TRACK_COUNT * TRACK_SIZE

    # The generated disks are treated as already initialized by the game.
    # Keep the IPLD markers at both disk-check locations so neither CMD FOR
    # path reformats the disk during startup.
    IPLD_LOCATIONS = (
        (0x4F, 4),  # Main: track 0x4F, sector 0x05
        (0x31, 7),  # Game: track 0x31, sector 0x08
    )

    @classmethod
    def blank_2hd(cls, name: bytes = b"BLANK") -> bytes:
        if len(name) > 17:
            raise ValueError("D88 disk name must be at most 17 bytes")

        image = bytearray([0x00]) * cls.DISK_SIZE
        image[:len(name)] = name
        image[0x1B] = 0x20  # D88 2HD media type
        struct.pack_into("<I", image, 0x1C, cls.DISK_SIZE)

        for track_index in range(cls.TRACK_COUNT):
            track_offset = cls.HEADER_SIZE + track_index * cls.TRACK_SIZE
            struct.pack_into("<I", image, 0x20 + track_index * 4,
                             track_offset)
            cylinder = track_index // 2
            head = track_index % 2
            for sector_index in range(cls.SECTORS_PER_TRACK):
                sector_offset = (
                    track_offset + sector_index * cls.SECTOR_RECORD_SIZE
                )
                image[sector_offset:sector_offset + 16] = bytes([
                    cylinder,
                    head,
                    sector_index + 1,
                    0x03,  # 1024-byte sector
                    cls.SECTORS_PER_TRACK,
                    0x00,
                    0x00,
                    0x00,
                    0x00,
                    0x00,
                    0x00,
                    0x00,
                    0x00,
                    0x00,
                    0x00,
                    0x04,
                ])
                data_start = sector_offset + 16
                image[data_start:data_start + cls.SECTOR_SIZE] = bytes(
                    [0xFF]
                ) * cls.SECTOR_SIZE

        for track_index, sector_index in cls.IPLD_LOCATIONS:
            ipld_data = (
                cls.HEADER_SIZE
                + track_index * cls.TRACK_SIZE
                + sector_index * cls.SECTOR_RECORD_SIZE
                + 16
            )
            image[ipld_data:ipld_data + 4] = b"IPLD"
            image[ipld_data + 0x200] = 0xFE
            image[ipld_data + 0x38B] = 0xFE

        return bytes(image)


def write_blank_2hd(path, name: bytes = b"BLANK") -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(D88.blank_2hd(name))
