#!/usr/bin/env python3
import os
import sys

# Define standard Debian mirrors for i386
DEBIAN_MIRROR = "http://deb.debian.org/debian"
SUITE = "bookworm"

def generate_sources_list():
    lines = [
        f"deb {DEBIAN_MIRROR} {SUITE} main contrib non-free non-free-firmware\n",
        f"deb {DEBIAN_MIRROR} {SUITE}-updates main contrib non-free non-free-firmware\n",
        f"deb http://security.debian.org/debian-security {SUITE}-security main contrib non-free non-free-firmware\n"
    ]
    return "".join(lines)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        out_path = sys.argv[1]
    elif "BUILT_PRODUCTS_DIR" in os.environ and "CONTENTS_FOLDER_PATH" in os.environ:
        out_path = os.path.join(
            os.environ["BUILT_PRODUCTS_DIR"],
            os.environ["CONTENTS_FOLDER_PATH"],
            "sources.list"
        )
    else:
        out_path = "sources.list"

    os.makedirs(os.path.dirname(os.path.abspath(out_path)), exist_ok=True)
    with open(out_path, "w") as f:
        f.write(generate_sources_list())
