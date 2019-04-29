
from __future__ import print_function

import sys
try:
    from urllib.parse import urlparse
except ImportError:
    from urlparse import urlparse

import ssg.constants
import ssg.xml
ocil_ns = ssg.constants.ocil_namespace

oval_ns = ssg.constants.oval_namespace
xccdf_ns = ssg.constants.XCCDF12_NS
ds_ns = ssg.constants.datastream_namespace
xlink_ns = ssg.constants.xlink_namespace
cat_ns = ssg.constants.cat_namespace

component_ref_prefix = "#scap_org.open-scap_cref_"


# Inspired by openscap ds_sds_mangle_filepath() function
def mangle_path(path):
    path = path.replace('/', '-')
    path = path.replace('@', '-')
    path = path.replace('~', '-')
    return path


def move_patches_up_to_date_to_source_data_stream_component(datastreamtree):
    ds_checklists = datastreamtree.find(".//{%s}checklists" % ds_ns)

    for component_ref in ds_checklists:
        component_ref_id = component_ref.get('id')
        component_ref_href = component_ref.get('{%s}href' % xlink_ns)
        # The component ID is the component-ref href without leading '#'
        component_id = component_ref_href[1:]

        # Locate the <xccdf:check> element of an <xccdf:Rule> with id security_patches_up_to_date
        checklist_component = None
        oval_check = None
        ds_components = datastreamtree.findall(".//{%s}component" % ds_ns)
        for ds_component in ds_components:
            if ds_component.get('id') == component_id:
                checklist_component = ds_component
        if checklist_component is None:
            # Something strange happened
            sys.stderr.write("Couldn't find <component> %s referenced by <component-ref> %s" %
                             (component_id, component_ref_id))
            sys.exit(1)

        rules = checklist_component.findall(".//{%s}Rule" % (xccdf_ns))
        for rule in rules:
            if rule.get('id').endswith('rule_security_patches_up_to_date'):
                rule_checks = rule.findall("{%s}check" % xccdf_ns)
                for check in rule_checks:
                    if check.get('system') == oval_ns:
                        oval_check = check
                        break

        if oval_check is None:
            # The component doesn't have a security patches up to date rule with an OVAL check
            continue

        # SCAP 1.3 demands multi-check true if the Rules security_patches_up_to_date is
        # evaluated by multiple OVAL patch class definitinos.
        # See 3.2.4.3, SCAP 1.3 standard (NIST.SP.800-126r3)
        oval_check.set('multi-check', 'true')

        check_content_ref = oval_check.find('{%s}check-content-ref' % xccdf_ns)
        href_url = check_content_ref.get('href')

        # Use URL's path to define the component name and URI
        # Path attribute returned from urlparse contains a leading '/', when mangling it
        # it will get replaced by '-'.
        # Let's strip the '/' to avoid a sequence of "_-" in the component-ref ID.
        component_ref_name = mangle_path(urlparse(href_url).path[1:])
        component_ref_uri = component_ref_prefix + component_ref_name

        # update @href to refer the datastream component name
        check_content_ref.set('href', component_ref_name)

        # Add a uri refering the component in Rule's Benchmark component-ref catalog
        uri_exists = False
        catalog = checklist_component_ref.find('{%s}catalog' % cat_ns)
        uris = catalog.findall("{%s}uri" % (cat_ns))
        for uri in uris:
            if uri.get('name') == component_ref_name:
                uri_exists = True
                break
        if not uri_exists:
            uri = ssg.xml.ElementTree.Element('{%s}uri' % cat_ns)
            uri.set('name', component_ref_name)
            uri.set('uri', component_ref_uri)
            catalog.append(uri)

        # The component-ref ID is the catalog uri without leading '#'
        component_ref_feed_id = component_ref_uri[1:]

        # Add the component-ref to list of datastreams' checks
        check_component_ref_exists = False
        ds_checks = datastreamtree.find(".//{%s}checks" % ds_ns)
        check_component_refs = ds_checks.findall("{%s}component-ref" % ds_ns)
        for check_component_ref in check_component_refs:
            if check_component_ref.get('id') == component_ref_feed_id:
                check_component_ref_exists = True
                break
        if not check_component_ref_exists:
            component_ref_feed = ssg.xml.ElementTree.Element('{%s}component-ref' %
                                                             ds_ns)
            component_ref_feed.set('id', component_ref_feed_id)
            component_ref_feed.set('{%s}href' % xlink_ns, href_url)
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
    datastreamtree.find('{%s}data-stream' % ds_ns).set('scap-version', '1.3')

    # Move reference to remote OVAL content to a source data stream component
    move_patches_up_to_date_to_source_data_stream_component(datastreamtree)

    ssg.xml.ElementTree.ElementTree(datastreamtree).write(outdatastreamfile)

if __name__ == "__main__":
    main()
