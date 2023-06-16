#!/usr/bin/env python

import os
from xml.etree import ElementTree

NAMESPACES = dict(
    xccdf_ns="http://scap.nist.gov/schema/scap/source/1.2",
    profile_ns="http://checklists.nist.gov/xccdf/1.2",
)

SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))


def fname_to_etree(fname):
    input_tree = ElementTree.parse(fname)
    return input_tree


def get_profiles_from_etree(tree):
    xpath_expr = ".//{%s}Profile" % NAMESPACES["profile_ns"]
    xccdfs = tree.findall(xpath_expr)
    return xccdfs


def get_selections_from_etree(tree):
    xpath_expr = ".//{%s}select" % NAMESPACES["profile_ns"]
    xccdfs = tree.findall(xpath_expr)
    return xccdfs


def get_rules_from_etree(tree):
    xpath_expr = ".//{%s}Rule" % NAMESPACES["profile_ns"]
    xccdfs = tree.findall(xpath_expr)
    return xccdfs


def extract_tree_from_file(fname):
    return fname_to_etree(fname)


def get_ds_stats(filename):
    tree = extract_tree_from_file(filename)
    profiles = sorted(get_profiles_from_etree(tree), key=lambda x: x.attrib["id"])
    rules = sorted(get_rules_from_etree(tree), key=lambda x: x.attrib["id"])
    yield f"Found {len(profiles)} profiles, {len(rules)} rules\n"
    rules_selections = {}
    for p in profiles:
        p_id = p.attrib["id"].removeprefix("xccdf_org.ssgproject.content_")
        selections = sorted(get_selections_from_etree(p), key=lambda x: x.attrib["idref"])
        yield f"{p_id} (selections: {len(selections)})\n"
        for sel in selections:
            r_id = sel.attrib["idref"].removeprefix("xccdf_org.ssgproject.content_")
            r_selected = sel.attrib["selected"].lower() == "true"
            yield f"   {'+' if r_selected else '-'}{r_id}\n"
            r_stats = rules_selections.get(r_id, {"selected": 0, "unselected": 0})
            r_stats["selected" if r_selected else "unselected"] += 1
            rules_selections[r_id] = r_stats
    for r in rules:
        r_id = r.attrib["id"].removeprefix("xccdf_org.ssgproject.content_")
        r_selected = r.attrib["selected"].lower() == "true"
        in_profiles = f"selected: {rules_selections[r_id]['selected']}, unselected: {rules_selections[r_id]['unselected']}" if r_id in rules_selections else "absent"
        yield f"{'+' if r_selected else '-'}{r_id} (profiles: {in_profiles})\n"


if __name__ == "__main__":
    for d in os.listdir(f"{SSG_ROOT}/products"):
        fn = f"{SSG_ROOT}/build/ssg-{d}-ds.xml"
        if os.path.isfile(fn):
            stats = get_ds_stats(fn)
            with open(f"{SSG_ROOT}/build/ssg-{d}-ds.prof-stats", "w") as f:
                print(f"Writing stats for {d}")
                f.writelines(stats)
