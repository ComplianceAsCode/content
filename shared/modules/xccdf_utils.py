#!/usr/bin/env python2

"""
A couple generic XCCDF utilities used by build-all-guides.py and
build-all-remediation-roles.py

Author: Martin Preisler <mpreisle@redhat.com>
"""

import re

XCCDF11_NS = "http://checklists.nist.gov/xccdf/1.1"
XCCDF12_NS = "http://checklists.nist.gov/xccdf/1.2"

# if a profile ID ends with a string listed here we skip it
PROFILE_ID_BLACKLIST = ["test", "index", "default"]
# filler XCCDF 1.2 prefix which we will strip to avoid very long filenames
PROFILE_ID_PREFIX = ("^xccdf_org.*content_profile_")


def get_benchmark_ids_titles_for_input(input_tree):
    ret = {}

    def scrape_benchmarks(root_element, namespace, dest):
        candidates = \
            list(root_element.findall(".//{%s}Benchmark" % (namespace)))
        if root_element.tag == "{%s}Benchmark" % (namespace):
            candidates.append(root_element)

        for elem in candidates:
            id_ = elem.get("id")
            if id_ is None:
                continue

            title = "<unknown>"
            for element in elem.findall("{%s}title" % (namespace)):
                title = element.text
                break

            dest[id_] = title

    input_root = input_tree.getroot()

    scrape_benchmarks(
        input_root, XCCDF11_NS, ret
    )
    scrape_benchmarks(
        input_root, XCCDF12_NS, ret
    )

    return ret


def get_profile_choices_for_input(input_tree, benchmark_id, tailoring_tree):
    """Returns a dictionary that maps profile_ids to their respective titles.
    """

    # Ideally oscap would have a command line to do this, but as of now it
    # doesn't so we have to implement it ourselves. Importing openscap Python
    # bindings is nasty and overkill for this.

    ret = {}

    def scrape_profiles(root_element, namespace, dest):
        candidates = \
            list(root_element.findall(".//{%s}Benchmark" % (namespace)))
        if root_element.tag == "{%s}Benchmark" % (namespace):
            candidates.append(root_element)

        for benchmark in candidates:
            if benchmark.get("id") != benchmark_id:
                continue

            for elem in benchmark.findall(".//{%s}Profile" % (namespace)):
                id_ = elem.get("id")
                if id_ is None:
                    continue

                title = "<unknown>"
                for element in elem.findall("{%s}title" % (namespace)):
                    title = element.text
                    break

                dest[id_] = title

    input_root = input_tree.getroot()

    scrape_profiles(
        input_root, XCCDF11_NS, ret
    )
    scrape_profiles(
        input_root, XCCDF12_NS, ret
    )

    if tailoring_tree is not None:
        tailoring_root = tailoring_tree.getroot()

        scrape_profiles(
            tailoring_root, XCCDF11_NS, ret
        )
        scrape_profiles(
            tailoring_root, XCCDF12_NS, ret
        )

    return ret


def get_profile_short_id(long_id):
    """If given profile ID is the XCCDF 1.2 long ID this function shortens it
    """

    if re.search(PROFILE_ID_PREFIX, long_id):
        return long_id[re.search(PROFILE_ID_PREFIX, long_id).end():]

    return long_id
