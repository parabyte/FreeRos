#!/usr/bin/env python3
"""Read from a PTY slave and write all received bytes to a file.

Usage: capture_pty.py <pty_path> <output_file>

Opens the PTY slave in raw mode, reads until the master side closes
(EIO), then exits cleanly.  Flushes after every read so partial
output is always on disk.
"""

import errno
import os
import sys
import termios
import tty


def main():
    if len(sys.argv) != 3:
        print(f"usage: {sys.argv[0]} <pty_path> <output_file>", file=sys.stderr)
        sys.exit(1)

    pty_path = sys.argv[1]
    out_path = sys.argv[2]

    fd = os.open(pty_path, os.O_RDWR | os.O_NOCTTY)
    try:
        tty.setraw(fd)
        old = termios.tcgetattr(fd)
        old[6][termios.VMIN] = 1
        old[6][termios.VTIME] = 0
        termios.tcsetattr(fd, termios.TCSANOW, old)
    except termios.error:
        pass

    with open(out_path, "wb") as out:
        while True:
            try:
                data = os.read(fd, 4096)
            except OSError as e:
                if e.errno == errno.EIO:
                    break
                raise
            if not data:
                break
            out.write(data)
            out.flush()

    os.close(fd)


if __name__ == "__main__":
    main()
