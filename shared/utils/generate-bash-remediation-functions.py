#!/usr/bin/python2

import sys
import os
import os.path
import argparse

try:
    from xml.etree import cElementTree as ElementTree
except ImportError:
    import cElementTree as ElementTree


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
        filename, ext = os.path.splitext(file_)

        source = ""
        with open(os.path.join(args.input_dir, file_), "r") as f:
            source = f.read()

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

    args.output.write(ElementTree.tostring(root))


if __name__ == "__main__":
    main()
