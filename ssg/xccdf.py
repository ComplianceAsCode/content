"""
A couple generic XCCDF utilities used by build_all_guides.py and
build_all_remediations.py

Author: Martin Preisler <mpreisle@redhat.com>
"""

from __future__ import absolute_import
from __future__ import print_function

import re

from .constants import XCCDF11_NS, XCCDF12_NS

# if a profile ID ends with a string listed here we skip it
PROFILE_ID_BLACKLIST = ["test", "index", "default"]
# filler XCCDF 1.2 prefix which we will strip to avoid very long filenames
PROFILE_ID_PREFIX = ("^xccdf_org.*content_profile_")


def get_benchmark_id_title_map(input_tree):
    input_root = input_tree.getroot()
    ret = {}

    for namespace in [XCCDF11_NS, XCCDF12_NS]:
        candidates = []
        scrape_benchmarks(input_root, namespace, candidates)

        for _, elem in candidates:
            _id = elem.get("id")
            if _id is None:
                continue

            title = "<unknown>"
            for element in elem.findall("{%s}title" % (namespace)):
                title = element.text
                break

            ret[_id] = title

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


def scrape_benchmarks(root, namespace, dest):
    """
    Add all benchmark elements in root to dest list
    """
    dest.extend([
        (namespace, elem)
        for elem in list(root.findall(".//{%s}Benchmark" % (namespace)))
    ])
    if root.tag == "{%s}Benchmark" % (namespace):
        dest.append((namespace, root))
