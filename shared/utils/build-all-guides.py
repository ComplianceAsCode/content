#!/usr/bin/python2

"""
Takes given XCCDF or DataStream and for every profile in it it generates one
OpenSCAP HTML guide. Also generates an index file that lists all the profiles
and allows the user to navigate between them.

Author: Martin Preisler <mpreisle@redhat.com>
"""

try:
    from xml.etree import cElementTree as ElementTree
except ImportError:
    import cElementTree as ElementTree

import os.path
from optparse import OptionParser
import subprocess

import threading
import Queue

OSCAP_PATH = "oscap"

XCCDF11_NS = "http://checklists.nist.gov/xccdf/1.1"
XCCDF12_NS = "http://checklists.nist.gov/xccdf/1.2"

# if a profile ID ends with a string listed here we skip it
PROFILE_ID_BLACKLIST = ["test", "index", "default"]
# filler XCCDF 1.2 prefix which we will strip to avoid very long filenames
PROFILE_ID_PREFIX = "xccdf_org.ssgproject.content_profile_"


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


def get_profile_choices_for_input(input_tree, tailoring_tree):
    """Returns a dictionary that maps profile_ids to their respective titles.
    """

    # Ideally oscap would have a command line to do this, but as of now it
    # doesn't so we have to implement it ourselves. Importing openscap Python
    # bindings is nasty and overkill for this.

    ret = {}

    def scrape_profiles(root_element, namespace, dest):
        for elem in root_element.findall(".//{%s}Profile" % (namespace)):
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

    if long_id.startswith(PROFILE_ID_PREFIX):
        return long_id[len(PROFILE_ID_PREFIX):]

    return long_id


def subprocess_check_output(*popenargs, **kwargs):
    # Backport of subprocess.check_output taken from
    # https://gist.github.com/edufelipe/1027906
    #
    # Originally from Python 2.7 stdlib under PSF, compatible with LGPL2+
    # Copyright (c) 2003-2005 by Peter Astrand <astrand@lysator.liu.se>
    # Changes by Eduardo Felipe

    process = subprocess.Popen(stdout=subprocess.PIPE, *popenargs, **kwargs)
    output, unused_err = process.communicate()
    retcode = process.poll()
    if retcode:
        cmd = kwargs.get("args")
        if cmd is None:
            cmd = popenargs[0]
        error = subprocess.CalledProcessError(retcode, cmd)
        error.output = output
        raise error
    return output


if hasattr(subprocess, "check_output"):
    # if available we just use the real function
    subprocess_check_output = subprocess.check_output


def generate_guide_for_input_content(input_content, profile_id):
    """Returns HTML guide for given input_content and profile_id
    combination. This function assumes only one Benchmark exists
    in given input_content!
    """

    args = [OSCAP_PATH, "xccdf", "generate", "guide"]
    if profile_id != "":
        args.extend(["--profile", profile_id])
    args.append(input_content)

    ret = subprocess_check_output(args).decode("utf-8")

    return ret


def main():
    usage = "usage: %prog [options]"
    parser = OptionParser(usage=usage)
    parser.add_option(
        "-i", "--input", dest="input_content", type="string",
        action="store", help="INPUT can be XCCDF or Source DataStream. XCCDF "
        "is supported with all OpenSCAP versions. You need OpenSCAP 1.1.0 or "
        "higher to generate guides from Source DataStream!"
    )
    parser.add_option(
        "-j", "--jobs", dest="parallel_jobs", type="int",
        action="store", help="How many workers should generate guides in "
        "parallel. Defaults to 4.", default=4
    )
    (options, args) = parser.parse_args()

    if options.input_content is None:
        parser.print_help()
        raise RuntimeError("No INPUT file provided, please use --input.")

    parent_dir = os.path.dirname(os.path.abspath(options.input_content))
    path_base, _ = os.path.splitext(os.path.basename(options.input_content))
    # avoid -ds and -xccdf suffices in guide filenames
    if path_base.endswith("-ds"):
        path_base = path_base[:-3]
    elif path_base.endswith("-xccdf"):
        path_base = path_base[:-6]

    input_tree = ElementTree.parse(options.input_content)
    benchmarks = get_benchmark_ids_titles_for_input(input_tree)
    if len(benchmarks) != 1:
        raise RuntimeError(
            "Expected input file '%s' to contain exactly 1 xccdf:Benchmark. "
            "Instead we found %i benchmarks" %
            (options.input_content, len(benchmarks))
        )
    profiles = get_profile_choices_for_input(input_tree, None)
    # add the default profile
    profiles[""] = "(default)"

    if not profiles:
        raise RuntimeError(
            "No profiles were found in '%s'." % (options.input_content)
        )

    queue = Queue.Queue()

    # TODO: Make the index file nicer

    index_links = []
    index_initial_src = None

    for profile_id, profile_title in profiles.iteritems():
        skip = False
        for blacklisted_id in PROFILE_ID_BLACKLIST:
            if profile_id.endswith(blacklisted_id):
                skip = True
                break

        if skip:
            continue

        profile_id_for_path = profile_id
        if profile_id_for_path == "":
            profile_id_for_path = "default"

        guide_filename = \
            "%s-guide-%s.html" % \
            (path_base, get_profile_short_id(profile_id_for_path))
        guide_path = os.path.join(parent_dir, guide_filename)

        index_links.append("<option value=\"%s\">%s</option>" %
                           (guide_filename, profile_title))
        if index_initial_src is None:
            index_initial_src = guide_path

        queue.put((profile_id, profile_title, guide_path))

    def builder():
        while True:
            try:
                profile_id, profile_title, guide_path = queue.get(False)

                guide_html = generate_guide_for_input_content(
                    options.input_content, profile_id
                )
                with open(guide_path, "w") as f:
                    f.write(guide_html.encode("utf-8"))

                queue.task_done()

                print(
                    "Generated '%s' for profile ID '%s'." %
                    (guide_filename, profile_id)
                )

            except Queue.Empty:
                break

    workers = []
    for worker_id in range(options.parallel_jobs):
        worker = threading.Thread(
            name="Guide generate worker #%i" % (worker_id),
            target=builder
        )
        workers.append(worker)
        worker.start()

    queue.join()

    index_source = "<html>\n"
    index_source += "\t<head><title>%s</title></head>" % \
                    (benchmarks.itervalues().next())
    index_source += "\t<body>\n"
    index_source += "\t\tProfile selector: \n"
    index_source += "\t\t<select style=\"margin-bottom: 5px\" onchange=\""
    index_source += \
        "window.open(this.options[this.selectedIndex].value,'guide');"
    index_source += "\">\n"
    index_source += "\n".join(index_links)
    index_source += "\t\t</select><br />\n"
    index_source += \
        "\t\t<iframe src=\"%s\" name=\"guide\" " % (index_initial_src)
    index_source += "style=\"width: 100%; height: calc(100% - 50px)\">\n"
    index_source += "\t\t</iframe>\n"
    index_source += "\t</body>\n"
    index_source += "</html>\n"

    index_path = os.path.join(parent_dir, "%s-guide-index.html" % (path_base))
    with open(index_path, "w") as f:
        f.write(index_source.encode("utf-8"))

if __name__ == "__main__":
    main()
