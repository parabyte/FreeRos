#!/usr/bin/env python3
"""Build a minimal El Torito bootable ISO for CD-ROM smoke testing.

Creates a standards-compliant ISO 9660 image with El Torito boot support.
The ISO contains:
  - ISO 9660 Primary Volume Descriptor at LBA 16
  - El Torito Boot Record Volume Descriptor at LBA 17
  - Boot Catalog at LBA 18
  - Boot Image starting at LBA 19
  - Volume Descriptor Set Terminator at LBA 20
"""

import argparse
import struct
import sys
from pathlib import Path

SECTOR_SIZE = 2048


def pad_sector(data: bytes) -> bytes:
    """Pad data to a full 2048-byte sector."""
    remainder = len(data) % SECTOR_SIZE
    if remainder:
        data += b"\x00" * (SECTOR_SIZE - remainder)
    return data


def make_pvd(vol_id: str, num_sectors: int) -> bytes:
    """Build ISO 9660 Primary Volume Descriptor (type 1)."""
    sector = bytearray(SECTOR_SIZE)
    sector[0] = 0x01  # Type: PVD
    sector[1:6] = b"CD001"  # Standard Identifier
    sector[6] = 0x01  # Version
    # System Identifier (32 bytes, padded with spaces)
    sys_id = b"FREEROS TEST".ljust(32)
    sector[8:40] = sys_id
    # Volume Identifier (32 bytes, padded with spaces)
    vol = vol_id.encode("ascii").ljust(32)
    sector[40:72] = vol
    # Volume Space Size (both-endian 32-bit)
    sector[80:84] = struct.pack("<I", num_sectors)
    sector[84:88] = struct.pack(">I", num_sectors)
    # Volume Set Size (both-endian 16-bit) = 1
    sector[120:122] = struct.pack("<H", 1)
    sector[122:124] = struct.pack(">H", 1)
    # Volume Sequence Number = 1
    sector[124:126] = struct.pack("<H", 1)
    sector[126:128] = struct.pack(">H", 1)
    # Logical Block Size (both-endian 16-bit) = 2048
    sector[128:130] = struct.pack("<H", SECTOR_SIZE)
    sector[130:132] = struct.pack(">H", SECTOR_SIZE)
    # Root directory record at LBA 21
    # Minimal root directory record (34 bytes)
    root_dr = bytearray(34)
    root_dr[0] = 34  # Length of directory record
    root_dr[1] = 0   # Extended Attribute Record Length
    root_dr[2:6] = struct.pack("<I", 21)   # Location of Extent (LE)
    root_dr[6:10] = struct.pack(">I", 21)  # Location of Extent (BE)
    root_dr[10:14] = struct.pack("<I", SECTOR_SIZE)  # Data Length (LE)
    root_dr[14:18] = struct.pack(">I", SECTOR_SIZE)  # Data Length (BE)
    # Recording date/time (7 bytes): 1988-01-01 00:00:00 GMT
    root_dr[18] = 88   # Years since 1900
    root_dr[19] = 1    # Month
    root_dr[20] = 1    # Day
    root_dr[21] = 0    # Hour
    root_dr[22] = 0    # Minute
    root_dr[23] = 0    # Second
    root_dr[24] = 0    # GMT offset
    root_dr[25] = 0x02  # File flags: directory
    root_dr[32] = 1    # Length of file identifier
    root_dr[33] = 0x00  # File identifier (root)
    sector[156:190] = root_dr
    return bytes(sector)


def make_brvd(catalog_lba: int) -> bytes:
    """Build El Torito Boot Record Volume Descriptor (type 0)."""
    sector = bytearray(SECTOR_SIZE)
    sector[0] = 0x00  # Type: Boot Record
    sector[1:6] = b"CD001"  # Standard Identifier
    sector[6] = 0x01  # Version
    # Boot System Identifier: "EL TORITO SPECIFICATION" padded to 32 bytes
    boot_sys_id = b"EL TORITO SPECIFICATION".ljust(32, b"\x00")
    sector[7:39] = boot_sys_id
    # Boot Catalog LBA at offset 71 (little-endian 32-bit)
    struct.pack_into("<I", sector, 71, catalog_lba)
    return bytes(sector)


def make_vdst() -> bytes:
    """Build Volume Descriptor Set Terminator (type 255)."""
    sector = bytearray(SECTOR_SIZE)
    sector[0] = 0xFF  # Type: VDST
    sector[1:6] = b"CD001"  # Standard Identifier
    sector[6] = 0x01  # Version
    return bytes(sector)


def make_boot_catalog(image_lba: int, image_sectors: int,
                      load_segment: int = 0x0000,
                      media_type: int = 0) -> bytes:
    """Build El Torito Boot Catalog (Validation Entry + Default Entry)."""
    sector = bytearray(SECTOR_SIZE)

    # Validation Entry (32 bytes)
    sector[0] = 0x01  # Header ID
    sector[1] = 0x00  # Platform ID (0 = x86)
    sector[2:4] = b"\x00\x00"  # Reserved
    # ID string (24 bytes)
    id_str = b"FREEROS CDROM TEST".ljust(24, b"\x00")
    sector[4:28] = id_str
    sector[28:30] = b"\x00\x00"  # Checksum placeholder
    sector[30] = 0x55  # Key byte 1
    sector[31] = 0xAA  # Key byte 2

    # Compute checksum: sum of all 16-bit words in the entry must be 0
    checksum = 0
    for i in range(0, 32, 2):
        checksum += struct.unpack_from("<H", sector, i)[0]
    checksum = (-checksum) & 0xFFFF
    struct.pack_into("<H", sector, 28, checksum)

    # Verify
    verify = 0
    for i in range(0, 32, 2):
        verify += struct.unpack_from("<H", sector, i)[0]
    assert (verify & 0xFFFF) == 0, f"Checksum verification failed: {verify:#06x}"

    # Default Entry (32 bytes, at offset 32)
    sector[32] = 0x88  # Boot Indicator (0x88 = bootable)
    sector[33] = media_type  # Boot Media Type (0 = no emulation)
    struct.pack_into("<H", sector, 34, load_segment)  # Load Segment
    sector[36] = 0x00  # System Type
    sector[37] = 0x00  # Reserved
    # Sector Count (in 512-byte virtual sectors)
    struct.pack_into("<H", sector, 38, image_sectors)
    # Load RBA (LBA of boot image)
    struct.pack_into("<I", sector, 40, image_lba)
    # Reserved (20 bytes)

    return bytes(sector)


def make_root_directory(image_lba: int, image_size: int) -> bytes:
    """Build a minimal root directory with self/parent entries and boot image."""
    sector = bytearray(SECTOR_SIZE)
    off = 0

    # Self entry (.)
    rec = bytearray(34)
    rec[0] = 34
    rec[2:6] = struct.pack("<I", 21)
    rec[6:10] = struct.pack(">I", 21)
    rec[10:14] = struct.pack("<I", SECTOR_SIZE)
    rec[14:18] = struct.pack(">I", SECTOR_SIZE)
    rec[18] = 88; rec[19] = 1; rec[20] = 1
    rec[25] = 0x02
    rec[32] = 1
    rec[33] = 0x00
    sector[off:off + 34] = rec
    off += 34

    # Parent entry (..)
    rec[33] = 0x01
    sector[off:off + 34] = rec
    off += 34

    # Boot image file entry: "BOOT.IMG;1"
    fname = b"BOOT.IMG;1"
    rec_len = 33 + len(fname)
    if rec_len & 1:
        rec_len += 1  # Pad to even
    frec = bytearray(rec_len)
    frec[0] = rec_len
    frec[2:6] = struct.pack("<I", image_lba)
    frec[6:10] = struct.pack(">I", image_lba)
    frec[10:14] = struct.pack("<I", image_size)
    frec[14:18] = struct.pack(">I", image_size)
    frec[18] = 88; frec[19] = 1; frec[20] = 1
    frec[25] = 0x00  # File, not directory
    frec[32] = len(fname)
    frec[33:33 + len(fname)] = fname
    sector[off:off + rec_len] = frec

    return bytes(sector)


def build_iso(boot_image_path: str, output_path: str,
              vol_id: str = "CDROM_TEST",
              load_segment: int = 0x0000,
              media_type: int = 0):
    """Build a complete bootable ISO image."""
    boot_image = Path(boot_image_path).read_bytes()
    boot_image = pad_sector(boot_image)
    image_cd_sectors = len(boot_image) // SECTOR_SIZE
    # Sector count in 512-byte units for the boot catalog
    image_512_sectors = len(boot_image) // 512

    # ISO layout:
    # LBA 0-15:  System Area (zeros)
    # LBA 16:    Primary Volume Descriptor
    # LBA 17:    Boot Record Volume Descriptor (El Torito)
    # LBA 18:    Volume Descriptor Set Terminator
    # LBA 19:    Boot Catalog
    # LBA 20:    Boot Image (may span multiple sectors)
    # LBA 20+N:  Root Directory
    catalog_lba = 19
    image_lba = 20
    root_dir_lba = image_lba + image_cd_sectors
    total_sectors = root_dir_lba + 1

    iso = bytearray()

    # System area: 16 sectors of zeros
    iso += b"\x00" * (16 * SECTOR_SIZE)

    # LBA 16: PVD
    pvd = bytearray(make_pvd(vol_id, total_sectors))
    # Fix root directory record to point to correct LBA
    struct.pack_into("<I", pvd, 156 + 2, root_dir_lba)
    struct.pack_into(">I", pvd, 156 + 6, root_dir_lba)
    iso += pvd

    # LBA 17: BRVD
    iso += make_brvd(catalog_lba)

    # LBA 18: VDST
    iso += make_vdst()

    # LBA 19: Boot Catalog
    iso += make_boot_catalog(image_lba, image_512_sectors,
                             load_segment, media_type)

    # LBA 20+: Boot Image
    iso += boot_image

    # Root Directory
    iso += make_root_directory(image_lba, len(boot_image))

    Path(output_path).write_bytes(iso)
    print(f"ISO image: {len(iso)} bytes, {total_sectors} sectors, "
          f"boot image: {len(boot_image)} bytes ({image_cd_sectors} CD sectors)")


def main():
    parser = argparse.ArgumentParser(
        description="Build a minimal El Torito bootable ISO for testing")
    parser.add_argument("--boot-image", required=True,
                        help="Path to the boot image binary")
    parser.add_argument("--output", required=True,
                        help="Output ISO file path")
    parser.add_argument("--volume-id", default="CDROM_TEST",
                        help="Volume identifier (default: CDROM_TEST)")
    parser.add_argument("--load-segment", default="0x0000", type=str,
                        help="Load segment (default: 0x0000 = use 0x07C0)")
    parser.add_argument("--media-type", default=0, type=int,
                        help="Media type: 0=no-emul, 1=1.2M, 2=1.44M, 4=HDD")
    args = parser.parse_args()

    load_seg = int(args.load_segment, 0)
    build_iso(args.boot_image, args.output, args.volume_id,
              load_seg, args.media_type)


if __name__ == "__main__":
    main()
