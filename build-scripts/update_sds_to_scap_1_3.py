
from __future__ import print_function

import sys
from urllib.parse import urlparse

import ssg.constants
import ssg.xml
ocil_ns = ssg.constants.ocil_namespace

oval_ns = ssg.constants.oval_namespace
xccdf_ns = ssg.constants.XCCDF12_NS
ds_ns = ssg.constants.datastream_namespace
xlink_ns = ssg.constants.xlink_namespace
cat_ns = ssg.constants.cat_namespace
ns = {'oval': oval_ns,
      'xccdf': xccdf_ns,
      'ds': ds_ns,
      'xlink': xlink_ns,
      'cat': cat_ns}

component_ref_prefix = "#scap_org.open-scap_cref_"

# Inspired by openscap ds_sds_mangle_filepath() function
def mangle_path(path):
    path = path.replace('/', '-')
    path = path.replace('@', '-')
    return path

def move_patches_up_to_date_to_source_data_stream_component(datastreamtree):
    ds_checklists = datastreamtree.find(".//ds:checklists", ns)

    for component_ref in ds_checklists:
        component_id = component_ref.get('{%s}href' % xlink_ns)
        component_id = component_id[1:]

        # Locate the <xccdf:check> of the <xccdf:Rule> with id security_patches_up_to_date
        oval_check = datastreamtree.find(".//ds:component[@id='%s']//xccdf:Rule[@id='xccdf_org.ssgproject.content_rule_security_patches_up_to_date']/xccdf:check[@system='%s']" % (component_id, oval_ns), ns )
        # SCAP 1.3 demands multi-check true if the Rules security_patches_up_to_date is
        # evaluated by multiple OVAL patch class definitinos.
        # See 3.2.4.3, SCAP 1.3 standard (NIST.SP.800-126r3)
        if oval_check is None:
            continue
        oval_check.set('multi-check', 'true')

        check_content_ref = oval_check.find('xccdf:check-content-ref', ns)
        href_url = check_content_ref.get('href')

        # Use URL's path to define the component name and URI
        component_ref_name = mangle_path(urlparse(href_url).path[1:])
        component_ref_uri = component_ref_prefix + component_ref_name

        # update @href to refer the datastream component name
        check_content_ref.set('href', component_ref_name)

        # Add a uri refering the component in Rule's Benchmark component-ref catalog
        catalog = component_ref.find('cat:catalog', ns)
        uris = catalog.findall("cat:uri[@name='%s']" % component_ref_name, ns)
        if not uris:
            uri = ssg.xml.ElementTree.Element('{%s}uri' % cat_ns,
                                    attrib = {
                                        'name' : component_ref_name,
                                        'uri' : component_ref_uri })
            catalog.append(uri)

        # Add the component-ref to list of datastreams' checks
        ds_checks = datastreamtree.find(".//ds:checks", ns)
        check_component_ref = ds_checks.findall("ds:component-ref[@id='%s']" % component_ref_uri[1:], ns)
        if not check_component_ref:
            component_ref_feed = ssg.xml.ElementTree.Element('{%s}component-ref' % ds_ns,
                                    attrib = {
                                        'id' : component_ref_uri[1:],
                                        '{%s}href' % xlink_ns : href_url })
            ds_checks.append(component_ref_feed)


def main():
    if len(sys.argv) < 3:
        print("This script updates SCAP 1.2 Source DataStream to SCAP 1.3")
        sys.exit(1)

    # Input datastream file
    indatastreamfile = sys.argv[1]
    # Output datastream file
    outdatastreamfile = sys.argv[2]
    # Datastream element tree
    datastreamtree = ssg.xml.ElementTree.parse(indatastreamfile).getroot()

    # Set SCAP version to 1.3
    datastreamtree.set('schematron-version', '1.3')
    datastreamtree.find('ds:data-stream', ns).set('scap-version', '1.3')

    # Move reference to remote OVAL content to a source data stream component
    move_patches_up_to_date_to_source_data_stream_component(datastreamtree)

    ssg.xml.ElementTree.ElementTree(datastreamtree).write(outdatastreamfile)

if __name__ == "__main__":
    main()
