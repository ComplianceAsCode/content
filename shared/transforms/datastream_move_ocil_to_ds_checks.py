#!/usr/bin/python2

# OpenSCAP as of version 1.2.8 doesn't support OCIL check system yet. For
# example attempt to build RHEL/6 SSG benchmark produces the following error:
#
# scap-security-guide/RHEL/6 ] make content
# ..
# OpenSCAP Error: Unknown document type: 'ocil-ssg.xml' [oscap_source.c:172]
#
# As a result of this, when building datastream OCIL component is put into
# <ds:extended-components> element rather than into <ds:checks> element. See [1]
# for further details
#
# [1] https://github.com/OpenSCAP/openscap/issues/364
#
# But [2] http://csrc.nist.gov/publications/nistpubs/800-126-rev2/SP800-126r2.pdf
# (page "Table 6 - ds-checks [Page #22]" and section "3.2.4.2" suggests OCIL
# check system should be placed into <ds:checks> element when building a datastream
#
# The current oscap behaviour leads to:
# * [3] https://github.com/OpenSCAP/scap-security-guide/issues/1101 and
# * [4] https://github.com/OpenSCAP/scap-security-guide/issues/1100
# issues when validating the produced datastream using the NIST SCAP content
# test suite
#
# Therefore this script is performing the following:
# * moving the OCIL check system datastream component from <ds:extended-components>
#   element to <ds:checks> element (as required by SCAP v1.2 standard [2]),
# * and renaming the tag name for OCIL component from '<ds:extended-component>' to
#   '<ds:component>'
#
# This is a temporary workaround for bug [1], fixing the issues [3] and [4].
#
# Example run:
#   $ ./datastream_move_ocil_to_ds_checks.py ssg-rhel6-ds.xml new-ds.xml

import os
import sys
import lxml.etree as ET

xlink_ns = "http://www.w3.org/1999/xlink"
datastream_ns = "http://scap.nist.gov/schema/scap/source/1.2"

def parse_xml_file(xmlfile):
    with open(xmlfile, 'r') as xml_file:
        filestring = xml_file.read()
        tree = ET.fromstring(filestring)
    return tree


def move_ocil_from_ds_extended_components_to_ds_checks(datastreamtree, ocilcomp):

    # Locate <ds:checks> element
    dschecks = datastreamtree.find(".//{%s}checks" % datastream_ns)
    # Express <xlink:href> tag in namespace + tag form
    hreftag = '{' + xlink_ns + '}' + 'href'
    if dschecks is not None:
        # Sanity check if OCIL component has '<xlink:href>' attribute
        if hreftag in ocilcomp.attrib:
            # Save old <xlink:href> attribute value of the OCIL component
            oldocilhref = ocilcomp.attrib[hreftag]
            # Replace 'ecomp' with 'comp' in <xlink:href> attribute
            # Turns e.g. 'scap_org.open-scap_ecomp_ocil-ssg.xml' into 'scap_org.open-scap_comp_ocil-ssg.xml'
            ocilcomp.attrib[hreftag] = oldocilhref.replace('ecomp', 'comp')
            # Insert the updated OCIL component past the last child in current <ds:checks> element
            dschecks.insert(len(dschecks)+1, ocilcomp)
            # Locate <ds:extended-components> element in datastream
            extendedcomps = datastreamtree.find(".//{%s}extended-components" % datastream_ns)
            # Remove the <ds:extended-components> element from the datastream if it's empty
            if extendedcomps is not None and len(extendedcomps) == 0:
                extendedcomps.getparent().remove(extendedcomps)
                # Return '<xlink:href>' value for later reuse
                return oldocilhref

    # Default return value
    return None


def replace_ds_extended_component_tag_with_ds_component_tag_for_ocil(datastreamtree, ocilxlinkhref):

    # Drop the leading '#' character from <xlink:href> to get OCIL component ID
    ocilid = ocilxlinkhref[1:]
    # Locate the <ds:extended-component> having @id set to OCIL component ID
    ocilcomp = datastreamtree.find(".//{%s}extended-component[@id=\"%s\"]" % (datastream_ns, ocilid))
    # We succeeded trying to locate
    if ocilcomp is not None:
        # Sanity check if OCIL component has 'id' attribute
        if 'id' in ocilcomp.attrib:
            # Replace 'ecomp' with 'comp' in OCIL component ID
            # Turns e.g. 'scap_org.open-scap_ecomp_ocil-ssg.xml' into 'scap_org.open-scap_comp_ocil-ssg.xml'
            ocilcomp.attrib['id'] = ocilid.replace('ecomp', 'comp')
            # Express <ds:extended-component> tag in namespace + tag form
            extcomptag = '{%s}extended-component' % datastream_ns
            # Ensure we operate on '<ds:extended-component>' element
            if ocilcomp.tag == extcomptag:
                # Reset OCIL component tag from '<ds:extended-component>' to '<ds:component>'
                ocilcomp.tag = '{%s}component' % datastream_ns


def main():

    if len(sys.argv) < 3:
        print("Provide input and output SCAP Security Guide source datastream files.")
        print("This script moves <ocil:ocil> datastream component from " +
              "<ds:extended-components> to <ds:checks>.")
        sys.exit(1)

    # Input datastream file
    indatastreamfile = sys.argv[1]
    # Output datastream file
    outdatastreamfile = sys.argv[2]
    # Datastream element tree
    datastreamtree = parse_xml_file(indatastreamfile)

    # Locate <ds:extended-components> element in datastream
    extendedcomps = datastreamtree.find(".//{%s}extended-components" % datastream_ns)
    if extendedcomps is not None:
        # Locate OCIL component within <ds:extended-components>
        ocilcomps = extendedcomps.xpath(".//ds:component-ref[contains(@id,'_ocil')]",
                                        namespaces={"ds" : datastream_ns})
        # SSG produces datastream with exactly one OCIL component
        if len(ocilcomps) != 1:
            print("Expecting exactly one OCIL component in datastream.")
            sys.exit(1)
        else:
            comp = ocilcomps[0]
            # Move found OCIL component from <ds:extended-components> to <ds:checks>
            # Obtain old value of <xlink:href> atrribute value of the OCIL component
            oldocilhref = move_ocil_from_ds_extended_components_to_ds_checks(datastreamtree, comp)
            if oldocilhref is not None:
                # Rename <ds:extended-component> tag to <ds:component> tag for OCIL component
                # Also update the ID replacing 'ecomp' with 'comp'
                replace_ds_extended_component_tag_with_ds_component_tag_for_ocil(datastreamtree, oldocilhref)
            else:
                print("Error trying to move OCIL component in datastream. Exiting")
                sys.exit(1)

        # Write the updated benchmark into output datastream file
        ET.ElementTree(datastreamtree).write(outdatastreamfile)
        sys.exit(0)


if __name__ == "__main__":
    main()
