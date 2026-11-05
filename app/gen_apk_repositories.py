#!/usr/bin/env python3
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
    out_path = sys.argv[1] if len(sys.argv) > 1 else "sources.list"
    with open(out_path, "w") as f:
        f.write(generate_sources_list())
    #print(f"Generated sources.list at {out_path}")
