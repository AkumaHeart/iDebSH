#!/usr/bin/env python3
import os
import sys

# Forward to gen_apt_sources.py for Debian APT sources generation
script_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, script_dir)
from gen_apt_sources import *

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
