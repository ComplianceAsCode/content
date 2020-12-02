#!/usr/bin/env python2

from __future__ import print_function

"""
Takes given XCCDF or DataStream and adds RHEL derivative operating system(s) CPE name next
to RHEL CPE names. Can automatically recognize RHEL CPEs and adds the derivitive OS ones
next to those accordingly.

Apart from adding the CPEs it adds a notice informing the user that the content
has been enabled for the derivative operating systems and what are the implications.

Author: Martin Preisler <mpreisle@redhat.com>
"""

import os
import sys
from optparse import OptionParser

import ssg.constants
import ssg.build_derivatives
import ssg.xccdf
import ssg.xml

XCCDF11_NS = ssg.constants.XCCDF11_NS
XCCDF12_NS = ssg.constants.XCCDF12_NS
oval_ns = ssg.constants.oval_namespace

CENTOS_NOTICE_ELEMENT = ssg.xml.ElementTree.fromstring(ssg.constants.CENTOS_NOTICE)
SL_NOTICE_ELEMENT = ssg.xml.ElementTree.fromstring(ssg.constants.SL_NOTICE)

CENTOS_WARNING = 'centos_warning'
SL_WARNING = 'sl_warning'


def parse_args():
    usage = "usage: %prog [options]"
    parser = OptionParser(usage=usage)
    parser.add_option("--enable-centos", dest="centos", default=False,
                      action="store_true", help="Enable CentOS")
    parser.add_option("--enable-sl", dest="sl", default=False,
                      action="store_true", help="Enable Scientific Linux")
    parser.add_option("-i", "--input", dest="input_content", default=False,
                      action="store",
                      help="INPUT can be XCCDF or Source DataStream")
    parser.add_option("-o", "--output", dest="output", default=False,
                      action="store", help="XML Tree content")
    parser.add_option("--id-name", dest="id_name", default="ssg",
                      action="store", help="ID naming scheme")
    (options, args) = parser.parse_args()

    if options.centos and options.sl:
        sys.stderr.write(
            "Cannot enable two derivative OS(s) at the same time\n"
        )
        parser.print_help()
        sys.exit(1)

    if not options.output and not options.input_content:
        parser.print_help()
        sys.exit(1)


    return options, args


def main():
    options, args = parse_args()

    if options.centos:
        mapping = ssg.constants.RHEL_CENTOS_CPE_MAPPING
        notice = CENTOS_NOTICE_ELEMENT
        warning = CENTOS_WARNING
        derivative = "CentOS"

    if options.sl:
        mapping = ssg.constants.RHEL_SL_CPE_MAPPING
        notice = SL_NOTICE_ELEMENT
        warning = SL_WARNING
        derivative = "Scientific Linux"

    tree = ssg.xml.open_xml(options.input_content)
    root = tree.getroot()

    benchmarks = []

    ssg.xccdf.scrape_benchmarks(root, XCCDF11_NS, benchmarks)
    ssg.xccdf.scrape_benchmarks(root, XCCDF12_NS, benchmarks)

    # Remove CCEs and DISA STIG IDs from derivatives as these are specific to
    # the vendor/OS.
    ssg.build_derivatives.remove_idents(root, XCCDF11_NS)
    ssg.build_derivatives.remove_idents(root, XCCDF12_NS)
    ssg.build_derivatives.remove_cce_reference(root, oval_ns)

    if len(benchmarks) == 0:
        raise RuntimeError("No Benchmark found!")

    for namespace, benchmark in benchmarks:
        ssg.build_derivatives.profile_handling(benchmark, namespace)
        if not ssg.build_derivatives.add_cpes(benchmark, namespace, mapping):
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
    ssg.build_derivatives.add_cpe_item_to_dictionary(root, args[0], args[1], "ssg-%s-cpe-oval.xml" % args[0], options.id_name)

    tree.write(options.output)


if __name__ == "__main__":
    main()
