#!/usr/bin/env python2

import sys
import os

# always use shared/testoval_module.py version
script_directory = os.path.dirname(os.path.realpath(__file__))
SHARED_MODULE_PATH = os.path.join(script_directory, "..", "modules")

sys.path.insert(0, SHARED_MODULE_PATH)
import testoval_module

if __name__ == "__main__":
    testoval_module.main()
