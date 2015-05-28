#!/usr/bin/python2

"""
Takes given XCCDF or DataStream and adds Scientific Linux CPE name next to RHEL CPE names.
Can automatically recognize RHEL5, 6, 7 CPEs and adds the Scientifc Linux ones next to
those accordingly.

Apart from adding the CPEs it adds a notice informing the user that the content
has been enabled for Scientifc Linux and what are the implications.

Author: Martin Preisler <mpreisle@redhat.com>
"""

from xml.etree import cElementTree as ElementTree
import sys

XCCDF11_NS = "http://checklists.nist.gov/xccdf/1.1"
XCCDF12_NS = "http://checklists.nist.gov/xccdf/1.2"

RHEL_SL_CPE_MAPPING = {
    "cpe:/o:redhat:enterprise_linux:4": "cpe:/o:scientific:linux:4",
    "cpe:/o:redhat:enterprise_linux:5": "cpe:/o:scientific:linux:5",
    "cpe:/o:redhat:enterprise_linux:6": "cpe:/o:scientific:linux:6",
    "cpe:/o:redhat:enterprise_linux:7": "cpe:/o:scientific:linux:7",
}

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
    "<i>Red Hat Enterprise Linux</i>. There may be configuration differences " \
    "that produce false positives and/or false negatives. If this occurs " \
    "please file a bug report.</li>\n" \
    "\n" \
    "<li><i>Scientifc Linux</i> has its own build system, compiler options, patchsets, " \
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

SL_NOTICE_ELEMENT = ElementTree.fromstring(SL_NOTICE)


def add_sl_cpes(elem, namespace):
    """Adds Scientifc Linux CPEs next to RHEL ones, checks XCCDF elements of given
    namespace.
    """

    affected = False

    for child in list(elem):
        affected = affected or add_sl_cpes(child, namespace)

    # precompute this so that we can affect the tree while iterating
    children = list(elem.findall(".//{%s}platform" % (namespace)))

    for child in children:
        idref = child.get("idref")
        if idref in RHEL_SL_CPE_MAPPING:
            new_platform = ElementTree.Element("{%s}platform" % (namespace))
            new_platform.set("idref", RHEL_SL_CPE_MAPPING[idref])
            # this is done for the newline and indentation
            new_platform.tail = child.tail

            index = list(elem).index(child)
            # insert it right after the respective RHEL CPE
            elem.insert(index + 1, new_platform)

            affected = True

    return affected


def add_sl_notice(benchmark, namespace):
    """Adds Scientifc Linux notice as the first notice to given benchmark.
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
    elem.set("id", "sl_warning")
    elem.append(SL_NOTICE_ELEMENT)
    # this is done for the newline and indentation
    elem.tail = prev_element.tail
    benchmark.insert(index, elem)

    return True


def main():
    # the first arg is the script name
    if len(sys.argv) != 1 + 2:
        print("Usage: enable-sl.py INPUT OUTPUT")
        print("")
        print("INPUT can be XCCDF or Source DataStream.")

        sys.exit(1)

    input_ = sys.argv[1]
    output = sys.argv[2]

    tree = ElementTree.ElementTree()
    tree.parse(input_)

    root = tree.getroot()

    benchmarks = []
    benchmarks.extend([
        (XCCDF11_NS, elem)
        for elem in list(root.findall(".//{%s}Benchmark" % (XCCDF11_NS)))
    ])
    benchmarks.extend([
        (XCCDF12_NS, elem)
        for elem in list(root.findall(".//{%s}Benchmark" % (XCCDF12_NS)))
    ])

    for namespace, benchmark in benchmarks:
        if not add_sl_cpes(benchmark, namespace):
            raise RuntimeError(
                "Could not add Scientifc Linux CPEs to Benchmark '%s'." % (benchmark)
            )

        if not add_sl_notice(benchmark, namespace):
            raise RuntimeError(
                "Managed to add Scientifc Linux CPEs but failed to add the notice to "
                "affected XCCDF Benchmark '%s'." % (benchmark)
            )

    tree.write(output)

if __name__ == "__main__":
    main()
