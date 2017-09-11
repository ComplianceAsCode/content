#!/usr/bin/env python2

import re
import sys
import optparse
import os
import copy
import lxml.etree as ET


owner = "disastig"
stig_ns = "http://iase.disa.mil/stigs/os/unix-linux/Pages/index.aspx"
xccdf_ns = "http://checklists.nist.gov/xccdf/1.1"
dc_ns = "http://purl.org/dc/elements/1.1/"
outfile = "stig_overlay.xml"
legacyfile = "legacy_stig_overlay.xml"


def yes_no_prompt():
    prompt = "Would you like to proceed? (Y/N): "

    while True:
        data = str(raw_input(prompt)).lower()

        if data in ("yes", "y"):
            return True
        elif data in ("n", "no"):
            return False


def element_value(element, element_obj):
    for elem in element_obj.findall("./{%s}%s" % (xccdf_ns, element)):
        elem = elem.text
    try:
        return elem
    except UnboundLocalError as e:
        return ""


def ssg_xccdf_stigid_mapping(ssgtree):
    xccdftostig_idmapping = {}

    for rule in ssgtree.findall(".//{%s}Rule" % xccdf_ns):
        xccdfid = rule.get("id")
        if xccdfid is not None:
            ident_stig_id = rule.find("./{%s}ident[@system='%s']" % (xccdf_ns, stig_ns))
            if ident_stig_id is not None:
                stigid = ident_stig_id.text
                xccdftostig_idmapping[stigid.strip("DISA FSO ")] = xccdfid
            else:
                ref_stig_id = rule.find("./{%s}reference[@href='%s']" % (xccdf_ns, stig_ns))
                if ref_stig_id is not None:
                    stigid = ref_stig_id.text
                    xccdftostig_idmapping[stigid] = xccdfid

    return xccdftostig_idmapping


def getkey(elem):
    return elem.get("ownerid")


def update_legacy_stig_overlay(ssgtree, overlayfile, legacyfile):
    new_overlay = []
    legacy_overlay = []

    for overlay in ssgtree.findall(".//overlay"):
        new_overlay.append(overlay.get("ownerid"))

    if not os.path.isfile(legacyfile):
        tree = ET.Element("overlays", xmlns=xccdf_ns)
        root = tree
    else:
        tree = ET.parse(legacyfile)
        legacy_overlay = []
        for overlay in tree.findall(".//{%s}overlay" % xccdf_ns):
            legacy_overlay.append(overlay.get("ownerid"))
        root = tree.getroot()

    original_overlay = ET.parse(overlayfile)
    for overlay in original_overlay.findall("//{%s}overlay" % xccdf_ns):
        ownerid = overlay.get("ownerid")
        if ownerid not in new_overlay and ownerid not in legacy_overlay:
            elements = copy.deepcopy(overlay)
            root.append(elements)

    lines = root.findall(".//{%s}overlay" % xccdf_ns)
    root[:] = sorted(lines, key=getkey)

    with open(legacyfile, 'w') as f:
        f.write(ET.tostring(tree, pretty_print=True, encoding="UTF-8",
                xml_declaration=True))

    print("\nUpdated Legacy STIG overlay file: %s" % legacyfile)


def new_stig_overlay(xccdftree, ssgtree, outfile, backup=False,
                     overlayfile=False, legacyfile=False):
    if not ssgtree:
        ssg_mapping = False
    else:
        ssg_mapping = ssg_xccdf_stigid_mapping(ssgtree)

    new_stig_overlay = ET.Element("overlays", xmlns=xccdf_ns)
    for group in xccdftree.findall("./{%s}Group" % xccdf_ns):
        vkey = group.get("id").strip('V-')
        for title in group.findall("./{%s}title" % xccdf_ns):
            srg = title.text
        for rule in group.findall("./{%s}Rule" % xccdf_ns):
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
                mapped_id = ssg_mapping[version]
            except KeyError as e:
                mapped_id = "XXXX"

        overlay = ET.SubElement(new_stig_overlay, "overlay", owner=owner,
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

    if backup:
        update_legacy_stig_overlay(tree, overlayfile, legacyfile)


def parse_options():
    usage = "usage: %prog [options]"
    parser = optparse.OptionParser(usage=usage, version="%prog ")
    # only some options are on by default
    parser.add_option("--ssg-xccdf", default=False,
                      action="store", dest="ssg_xccdf_filename",
                      help="A SSG generated XCCDF file. \
                            For example: ssg-rhel6-xccdf.xml")
    parser.add_option("--disa-xccdf", default=False,
                      action="store", dest="disa_xccdf_filename",
                      help="A DISA generated XCCDF Manual checks file. \
                            For example: disa-stig-rhel6-v1r12-xccdf-manual.xml")
    parser.add_option("--original-overlay", default=outfile,
                      action="store", dest="original",
                      help="A currently existing STIG overlay XML content file \
                           [default: %default]")
    parser.add_option("--legacy", default=legacyfile,
                      action="store", dest="legacy",
                      help="The Legacy STIG overlay XML content file \
                           [default: %default]")
    parser.add_option("-b", "--backup", default=False,
                      action="store_true", dest="backup",
                      help="Backup the STIG overlay XML file \
                           [default: %default]")
    parser.add_option("-o", "--output", default=outfile,
                      action="store", dest="output_file",
                      help="STIG overlay XML content file \
                           [default: %default]")
    (options, args) = parser.parse_args()

    if not options.disa_xccdf_filename:
        parser.print_help()
        sys.exit(1)

    return (options, args)


def main():
    (options, args) = parse_options()

    disa_xccdftree = ET.parse(options.disa_xccdf_filename)

    if not options.ssg_xccdf_filename:
        print("WARNING: You are generating a STIG overlay XML file without mapping it "
              "to existing SSG content.")
        prompt = yes_no_prompt()
        if not prompt:
            sys.exit(0)
        ssg_xccdftree = False
    else:
        ssg_xccdftree = ET.parse(options.ssg_xccdf_filename)
        ssg = ssg_xccdftree.find(".//{%s}publisher" % dc_ns).text
        if ssg != "SCAP Security Guide Project":
            sys.exit("%s is not a valid SSG generated XCCDF file." % ssg_xccdf_filename)

    disa = disa_xccdftree.find(".//{%s}source" % dc_ns).text
    if disa != "STIG.DOD.MIL":
        sys.exit("%s is not a valid DISA generated manual XCCDF file." % disa_xccdf_filename)
    if not options.backup:
        new_stig_overlay(disa_xccdftree, ssg_xccdftree, options.output_file)
    else:
        if not os.path.isfile(options.original):
            sys.exit("%s does not exist!" % options.original)
        new_stig_overlay(disa_xccdftree, ssg_xccdftree, options.output_file,
                         options.backup, options.original, options.legacy)


if __name__ == "__main__":
    main()
