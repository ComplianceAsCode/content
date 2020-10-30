#!/usr/bin/env python2

# OpenSCAP as of version 1.2.8 doesn't support OCIL check system yet. For
# example attempt to build rhel7 SSG benchmark produces the following error:
#
# scap-security-guide/rhel7 ] make content
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
# * moving the refence of found OCIL component from <ds:extended-components>
#   datastream element to <ds:checks> datastream element (and removing the
#   original <ds:extended-components> element)
# * also moving content of the found OCIL component from <ds:extended-component>
#   datastream element to <ds:component> datastream element (and removing the
#   original <ds:extended-component> element)
#
# This is a temporary workaround for bug [1], fixing the issues [3] and [4].
#
# Example run:
#   $ ./sds_move_ocil_to_checks.py ssg-rhel7-ds.xml new-ds.xml

from __future__ import print_function

import sys
import os

import ssg.constants
import ssg.xml

xlink_ns = "http://www.w3.org/1999/xlink"
datastream_ns = ssg.constants.datastream_namespace
ocil_ns = ssg.constants.ocil_namespace


def move_ocil_ref_from_ds_extended_components_to_ds_checks(datastreamtree, ocilcomp):
    # This routine moves reference to present OCIL component from <ds:extended-components>
    # datastream element to <ds:checks> element (as required by SCAP v1.2 standard)

    # Locate <ds:checks> element
    dschecks = datastreamtree.find(".//{%s}checks" % datastream_ns)
    if dschecks is None:
        sys.stderr.write("Couldn't find the checks element.\n")
        return None

    # Express <xlink:href> tag in namespace + tag form
    hreftag = '{' + xlink_ns + '}' + 'href'

    # Sanity check if OCIL component has 'xlink:href' attribute
    if hreftag not in ocilcomp.attrib:
        sys.stderr.write("Couldn't find the hreftag attribute in the "
                         "OCIL reference.\n")
        return None

    # Save old <xlink:href> attribute value of the OCIL component
    oldocilhref = ocilcomp.attrib[hreftag]
    # Replace 'ecomp' with 'comp' in <xlink:href> attribute
    # Turns e.g. 'scap_org.open-scap_ecomp_ocil-ssg.xml' into 'scap_org.open-scap_comp_ocil-ssg.xml'
    ocilcomp.attrib[hreftag] = oldocilhref.replace('ecomp', 'comp')
    # Insert the reference to OCIL component past the last child in current <ds:checks> element
    dschecks.insert(len(dschecks)+1, ocilcomp)

    # Locate <ds:extended-components> element in datastream
    extendedcomps = datastreamtree.find(".//{%s}extended-components" % datastream_ns)
    # Remove the <ds:extended-components> element from the datastream if it's empty
    if extendedcomps is not None and len(extendedcomps) == 0:
        extendedcomps.getparent().remove(extendedcomps)
    # Return '<xlink:href>' value for later reuse
    return oldocilhref


def move_ocil_content_from_ds_extended_component_to_ds_component(datastreamtree, ocilxlinkhref):
    # This routine moves content of OCIL element from <ds:extended-component>
    # datastream element to <ds:component> element (as required by SCAP v1.2 standard)

    # Drop the leading '#' character from <xlink:href> to get OCIL component ID
    ocilextcompid = ocilxlinkhref[1:]
    # Locate the <ds:extended-component> having @id set to OCIL component ID
    extendedcomp = datastreamtree.find(".//{%s}extended-component[@id=\"%s\"]" % (datastream_ns, ocilextcompid))
    # Replace 'ecomp' for 'comp' to be used in new <ds:component> ID
    ocildscompid = ocilextcompid.replace('ecomp', 'comp')

    # Verify <ds:extended-component> contains 'timestamp' attribute
    if 'timestamp' not in extendedcomp.attrib:
        sys.stderr.write("Unable to obtain 'timestamp' attribute value from "
                         "<ds:extended-component>. Exiting.\n")
        sys.exit(1)

    # Save the 'timestamp' attribute value
    timestamp = extendedcomp.get('timestamp')

    # Get children elements of <ds:extended-component> containing OCIL content
    extchildren = list(extendedcomp)
    # There should be just one OCIL subcomponent in <ds:extended-component>
    if len(extchildren) != 1:
        sys.stderr.write("ds:extended-component contains more than one element!"
                         "Expected exactly one, found %i instead!\n" %
                         (len(extchildren)))
        sys.exit(1)

    # Decode possible HTML entities present in OCIL component
    extnohtmlents = ssg.xml.ElementTree.tostring(extendedcomp, method='html')
    # Create new element tree from decoded HTML
    extcomptree = ssg.xml.ElementTree.fromstring(extnohtmlents)
    # Locate the OCIL subcomponent within that element tree
    ocilcomp = extcomptree.find(".//{%s}ocil" % ocil_ns)

    # Now we have got everything:
    # * future OCIL <ds:component> ID        --> ocildscompid
    # * future OCIL <ds:component> timestamp --> timestamp
    # * future OCIL <ds:component> content   --> ocilcomp
    # to be ables to create new <ds:component> for OCIL content
    ocildscomp = ssg.xml.ElementTree.Element('{' + datastream_ns + '}component',
                            attrib = { 'id' : ocildscompid, 'timestamp' : timestamp },
                            nsmap = {'ds' : datastream_ns})
    # Insert the OCIL content into newly created <ds:component>
    ocildscomp.insert(len(ocildscomp)+1, ocilcomp)

    # Next insert that newly created OCIL <ds:component> into the datastream, thus
    # Get previous sibling of <ds:extended-component> (IOW last <ds:component> in benchmark)
    lastexistingdscomp = extendedcomp.getprevious()
    if lastexistingdscomp is None:
        sys.stderr.write("Couldn't find any existing component to add the OCIL "
                         "component next to.")
        sys.exit(1)

    # Append newly created OCIL <ds:component> as following sibling directly
    # after last existing <ds:component> element
    lastexistingdscomp.addnext(ocildscomp)
    # Sanity check if the appending succeeded
    if ocildscomp.getprevious() != lastexistingdscomp:
        print("Error trying to append new OCIL <ds:component> directly after "
              "last <ds:component> element.")
        sys.exit(1)

    # Finally remove the original <ds:extended-component> OCIL element (since
    # OCIL content has now been placed into new <ds:component> element)
    extendedcomp.getparent().remove(extendedcomp)


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
    datastreamtree = ssg.xml.open_xml(indatastreamfile)

    # Locate <ds:extended-components> element in datastream
    extendedcomps = datastreamtree.getroot().find("./{%s}extended-components" % datastream_ns)
    if extendedcomps is not None:
        # Locate OCIL components within <ds:extended-components>
        ocilcomps = extendedcomps.xpath(".//ds:component-ref[contains(@id,'-ocil')]",
                                        namespaces={"ds" : datastream_ns})
        if len(ocilcomps) == 0:
            print("Found extended-components but couldn't find any OCIL "
                  "components inside")

        for comp in ocilcomps:
            # Move reference of found OCIL component from <ds:extended-components> to <ds:checks> element
            # Return old value of <xlink:href> atrribute value of the OCIL component
            oldocilhref = move_ocil_ref_from_ds_extended_components_to_ds_checks(datastreamtree, comp)
            if oldocilhref is None:
                sys.stderr.write("Error trying to move OCIL component in "
                                 "datastream. Exiting\n")
                sys.exit(1)

            # Move OCIL component content from <ds:extended-component> to <ds:component>
            # Also update the ID replacing 'ecomp' with 'comp'
            move_ocil_content_from_ds_extended_component_to_ds_component(datastreamtree, oldocilhref)

    # if the in and out files are the same and we didn't do any changes we can
    # skip the serialization
    if extendedcomps is not None or outdatastreamfile != indatastreamfile:
        # Write the updated benchmark into output datastream file
        ssg.xml.ElementTree.ElementTree(datastreamtree).write(outdatastreamfile)
    sys.exit(0)


if __name__ == "__main__":
    main()
