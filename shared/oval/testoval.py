#!/usr/bin/python

import sys

# always use shared/testoval_module.py version
SHARED_MODULE_PATH = "../modules/"
sys.path.insert(0, SHARED_MODULE_PATH)
import testoval_module

if __name__ == "__main__":
    testoval_module.main()
