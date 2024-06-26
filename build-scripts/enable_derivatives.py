#!/usr/bin/python3

from __future__ import print_function

"""
Takes given XCCDF or data stream and adds RHEL derivative operating system(s) CPE name next
to RHEL CPE names. Can automatically recognize RHEL CPEs and adds the derivitive OS ones
next to those accordingly.

Apart from adding the CPEs it adds a notice informing the user that the content
has been enabled for the derivative operating systems and what are the implications.

Author: Martin Preisler <mpreisle@redhat.com>
"""

import sys
from optparse import OptionParser

import ssg.build_derivatives
import ssg.constants
import ssg.xccdf
import ssg.xml

XCCDF12_NS = ssg.constants.XCCDF12_NS
oval_ns = ssg.constants.oval_namespace

CENTOS_NOTICE_ELEMENT = ssg.xml.ElementTree.fromstring(ssg.constants.CENTOS_NOTICE)

CENTOS_WARNING = 'centos_warning'


def parse_args():
    usage = "usage: %prog [options]"
    parser = OptionParser(usage=usage)
    parser.add_option("--enable-centos", dest="centos", default=False,
                      action="store_true", help="Enable CentOS")
    parser.add_option("-i", "--input", dest="input_content", default=False,
                      action="store",
                      help="INPUT can be XCCDF or Source data stream")
    parser.add_option("-o", "--output", dest="output", default=False,
                      action="store", help="XML Tree content")
    parser.add_option("--id-name", dest="id_name", default="ssg",
                      action="store", help="ID naming scheme")
    parser.add_option(
        "--cpe-items-dir",
        dest="cpe_items_dir", help="path to the directory where compiled cpe items are stored")
    parser.add_option(
        "--unlinked-cpe-oval-path",
        dest="unlinked_oval_file_path",
        help="path to the unlinked cpe oval"
    )

    (options, args) = parser.parse_args()


    if not options.output and not options.input_content:
        parser.print_help()
        sys.exit(1)
    return options, args


def store_xml(tree, path):
    if hasattr(ssg.xml.ElementTree, "indent"):
        ssg.xml.ElementTree.indent(tree, space="  ", level=0)
    tree.write(path, encoding="utf-8", xml_declaration=True)


def main():
    options, args = parse_args()

    if options.centos:
        mapping = ssg.constants.RHEL_CENTOS_CPE_MAPPING
        notice = CENTOS_NOTICE_ELEMENT
        warning = CENTOS_WARNING
        derivative = "CentOS"

    tree = ssg.xml.open_xml(options.input_content)
    root = tree.getroot()

    benchmarks = []

    ssg.xccdf.scrape_benchmarks(root, XCCDF12_NS, benchmarks)

    # Remove CCEs and DISA STIG IDs from derivatives as these are specific to
    # the vendor/OS.
    ssg.build_derivatives.remove_idents(root, XCCDF12_NS)
    ssg.build_derivatives.remove_cce_reference(root, oval_ns)

    if len(benchmarks) == 0:
        raise RuntimeError("No Benchmark found!")

    for namespace, benchmark in benchmarks:
        if args[1] not in ("cs9", "cs10") and not args[1].startswith("centos"):
            # In all CentOS and CentOS Streams, profiles are kept because they are systems
            # intended to test content that will get into RHEL
            ssg.build_derivatives.profile_handling(benchmark, namespace)
        if not ssg.build_derivatives.add_cpes(benchmark, namespace, mapping):
            import pprint
            pprint.pprint(namespace)
            pprint.pprint(mapping)
            raise RuntimeError(
                "Could not add derivative OS CPEs to Benchmark '%s'."
                % (benchmark)
            )

        if not ssg.build_derivatives.add_notice(benchmark, namespace, notice,
                                                warning):
            raise RuntimeError(
                "Managed to add derivative OS CPEs but failed to add the "
                "notice to affected XCCDF Benchmark '%s'." % (benchmark)
            )

    ssg.build_derivatives.replace_platform(root, oval_ns, derivative)
    oval_def_id = ssg.build_derivatives.add_cpe_item_to_dictionary(
        root, args[0], args[1], options.id_name, options.cpe_items_dir
    )
    if oval_def_id is not None:
        ssg.build_derivatives.add_oval_definition_to_cpe_oval(
            root, options.unlinked_oval_file_path, oval_def_id
        )

    store_xml(tree, options.output)


if __name__ == "__main__":
    main()
