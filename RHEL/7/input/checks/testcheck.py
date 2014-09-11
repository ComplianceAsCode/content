#!/usr/bin/python

import sys

# always use shared/testcheck_module.py version
SHARED_TESTCHECK_MODULE_PATH = "../../../../shared/"
sys.path.insert(0, SHARED_TESTCHECK_MODULE_PATH)
import testcheck_module

if __name__ == "__main__":
    testcheck_module.main()
