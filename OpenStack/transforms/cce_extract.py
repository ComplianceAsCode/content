#!/usr/bin/python

import sys

# always use shared/modules version
SHARED_MODULE_PATH = "../../../shared/modules"
sys.path.insert(0, SHARED_MODULE_PATH)
import cce_extract_module

if __name__ == "__main__":
    cce_extract_module.main()
