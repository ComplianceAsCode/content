#!/usr/bin/env python2

"""
Takes given XCCDF or DataStream and adds RHEL derivative operating system(s) CPE name next
to RHEL CPE names. Can automatically recognize RHEL6, 7, etc. CPEs and adds the derivitive OS ones
next to those accordingly.

Apart from adding the CPEs it adds a notice informing the user that the content
has been enabled for the derivative operating systems and what are the implications.

Author: Martin Preisler <mpreisle@redhat.com>
"""

try:
    from xml.etree import cElementTree as ElementTree
except ImportError:
    import cElementTree as ElementTree

import sys
import re
from optparse import OptionParser

XCCDF11_NS = "http://checklists.nist.gov/xccdf/1.1"
XCCDF12_NS = "http://checklists.nist.gov/xccdf/1.2"

RHEL_CENTOS_CPE_MAPPING = {
    "cpe:/o:redhat:enterprise_linux:6": "cpe:/o:centos:centos:6",
    "cpe:/o:redhat:enterprise_linux:7": "cpe:/o:centos:centos:7",
}

RHEL_SL_CPE_MAPPING = {
    "cpe:/o:redhat:enterprise_linux:6": "cpe:/o:scientificlinux:scientificlinux:6",
    "cpe:/o:redhat:enterprise_linux:7": "cpe:/o:scientificlinux:scientificlinux:7",
}

CENTOS_NOTICE = \
    "<div xmlns=\"http://www.w3.org/1999/xhtml\">\n" \
    "<p>This benchmark is a direct port of a <i>SCAP Security Guide </i> " \
    "benchmark developed for <i>Red Hat Enterprise Linux</i>. It has been " \
    "modified through an automated process to remove specific dependencies " \
    "on <i>Red Hat Enterprise Linux</i> and to function with <i>CentOS</i>. " \
    "The result is a generally useful <i>SCAP Security Guide</i> benchmark " \
    "with the following caveats:</p>\n" \
    "<ul>\n" \
    "<li><i>CentOS</i> is not an exact copy of " \
    "<i>Red Hat Enterprise Linux</i>. There may be configuration differences " \
    "that produce false positives and/or false negatives. If this occurs " \
    "please file a bug report.</li>\n" \
    "\n" \
    "<li><i>CentOS</i> has its own build system, compiler options, patchsets, " \
    "and is a community supported, non-commercial operating system. " \
    "<i>CentOS</i> does not inherit " \
    "certifications or evaluations from <i>Red Hat Enterprise Linux</i>. As " \
    "such, some configuration rules (such as those requiring " \
    "<i>FIPS 140-2</i> encryption) will continue to fail on <i>CentOS</i>.</li>\n" \
    "</ul>\n" \
    "\n" \
    "<p>Members of the <i>CentOS</i> community are invited to participate in " \
    "<a href=\"http://open-scap.org\">OpenSCAP</a> and " \
    "<a href=\"https://github.com/OpenSCAP/scap-security-guide\">" \
    "SCAP Security Guide</a> development. Bug reports and patches " \
    "can be sent to GitHub: " \
    "<a href=\"https://github.com/OpenSCAP/scap-security-guide\">" \
    "https://github.com/OpenSCAP/scap-security-guide</a>. " \
    "The mailing list is at " \
    "<a href=\"https://fedorahosted.org/mailman/listinfo/scap-security-guide\">" \
    "https://fedorahosted.org/mailman/listinfo/scap-security-guide</a>" \
    ".</p>" \
    "</div>"

SL_NOTICE = \
    "<div xmlns=\"http://www.w3.org/1999/xhtml\">\n" \
    "<p>This benchmark is a direct port of a <i>SCAP Security Guide </i> " \
    "benchmark developed for <i>Red Hat Enterprise Linux</i>. It has been " \
    "modified through an automated process to remove specific dependencies " \
    "on <i>Red Hat Enterprise Linux</i> and to function with <i>Scientifc Linux</i>. " \
    "The result is a generally useful <i>SCAP Security Guide</i> benchmark " \
    "with the following caveats:</p>\n" \
    "<ul>\n" \
    "<li><i>Scientifc Linux</i> is not an exact copy of " \
    "<i>Red Hat Enterprise Linux</i>. Scientific Linux is a Linux distribution " \
    "produced by <i>Fermi National Accelerator Laboratory</i>. It is a free and " \
    "open source operating system based on <i>Red Hat Enterprise Linux</i> and aims " \
    "to be \"as close to the commercial enterprise distribution as we can get it.\" " \
    "There may be configuration differences that produce false positives and/or " \
    "false negatives. If this occurs please file a bug report.</li>\n" \
    "\n" \
    "<li><i>Scientifc Linux</i> is derived from the free and open source software " \
    "made available by Red Hat, but it is not produced, maintained or supported by <i>Red Hat</i>. " \
    "<i>Scientifc Linux</i> has its own build system, compiler options, patchsets, " \
    "and is a community supported, non-commercial operating system. " \
    "<i>Scientifc Linux</i> does not inherit " \
    "certifications or evaluations from <i>Red Hat Enterprise Linux</i>. As " \
    "such, some configuration rules (such as those requiring " \
    "<i>FIPS 140-2</i> encryption) will continue to fail on <i>Scientifc Linux</i>.</li>\n" \
    "</ul>\n" \
    "\n" \
    "<p>Members of the <i>Scientifc Linux</i> community are invited to participate in " \
    "<a href=\"http://open-scap.org\">OpenSCAP</a> and " \
    "<a href=\"https://github.com/OpenSCAP/scap-security-guide\">" \
    "SCAP Security Guide</a> development. Bug reports and patches " \
    "can be sent to GitHub: " \
    "<a href=\"https://github.com/OpenSCAP/scap-security-guide\">" \
    "https://github.com/OpenSCAP/scap-security-guide</a>. " \
    "The mailing list is at " \
    "<a href=\"https://fedorahosted.org/mailman/listinfo/scap-security-guide\">" \
    "https://fedorahosted.org/mailman/listinfo/scap-security-guide</a>" \
    ".</p>" \
    "</div>"

CENTOS_NOTICE_ELEMENT = ElementTree.fromstring(CENTOS_NOTICE)
SL_NOTICE_ELEMENT = ElementTree.fromstring(SL_NOTICE)

CENTOS_WARNING = 'centos_warning'
SL_WARNING = 'sl_warning'


def add_derivative_cpes(elem, namespace, mapping):
    """Adds derivative CPEs next to RHEL ones, checks XCCDF elements of given
    namespace.
    """

    affected = False

    for child in list(elem):
        affected = affected or add_derivative_cpes(child, namespace, mapping)

    # precompute this so that we can affect the tree while iterating
    children = list(elem.findall(".//{%s}platform" % (namespace)))

    for child in children:
        idref = child.get("idref")
        if idref in mapping:
            new_platform = ElementTree.Element("{%s}platform" % (namespace))
            new_platform.set("idref", mapping[idref])
            # this is done for the newline and indentation
            new_platform.tail = child.tail

            index = list(elem).index(child)
            # insert it right after the respective RHEL CPE
            elem.insert(index + 1, new_platform)

            affected = True

    return affected


def add_derivative_notice(benchmark, namespace, notice, warning):
    """Adds derivative notice as the first notice to given benchmark.
    """

    index = -1
    prev_element = None
    existing_notices = list(benchmark.findall("./{%s}notice" % (namespace)))
    if len(existing_notices) > 0:
        prev_element = existing_notices[0]
        # insert before the first notice
        index = list(benchmark).index(prev_element)
    else:
        existing_descriptions = list(
            benchmark.findall("./{%s}description" % (namespace))
        )
        prev_element = existing_descriptions[-1]
        # insert after the last description
        index = list(benchmark).index(prev_element) + 1

    if index == -1:
        raise RuntimeError(
            "Can't find existing notices or description in benchmark '%s'." %
            (benchmark)
        )

    elem = ElementTree.Element("{%s}notice" % (namespace))
    elem.set("id", warning)
    elem.append(notice)
    # this is done for the newline and indentation
    elem.tail = prev_element.tail
    benchmark.insert(index, elem)

    return True


def remove_rh_idents(tree_root, namespace):
    for rule in tree_root.findall(".//{%s}Rule" % (namespace)):
        for ident in rule.findall(".//{%s}ident" % (namespace)):
            if ident is not None:
                if re.search('CCE-*', ident.text) or re.search('.*RHEL-*', ident.text):
                    rule.remove(ident)

        for ref in rule.findall(".//{%s}reference" % (namespace)):
            if ref.text is not None:
                if re.search('RHEL-*', ref.text):
                    rule.remove(ref)


def main():
    usage = "usage: %prog [options]"
    parser = OptionParser(usage=usage)
    parser.add_option("--enable-centos", dest="centos", default=False,
                      action="store_true", help="Enable CentOS")
    parser.add_option("--enable-sl", dest="sl", default=False,
                      action="store_true", help="Enable Scientific Linux")
    parser.add_option("-i", "--input", dest="input_content", default=False,
                      action="store", help="INPUT can be XCCDF or Source DataStream")
    parser.add_option("-o", "--output", dest="output", default=False,
                      action="store", help="XML Tree content")
    (options, args) = parser.parse_args()

    if options.centos and options.sl:
        print "Cannot enable two derivative OS(s) at the same time"
        parser.print_help()
        sys.exit(1)

    if not options.output and not options.input_content:
        parser.print_help()
        sys.exit(1)

    if options.centos:
        mapping = RHEL_CENTOS_CPE_MAPPING
        notice = CENTOS_NOTICE_ELEMENT
        warning = CENTOS_WARNING

    if options.sl:
        mapping = RHEL_SL_CPE_MAPPING
        notice = SL_NOTICE_ELEMENT
        warning = SL_WARNING

    tree = ElementTree.ElementTree()
    tree.parse(options.input_content)

    root = tree.getroot()

    benchmarks = []

    def scrape_benchmarks(root_element, namespace, dest):
        dest.extend([
            (namespace, elem)
            for elem in list(root.findall(".//{%s}Benchmark" % (namespace)))
        ])
        if root_element.tag == "{%s}Benchmark" % (namespace):
            dest.append((namespace, root_element))

    scrape_benchmarks(root, XCCDF11_NS, benchmarks)
    scrape_benchmarks(root, XCCDF12_NS, benchmarks)

    # Remove CCEs and DISA STIG IDs from derivatives as these are specific to
    # the vendor/OS.
    remove_rh_idents(root, XCCDF11_NS)
    remove_rh_idents(root, XCCDF12_NS)

    if len(benchmarks) == 0:
        raise RuntimeError("No Benchmark found!")

    for namespace, benchmark in benchmarks:
        if not add_derivative_cpes(benchmark, namespace, mapping):
            raise RuntimeError(
                "Could not add derivative OS CPEs to Benchmark '%s'." % (benchmark)
            )

        if not add_derivative_notice(benchmark, namespace, notice, warning):
            raise RuntimeError(
                "Managed to add derivative OS CPEs but failed to add the notice to "
                "affected XCCDF Benchmark '%s'." % (benchmark)
            )

    tree.write(options.output)

if __name__ == "__main__":
    main()
