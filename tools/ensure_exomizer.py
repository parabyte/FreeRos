"""
Fetch and build the upstream Exomizer tool on demand.

The build runs in a disposable temporary tree and installs only the local
`exomizer` binary plus a small version stamp under the requested output tree.
That keeps the project from retaining the full upstream source dump in `build/`.
"""

from __future__ import annotations

import hashlib
import os
import subprocess
import sys
import tempfile
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


def version_stamp_path(output: Path) -> Path:
    return output.parent / "exomizer.version.txt"


def output_is_current(output: Path) -> bool:
    stamp = version_stamp_path(output)
    if not (output.exists() and os.access(output, os.X_OK) and stamp.exists()):
        return False
    return stamp.read_text(encoding="utf-8").strip() == EXOMIZER_VERSION


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: ensure_exomizer.py <output-executable>", file=sys.stderr)
        return 1

    output = Path(sys.argv[1])
    if output_is_current(output):
        return 0

    output.parent.mkdir(parents=True, exist_ok=True)

    with tempfile.TemporaryDirectory(prefix="freeros-exomizer-") as temp_dir:
        temp_root = Path(temp_dir)
        archive = temp_root / f"exomizer-{EXOMIZER_VERSION}.zip"
        source_root = temp_root / "source"

        ensure_archive(archive)
        extract_archive(archive, source_root)
        built = build_exomizer(source_root)

        output.write_bytes(built.read_bytes())
        output.chmod(output.stat().st_mode | 0o111)

    version_stamp_path(output).write_text(f"{EXOMIZER_VERSION}\n", encoding="utf-8")

    print(f"ready: {output}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
