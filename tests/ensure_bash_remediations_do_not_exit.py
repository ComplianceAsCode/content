#!/usr/bin/python3

# Rule Bash remediations are concatenated into the profile remediation
# scripts. A bare "exit" or "exit 0" in one of them ends the whole script
# with a success status, and the remediations of all following rules are
# skipped. Use an if/else branch instead.

import os
import re
import sys


EXIT_RE = re.compile(r"^\s*exit(\s+0)?\s*(#.*)?$")
DIRS = ["linux_os", "applications", "apple_os", os.path.join("shared", "templates")]


def is_bash_remediation(path):
    return (os.path.basename(os.path.dirname(path)) == "bash" and path.endswith(".sh")) \
        or os.path.basename(path) == "bash.template"


def main():
    ssg_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    found = []
    for top in DIRS:
        for dir_, _, files in os.walk(os.path.join(ssg_root, top)):
            for file_ in files:
                path = os.path.join(dir_, file_)
                if not is_bash_remediation(path):
                    continue
                with open(path, "r") as f:
                    for lineno, line in enumerate(f, 1):
                        if EXIT_RE.match(line):
                            found.append("%s:%d: %s" % (
                                os.path.relpath(path, ssg_root), lineno, line.strip()))
    if found:
        print("These Bash remediations exit, which stops the profile "
              "remediation script before the following rules are remediated:",
              file=sys.stderr)
        for item in found:
            print("  " + item, file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
