#!/usr/bin/python2

import sys
import os
import os.path
import xml.etree.ElementTree as ET
import pyaml
import collections
import codecs


def pyaml_dump(data):
    return pyaml.dump(data, indent=4, width=120, vspacing=1)


def element_value(element, element_obj):
    for elem in element_obj.findall("./%s" % (element)):
        text = elem.text
        if text is None:
            text = ""

        text += "".join(ET.tostring(e) for e in elem)
    try:
        return text
    except UnboundLocalError:
        return ""


def dump_profile(target_file, element):
    basename, ext = os.path.splitext(os.path.basename(target_file))

    id_ = element.get("id")
    print(id_)
    print(basename)

    # oh my...
    if id_ not in ["stig-rhevh-upstream", "nist-cl-il-al"]:
        assert(id_ == basename)

    extends = element.get("extends")

    title = element_value("title", element).strip()
    description = element_value("description", element).strip()

    yml_data = collections.OrderedDict([
        ("documentation_complete", "true"),
        ("title", title),
        ("description", description)
    ])

    if extends is not None:
        yml_data["extends"] = extends

    contents = []

    for el in element:
        if el.tag == "select":
            selected = el.get("selected")
            selected_idref = el.get("idref")
            assert(selected is not None)
            if selected == "true":
                contents.append("%s" % (selected_idref))
            else:
                contents.append("!%s" % (selected_idref))

        elif el.tag == "refine-value":
            refine_idref = el.get("idref")
            selector = el.get("selector")
            contents.append("%s=%s" % (refine_idref, selector))

        elif el.tag == "set-value":
            assert(False)

    yml_data["selections"] = contents

    with codecs.open(target_file, "w", "utf8") as f:
        f.write(pyaml_dump(yml_data))


def dump_dir(target, path):
    for dir_ in os.listdir(path):
        full_path = os.path.join(path, dir_)

        if not os.path.isfile(full_path):
            continue

        basename, ext = os.path.splitext(os.path.basename(full_path))

        if ext != ".xml":
            continue

        tree = ET.parse(full_path)
        root = tree.getroot()

        target_file = os.path.join(target, basename + ".yml")
        dump_profile(target_file, root)


def main():
    root = sys.argv[1]
    target = sys.argv[2]

    dump_dir(target, root)


if __name__ == "__main__":
    main()
