#!/usr/bin/env python2

import re
import sys
import optparse
import os
import lxml.etree as ET


owner = "disastig"
stig_ns = ["http://iase.disa.mil/stigs/os/unix-linux/Pages/index.aspx",
           "http://iase.disa.mil/stigs/os/general/Pages/index.aspx",
           "http://iase.disa.mil/stigs/app-security/app-servers/Pages/index.aspx"]
xccdf_ns = "http://checklists.nist.gov/xccdf/1.1"
dc_ns = "http://purl.org/dc/elements/1.1/"
outfile = "stig_overlay.xml"


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
        srgs = []
        rhid = ""

        xccdfid = rule.get("id")
        if xccdfid is not None:
            for references in stig_ns:
                stig = [ids for ids in rule.findall(".//{%s}reference[@href='%s']" % (xccdf_ns, references))]
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
                mapped_id = ''.join(ssg_mapping[version].keys())
            except KeyError as e:
                mapped_id = get_nested_stig_items(ssg_mapping, srg)

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

    new_stig_overlay(disa_xccdftree, ssg_xccdftree, options.output_file)


if __name__ == "__main__":
    main()
