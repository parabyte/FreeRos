from pathlib import Path
import sys


ROS_SIZE = 0x4000
CHECKSUM_REL_OFFSET = 0x3FF5


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: fix_ros_checksum.py <rom>", file=sys.stderr)
        return 1

    path = Path(sys.argv[1])
    data = bytearray(path.read_bytes())
    rom_size = len(data)
    if rom_size < ROS_SIZE or (rom_size & (rom_size - 1)) != 0:
        print(f"unexpected ROM size: {rom_size}", file=sys.stderr)
        return 1

    ros_start = rom_size - ROS_SIZE
    checksum_offset = ros_start + CHECKSUM_REL_OFFSET

    data[checksum_offset] = 0
    checksum = (-sum(data[ros_start : ros_start + ROS_SIZE])) & 0xFF
    data[checksum_offset] = checksum
    path.write_bytes(data)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
