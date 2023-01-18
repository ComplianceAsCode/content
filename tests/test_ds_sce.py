import argparse
import os.path
import sys

from ssg.build_sce import collect_sce_checks
from ssg.constants import (
    cat_namespace, datastream_namespace, sce_namespace, xlink_namespace
)
import ssg.xml


def verify_file(ds, catalog_uris, file, build_dir):
    component_ref = ds.find(str.format(
        ".//{{{ds_ns}}}checklists/{{{ds_ns}}}component-ref[@id='{cid}']",
        ds_ns=datastream_namespace,
        cid=catalog_uris[file]
    ))
    if component_ref is None:
        print("Missing component reference with id '%s'" % catalog_uris[file])
        sys.exit(1)

    # drop the '#' prefix
    extended_component_id = component_ref.get('{%s}href' % xlink_namespace)[1:]
    extended_component = ds.find(str.format(
        "./{{{ds_ns}}}extended-component[@id='{cid}']",
        ds_ns=datastream_namespace,
        cid=extended_component_id
    ))
    if extended_component is None:
        print("Missing extended-component with id '%s'" % extended_component_id)
        sys.exit(1)

    script_content = extended_component.find('{%s}script' % sce_namespace)
    if script_content is None:
        print("Missing script content for extended-component '%s'" % extended_component_id)
        sys.exit(1)

    with open(os.path.join(build_dir, file), 'rt') as reference_fd:
        reference_content = reference_fd.read()

    if script_content.text != reference_content:
        print("Invalid content for the extended_component '%s'" % extended_component_id)
        sys.exit(1)


# Walk the datastream tree to find if every element of the chain from the Rules to the SCE script
# content are present.
def verify_component_refs(ds, check_files, build_dir):
    catalog_uris = {}
    catalog_uri_xpath = str.format(".//{{{cat_ns}}}catalog/{{{cat_ns}}}uri", cat_ns=cat_namespace)
    for uri in ds.findall(catalog_uri_xpath):
        # drop the '#' prefix
        catalog_uris[uri.get('name')] = uri.get('uri')[1:]

    for file in check_files:
        if file not in catalog_uris.keys():
            print("Missing catalog entry for '%s'" % file)
            sys.exit(1)

        verify_file(ds, catalog_uris, file, build_dir)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Checks a SCE test exists and was properly written in the datastream."
    )
    parser.add_argument(
        "build_dir", help="Path to the build directory")
    parser.add_argument(
        "datastream_path", help="Path to a SCAP source datastream")
    args = parser.parse_args()
    root = ssg.xml.parse_file(args.datastream_path)

    sce_checks = collect_sce_checks(root)
    if len(sce_checks) == 0:
        print("Could not find SCE checks in the datastream")
        sys.exit(1)
    verify_component_refs(root, sce_checks, args.build_dir)
    print("The SCE content is OK")
