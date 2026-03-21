from pathlib import Path
import sys


ROS_OFFSET = 0x0000
ROS_SIZE = 0x4000
CHECKSUM_OFFSET = 0x3FF5
ROM_SIZE = 0x4000


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: fix_ros_checksum.py <rom>", file=sys.stderr)
        return 1

    path = Path(sys.argv[1])
    data = bytearray(path.read_bytes())
    if len(data) != ROM_SIZE:
        print(f"unexpected ROM size: {len(data)}", file=sys.stderr)
        return 1

    data[CHECKSUM_OFFSET] = 0
    checksum = (-sum(data[ROS_OFFSET : ROS_OFFSET + ROS_SIZE])) & 0xFF
    data[CHECKSUM_OFFSET] = checksum
    path.write_bytes(data)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
