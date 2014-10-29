#!/usr/bin/python

import sys

# always use shared/testcheck_module.py version
SHARED_MODULE_PATH = "../modules/"
sys.path.insert(0, SHARED_MODULE_PATH)
import testcheck_module

if __name__ == "__main__":
    testcheck_module.main()
