from __future__ import print_function

import re
import sys
import argparse
import os

from ssg._xml import ElementTree as ET
from ssg._constants import dc_ns, stig_owner, all_stig_ns, XCCDF11_NS


def element_value(element, element_obj):
    for elem in element_obj.findall("./{%s}%s" % (XCCDF11_NS, element)):
        elem = elem.text
    try:
        return elem
    except UnboundLocalError as e:
        return ""


def ssg_xccdf_stigid_mapping(ssgtree):
    xccdftostig_idmapping = {}

    for rule in ssgtree.findall(".//{%s}Rule" % XCCDF11_NS):
        srgs = []
        rhid = ""

        xccdfid = rule.get("id")
        if xccdfid is not None:
            for references in all_stig_ns:
                stig = [ids for ids in rule.findall(".//{%s}reference[@href='%s']" % (XCCDF11_NS, references))]
                for ref in reversed(stig):
                    if not ref.text.startswith("SRG-"):
                        rhid = ref.text
                    else:
                        srgs.append(ref.text)
            xccdftostig_idmapping.update({rhid: {xccdfid: srgs}})

    return xccdftostig_idmapping


def get_nested_stig_items(ssg_mapping, srg):
    mapped_id = "XXXX"
    for rhid, srgs in ssg_mapping.iteritems():
        for xccdfid, srglist in srgs.iteritems():
            if srg in srglist and len(srglist) > 1:
                mapped_id = xccdfid
                break

    return mapped_id


def getkey(elem):
    return elem.get("ownerid")


def new_stig_overlay(xccdftree, ssgtree, outfile,
                     overlayfile=False):
    if not ssgtree:
        ssg_mapping = False
    else:
        ssg_mapping = ssg_xccdf_stigid_mapping(ssgtree)

    new_stig_overlay = ET.Element("overlays", xmlns=XCCDF11_NS)
    for group in xccdftree.findall("./{%s}Group" % XCCDF11_NS):
        vkey = group.get("id").strip('V-')
        for title in group.findall("./{%s}title" % XCCDF11_NS):
            srg = title.text
        for rule in group.findall("./{%s}Rule" % XCCDF11_NS):
            svkey_raw = rule.get("id")
            svkey = svkey_raw.strip()[3:-7]
            severity = rule.get("severity")
            release = svkey_raw.strip()[9:-5]
            version = element_value("version", rule)
            rule_title = element_value("title", rule)
            ident = element_value("ident", rule).strip("CCI-").lstrip("0")

        if not ssgtree:
            mapped_id = "XXXX"
        else:
            try:
                mapped_id = ''.join(ssg_mapping[version].keys())
            except KeyError as e:
                mapped_id = get_nested_stig_items(ssg_mapping, srg)

        overlay = ET.SubElement(new_stig_overlay, "overlay", owner=stig_owner,
                                ruleid=mapped_id, ownerid=version, disa=ident,
                                severity=severity)
        vmsinfo = ET.SubElement(overlay, "VMSinfo", VKey=vkey,
                                SVKey=svkey, VRelease=release)
        title = ET.SubElement(vmsinfo, "title")
        title.text = rule_title
        new_stig_overlay.append(overlay)
        overlay.append(vmsinfo)
        overlay.append(title)

    lines = new_stig_overlay.findall("overlay")
    new_stig_overlay[:] = sorted(lines, key=getkey)
    tree = ET.ElementTree(new_stig_overlay)
    tree.write(outfile, pretty_print=True, encoding="UTF-8",
               xml_declaration=True)
    print("\nGenerated the new STIG overlay file: %s" % outfile)
