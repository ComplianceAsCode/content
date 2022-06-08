from __future__ import print_function

import sys
import os

import importlib

automatus = importlib.import_module("automatus")


if __name__ == "__main__":
    msg = (
        "WARNING - "
        "You call Automatus using the legacy '{old_fname}' script, "
        "use the '{new_fname}' instead"
        .format(old_fname=os.path.basename(__file__), new_fname="automatus.py"))

    print(msg, file=sys.stderr)
    print(file=sys.stderr)

    ret = automatus.main()

    print(file=sys.stderr)
    print(msg, file=sys.stderr)
