#!/usr/bin/python2

import sys
import os
import os.path
import xml.etree.ElementTree as ET
import pyaml
import collections
import codecs


def pyaml_dump(data):
    return pyaml.dump(data, indent=4, width=1000, vspacing=1)


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


def dump_variable(target_dir, element):
    id_ = element.get("id")
    type_ = element.get("type")
    operator = element.get("operator")
    interactive = element.get("interactive") \
        in ["1", "true", "True", "yes", "Yes"]

    title = element_value("title", element).strip()
    description = element_value("description", element).strip()

    options = {}
    for value in element.findall("./value"):
        sel = value.get("selector", "default")
        if sel == "":
            sel = "default"
        options[sel] = value.text

    yml_data = collections.OrderedDict([
        ("documentation_complete", "true"),
        ("title", title),
        ("description", description),
        ("type", type_),
        ("operator", operator),
        ("interactive", interactive),
        ("options", options),
    ])

    target_file = os.path.join(target_dir, id_ + ".var")
    with codecs.open(target_file, "w", "utf8") as f:
        f.write(pyaml_dump(yml_data))


def dump_rule(target_dir, element):
    id_ = element.get("id")
    print id_
    severity = element.get("severity", "unknown")
    rule_prodtype = element.get("prodtype", "all")

    title = element_value("title", element).strip()
    description = element_value("description", element).strip()
    rationale = element_value("rationale", element).strip()

    idents = {}
    prodtype = None
    for ident in element.findall("ident"):
        prodtype = ident.get("prodtype")
        for atr in ident.attrib:
            if atr == "prodtype":
                continue

            if prodtype:
                idents[atr + "@" + prodtype] = unicode(ident.get(atr))
            else:
                idents[atr] = unicode(ident.get(atr))

    references = {}
    prodtype = None
    for reference in element.findall("ref"):
        prodtype = reference.get("prodtype")
        for atr in reference.attrib:
            if atr == "prodtype":
                continue

            if prodtype:
                references[atr + "@" + prodtype] = unicode(reference.get(atr))
            else:
                references[atr] = unicode(reference.get(atr))

    ocils = element.findall("ocil")
    ocil_clause = None
    ocil_contents = None
    assert(len(ocils) <= 1)
    for ocil in ocils:
        ocil_clause = ocil.get("clause", None)
        ocil_contents = element_value("ocil", element).strip()

    yml_data = collections.OrderedDict([
        ("documentation_complete", "true")])
    if rule_prodtype != "all":
        yml_data["prodtype"] = rule_prodtype
    yml_data["title"] = title
    yml_data["description"] = description
    yml_data["rationale"] = rationale
    yml_data["severity"] = severity

    if idents:
        yml_data["identifiers"] = idents

    if references:
        yml_data["references"] = references

    if ocil_clause:
        assert(ocil_contents is not None)
        yml_data["ocil_clause"] = ocil_clause

    if ocil_contents:
        yml_data["ocil"] = ocil_contents

    target_file = os.path.join(target_dir, id_ + ".rule")
    with codecs.open(target_file, "w", "utf8") as f:
        f.write(pyaml_dump(yml_data))


def dump_group(target_dir, element):
    id_ = element.get("id")
    group_prodtype = element.get("prodtype", "all")
    title = element_value("title", element).strip()
    description = element_value("description", element).strip()

    yml_data = collections.OrderedDict([
        ("documentation_complete", "true")])
    if group_prodtype != "all":
        yml_data["prodtype"] = group_prodtype
    yml_data["title"] = title
    yml_data["description"] = description

    target_group_dir = os.path.join(target_dir, id_)
    if not os.path.isdir(target_group_dir):
        os.makedirs(target_group_dir)
    target_file = os.path.join(target_group_dir, id_ + ".group")

    with codecs.open(target_file, "w", "utf8") as f:
        f.write(pyaml_dump(yml_data))

    for group in element.findall("./Group"):
        dump_group(target_group_dir, group)

    for value in element.findall("./Value"):
        dump_variable(target_group_dir, value)

    for rule in element.findall("./Rule"):
        dump_rule(target_group_dir, rule)


def dump_dir(target, path):
    for dir_ in os.listdir(path):
        full_path = os.path.join(path, dir_)
        if os.path.isfile(full_path):
            tree = ET.parse(full_path)
            root = tree.getroot()

            if root.tag == "Group":
                dump_group(target, root)

        elif os.path.isdir(full_path):
            dump_dir(os.path.join(target, dir_), full_path)


def main():
    root = sys.argv[1]
    target = sys.argv[2]

    dump_dir(target, root)


if __name__ == "__main__":
    main()
