#!/usr/bin/python3

from __future__ import print_function

import sys
import argparse
import os
import ssg
import ssg.xml
import xml.dom.minidom

from ssg.constants import XCCDF11_NS, XCCDF12_NS, OSCAP_RULE

ET = ssg.xml.ElementTree


owner = "disastig"
stig_ns = ["https://public.cyber.mil/stigs/downloads/?_dl_facet_stigs=operating-systems%2Cunix-linux",
           "https://public.cyber.mil/stigs/downloads/?_dl_facet_stigs=operating-systems%2Cgeneral-purpose-os",
           "https://public.cyber.mil/stigs/downloads/?_dl_facet_stigs=app-security%2Capplication-servers",
           "https://public.cyber.mil/stigs/downloads/?_dl_facet_stigs=app-security%2Capp-security-dev"]
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
    for elem in element_obj.findall("./{%s}%s" % (XCCDF11_NS, element)):
        elem = elem.text
    try:
        return elem
    except UnboundLocalError as e:
        return ""


def ssg_xccdf_stigid_mapping(ssgtree):
    xccdf_ns = ssg.xml.determine_xccdf_tree_namespace(ssgtree)
    xccdftostig_idmapping = {}

    for rule in ssgtree.findall(".//{%s}Rule" % xccdf_ns):
        srgs = []
        rhid = ""

        xccdfid = rule.get("id")
        if xccdf_ns == XCCDF12_NS:
            xccdfid = xccdfid.replace(OSCAP_RULE, "")
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


def getkey(elem):
    return elem.get("ownerid")


def new_stig_overlay(xccdftree, ssgtree, outfile, quiet):
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
            svkey = svkey_raw.strip()[3:9]
            severity = rule.get("severity")
            release = svkey_raw.strip()[10:-5]
            version = element_value("version", rule)
            rule_title = element_value("title", rule)
            ident = element_value("ident", rule).strip("CCI-").lstrip("0")

        if not ssgtree:
            mapped_id = "XXXX"
        else:
            try:
                mapped_id = ''.join(ssg_mapping[version].keys())
            except KeyError as e:
                mapped_id = "XXXX"

        overlay = ET.SubElement(new_stig_overlay, "overlay", owner=owner,
                                ruleid=mapped_id, ownerid=version, disa=ident,
                                severity=severity)
        vmsinfo = ET.SubElement(overlay, "VMSinfo", VKey=vkey,
                                SVKey=svkey, VRelease=release)
        title = ET.SubElement(overlay, "title", text=rule_title)

    lines = new_stig_overlay.findall("overlay")
    new_stig_overlay[:] = sorted(lines, key=getkey)

    try:
        et_str = ET.tostring(new_stig_overlay, encoding="UTF-8", xml_declaration=True)
    except TypeError:
        et_str = ET.tostring(new_stig_overlay, encoding="UTF-8")

    dom = xml.dom.minidom.parseString(et_str)
    pretty_xml_as_string = dom.toprettyxml(indent='  ', encoding="UTF-8")

    overlay_directory = os.path.dirname(outfile)
    if not os.path.exists(overlay_directory):
        os.makedirs(overlay_directory)
        if not quiet:
            print("\nOverlay directory created: %s" % overlay_directory)

    with open(outfile, 'wb') as f:
        f.write(pretty_xml_as_string)

    if not quiet:
        print("\nGenerated the new STIG overlay file: %s" % outfile)


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--disa-xccdf", default=False, required=True,
                        action="store", dest="disa_xccdf_filename",
                        help="A DISA generated XCCDF Manual checks file. \
                              For example: disa-stig-rhel8-v1r12-xccdf-manual.xml")
    parser.add_argument("--ssg-xccdf", default=None,
                        action="store", dest="ssg_xccdf_filename",
                        help="A SSG generated XCCDF file. Can be XCCDF 1.1 or XCCDF 1.2 \
                              For example: ssg-rhel8-xccdf.xml")
    parser.add_argument("-o", "--output", default=outfile,
                        action="store", dest="output_file",
                        help="STIG overlay XML content file \
                            [default: %s]" % outfile)
    parser.add_argument("-q", "--quiet", dest="quiet", default=False,
                      action="store_true", help="Do not print anything and assume yes for everything")

    return parser.parse_args()


def main():
    args = parse_args()

    disa_xccdftree = ET.parse(args.disa_xccdf_filename)

    if not args.ssg_xccdf_filename:
        prompt = True
        if not args.quiet:
            print("WARNING: You are generating a STIG overlay XML file without mapping it "
                "to existing SSG content.")
            prompt = yes_no_prompt()
        if not prompt:
            sys.exit(0)
        ssg_xccdftree = False
    else:
        ssg_xccdftree = ET.parse(args.ssg_xccdf_filename)
        ssg = ssg_xccdftree.find(".//{%s}publisher" % dc_ns).text
        if ssg != "SCAP Security Guide Project":
            if not args.quiet:
                sys.exit("%s is not a valid SSG generated XCCDF file." % args.ssg_xccdf_filename)
            else:
                sys.exit(1)

    disa = disa_xccdftree.find(".//{%s}source" % dc_ns).text
    if disa != "STIG.DOD.MIL":
        if not args.quiet:
            sys.exit("%s is not a valid DISA generated manual XCCDF file." % args.disa_xccdf_filename)
        else:
            sys.exit(2)

    new_stig_overlay(disa_xccdftree, ssg_xccdftree, args.output_file, args.quiet)


if __name__ == "__main__":
    main()
