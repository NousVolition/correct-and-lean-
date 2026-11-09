#!/usr/bin/env python3
"""Reject personal absolute home paths in tracked text and supported document formats."""
import base64
import io
import os
import re
import subprocess
import sys
import zipfile
import zlib
from pathlib import Path

HOME_PATH = re.compile(rb"(?i)(?:[a-z]:[/\\]+users[/\\]+|/mnt/[a-z]/users/|(?<![a-z0-9])/(?:home|Users)/)[a-z0-9_][a-z0-9_.-]*")
STREAM = re.compile(rb"(<<[^<>]{0,8192}/FlateDecode[^<>]{0,8192}>>)\s*stream\r?\n(.*?)\r?\nendstream", re.S)


def contains_path(data):
    # ASCII paths can also be stored as UTF-16 in office documents and PDF metadata.
    return bool(HOME_PATH.search(data) or (b"\0" in data and HOME_PATH.search(data.replace(b"\0", b""))))


def check_content(path, data):
    if contains_path(data):
        return True
    if path.suffix.lower() in {".docx", ".xlsx", ".pptx", ".zip", ".npz"}:
        with zipfile.ZipFile(io.BytesIO(data)) as archive:
            return any(contains_path(member.filename.encode()) or contains_path(archive.read(member))
                       for member in archive.infolist() if not member.is_dir())
    if path.suffix.lower() == ".pdf":
        for match in STREAM.finditer(data):
            compressed = match[2]
            if b"/ASCII85Decode" in match[1]:
                compressed = base64.a85decode(compressed, adobe=True)
            if contains_path(zlib.decompress(compressed)):
                return True
    return False


def main():
    paths = subprocess.check_output(["git", "ls-files", "--cached", "--others", "--exclude-standard", "-z"])
    leaks = []
    for raw in sorted(set(paths.split(b"\0")) - {b""}):
        path = Path(os.fsdecode(raw))
        if path.is_file() and check_content(path, path.read_bytes()):
            leaks.append(path)
    if leaks:
        for path in leaks:
            print(f"{path}: contains an absolute home path", file=sys.stderr)
        return 1
    print("No personal home paths found in the public files checked.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
