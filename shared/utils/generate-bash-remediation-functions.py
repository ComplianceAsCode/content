#!/usr/bin/env python2

import sys
import os
import os.path
import argparse

try:
    from xml.etree import cElementTree as ElementTree
except ImportError:
    import cElementTree as ElementTree


def preprocess_source(filepath):
    raw = ""
    with open(filepath, "r") as f:
        raw = f.read()

    source = ""
    for line in raw.splitlines(True):
        if line.startswith("source ") and line.endswith(".sh\n"):
            included_file = line.strip()[7:]  # skip "source "
            with open(os.path.join(
                os.path.dirname(filepath), included_file), "r"
            ) as f:
                source += f.read()
                source += "\n"
        else:
            source += line

    return source


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--input_dir", required=True)
    p.add_argument("--output", type=argparse.FileType('w'), required=True)

    args, unknown = p.parse_known_args()
    if unknown:
        sys.stderr.write(
            "Unknown positional arguments " + ",".join(unknown) + ".\n"
        )
        sys.exit(1)

    root = ElementTree.Element("Group")
    root.set("id", "remediation_functions")
    title = ElementTree.SubElement(root, "title")
    title.text = "Remediation functions used by the SCAP Security Guide Project"
    description = ElementTree.SubElement(root, "description")
    description.text = "XCCDF form of the various remediation functions as " \
        "used by remediation scripts from the SCAP Security Guide Project."

    for file_ in os.listdir(args.input_dir):
        if not file_.endswith(".sh"):
            sys.stderr.write(
                "File '%s' does not appear to be a bash script. Skipping!"
                % (file_)
            )
            continue

        filename, ext = os.path.splitext(file_)

        source = preprocess_source(os.path.join(args.input_dir, file_))

        value_element = ElementTree.SubElement(root, "Value")
        value_element.set("id", "function_%s" % (filename))
        value_element.set("type", "string")
        value_element.set("operator", "equals")
        value_element.set("interactive", "0")
        value_element.set("hidden", "true")
        value_element.set("prohibitChanges", "true")

        title = ElementTree.SubElement(value_element, "title")
        title.text = "Remediation function %s" % (filename)

        desc = ElementTree.SubElement(value_element, "description")
        desc.text = "Shared bash remediation function. Not intended to be " \
            "changed by tailoring."

        inner_value = ElementTree.SubElement(value_element, "value")
        inner_value.set("selector", "")
        inner_value.text = source

    tree = ElementTree.ElementTree(root)
    tree.write(args.output)


if __name__ == "__main__":
    main()
