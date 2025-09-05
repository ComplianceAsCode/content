
from __future__ import print_function

import argparse
import sys
try:
    from urllib.parse import urlparse
except ImportError:
    from urlparse import urlparse

import ssg.xml
from ssg.constants import (oval_namespace, XCCDF12_NS, cat_namespace,
                           datastream_namespace, xlink_namespace)


component_ref_prefix = "#scap_org.open-scap_cref_"


# Inspired by openscap ds_sds_mangle_filepath() function
def mangle_path(path):
    path = path.replace('/', '-')
    path = path.replace('@', '-')
    path = path.replace('~', '-')
    return path


def move_patches_up_to_date_to_source_data_stream_component(datastreamtree):
    ds_checklists = datastreamtree.find(".//{%s}checklists" % datastream_namespace)

    for checklists_component_ref in ds_checklists:
        checklists_component_ref_id = checklists_component_ref.get('id')
        # The component ID is the component-ref href without leading '#'
        checklists_component_id = checklists_component_ref.get('{%s}href' % xlink_namespace)[1:]

        # Locate the <xccdf:check> element of an <xccdf:Rule> with id security_patches_up_to_date
        checklist_component = None
        oval_check = None
        ds_components = datastreamtree.findall(".//{%s}component" % datastream_namespace)
        for ds_component in ds_components:
            if ds_component.get('id') == checklists_component_id:
                checklist_component = ds_component
        if checklist_component is None:
            # Something strange happened
            sys.stderr.write("Couldn't find <component> %s referenced by <component-ref> %s" %
                             (checklists_component_id, checklists_component_ref_id))
            sys.exit(1)

        rules = checklist_component.findall(".//{%s}Rule" % XCCDF12_NS)
        for rule in rules:
            if rule.get('id').endswith('rule_security_patches_up_to_date'):
                rule_checks = rule.findall("{%s}check" % XCCDF12_NS)
                for check in rule_checks:
                    if check.get('system') == oval_namespace:
                        oval_check = check
                        break

        if oval_check is None:
            # The component doesn't have a security patches up to date rule with an OVAL check
            continue

        # SCAP 1.3 demands multi-check true if the Rules security_patches_up_to_date is
        # evaluated by multiple OVAL patch class definitinos.
        # See 3.2.4.3, SCAP 1.3 standard (NIST.SP.800-126r3)
        oval_check.set('multi-check', 'true')

        check_content_ref = oval_check.find('{%s}check-content-ref' % XCCDF12_NS)
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
        catalog = checklists_component_ref.find('{%s}catalog' % cat_namespace)
        uris = catalog.findall("{%s}uri" % cat_namespace)
        for uri in uris:
            if uri.get('name') == component_ref_name:
                uri_exists = True
                break
        if not uri_exists:
            uri = ssg.xml.ElementTree.Element('{%s}uri' % cat_namespace)
            uri.set('name', component_ref_name)
            uri.set('uri', component_ref_uri)
            catalog.append(uri)

        # The component-ref ID is the catalog uri without leading '#'
        component_ref_feed_id = component_ref_uri[1:]

        # Add the component-ref to list of datastreams' checks
        check_component_ref_exists = False
        ds_checks = datastreamtree.find(".//{%s}checks" % datastream_namespace)
        check_component_refs = ds_checks.findall("{%s}component-ref" % datastream_namespace)
        for check_component_ref in check_component_refs:
            if check_component_ref.get('id') == component_ref_feed_id:
                check_component_ref_exists = True
                break
        if not check_component_ref_exists:
            component_ref_feed = ssg.xml.ElementTree.Element('{%s}component-ref' %
                                                             datastream_namespace)
            component_ref_feed.set('id', component_ref_feed_id)
            component_ref_feed.set('{%s}href' % xlink_namespace, href_url)
            ds_checks.append(component_ref_feed)

def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("--version", required=True)
    p.add_argument("--input", required=True)
    p.add_argument("--output", required=True)

    return p.parse_args()

def main():
    args = parse_args()

    # Datastream element tree
    datastreamtree = ssg.xml.parse_file(args.input)

    if args.version == "1.3":
        # Set SCAP version to 1.3
        datastreamtree.set('schematron-version', '1.3')
        datastreamtree.find('{%s}data-stream' % datastream_namespace).set('scap-version', '1.3')

        # Move reference to remote OVAL content to a source data stream component
        move_patches_up_to_date_to_source_data_stream_component(datastreamtree)

    ssg.xml.ElementTree.ElementTree(datastreamtree).write(args.output)


if __name__ == "__main__":
    main()
