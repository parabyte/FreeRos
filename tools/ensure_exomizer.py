"""
Fetch and build the upstream Exomizer tool on demand.

The first build downloads the official 3.1.2 source zip, verifies it, and
builds the local `exomizer` binary under the requested output tree.
"""

from __future__ import annotations

import hashlib
import os
import subprocess
import sys
import urllib.request
import zipfile
from pathlib import Path

EXOMIZER_VERSION = "3.1.2"
EXOMIZER_URL = (
    f"https://bitbucket.org/magli143/exomizer/wiki/downloads/"
    f"exomizer-{EXOMIZER_VERSION}.zip"
)
EXOMIZER_SHA256 = (
    "8896285e48e89e29ba962bc37d8f4dcd506a95753ed9b8ebf60e43893c36ce3a"
)


def sha256_path(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def download(url: str, dst: Path) -> None:
    dst.parent.mkdir(parents=True, exist_ok=True)
    with urllib.request.urlopen(url) as response, dst.open("wb") as handle:
        while True:
            chunk = response.read(1024 * 1024)
            if not chunk:
                break
            handle.write(chunk)


def ensure_archive(path: Path) -> None:
    if not path.exists():
        print(f"downloading Exomizer {EXOMIZER_VERSION}", file=sys.stderr)
        download(EXOMIZER_URL, path)
    digest = sha256_path(path)
    if digest != EXOMIZER_SHA256:
        raise SystemExit(
            f"ERROR: checksum mismatch for {path} "
            f"(expected {EXOMIZER_SHA256}, got {digest})"
        )


def extract_archive(archive: Path, root: Path) -> None:
    marker = root / "src" / "Makefile"
    if marker.exists():
        return
    with zipfile.ZipFile(archive) as zf:
        zf.extractall(root)
    if not marker.exists():
        raise SystemExit(f"ERROR: failed to extract Exomizer into {root}")


def build_exomizer(root: Path) -> Path:
    src_dir = root / "src"
    subprocess.check_call(["make"], cwd=src_dir)
    binary = src_dir / "exomizer"
    if not binary.exists():
        raise SystemExit(f"ERROR: build succeeded but {binary} is missing")
    binary.chmod(binary.stat().st_mode | 0o111)
    return binary


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: ensure_exomizer.py <output-executable>", file=sys.stderr)
        return 1

    output = Path(sys.argv[1])
    if output.exists() and os.access(output, os.X_OK):
        return 0

    source_root = output.parent.parent
    source_root.mkdir(parents=True, exist_ok=True)
    archive = source_root / f"exomizer-{EXOMIZER_VERSION}.zip"

    ensure_archive(archive)
    extract_archive(archive, source_root)
    built = build_exomizer(source_root)

    if built != output:
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_bytes(built.read_bytes())
        output.chmod(output.stat().st_mode | 0o111)

    print(f"ready: {output}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
