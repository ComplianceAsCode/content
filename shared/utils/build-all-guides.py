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
import argparse
import subprocess

import threading
import Queue
import re
import sys
import multiprocessing

OSCAP_PATH = "oscap"

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
        for benchmark in root_element.findall(
            ".//{%s}Benchmark" % (namespace)
        ):
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


def generate_guide_for_input_content(input_content, benchmark_id, profile_id):
    """Returns HTML guide for given input_content and profile_id
    combination. This function assumes only one Benchmark exists
    in given input_content!
    """

    args = [OSCAP_PATH, "xccdf", "generate", "guide"]
    if benchmark_id != "":
        args.extend(["--benchmark-id", benchmark_id])
    if profile_id != "":
        args.extend(["--profile", profile_id])
    args.append(input_content)

    ret = subprocess_check_output(args).decode("utf-8")

    return ret


def get_cpu_count():
    try:
        return max(1, multiprocessing.cpu_count())

    except NotImplementedError:
        # 2 CPUs is the most probable
        return 2


def main():
    p = argparse.ArgumentParser()

    sp = p.add_subparsers(help="actions")

    make_sp = sp.add_parser("build", help="Build all the HTML guides")
    make_sp.set_defaults(cmd="build")

    input_sp = sp.add_parser("list-inputs", help="Generate input list")
    input_sp.set_defaults(cmd="list_inputs")

    output_sp = sp.add_parser("list-outputs", help="Generate output list")
    output_sp.set_defaults(cmd="list_outputs")

    p.add_argument("-j", "--jobs", type=int, action="store",
                   default=get_cpu_count(),
                   help="how many jobs should be processed in parallel")

    p.add_argument("-i", "--input", action="store", required=True,
                   help="input file, can be XCCDF or Source DataStream")
    p.add_argument("-o", "--output", action="store", required=True,
                   help="output directory")

    args, unknown = p.parse_known_args()
    if unknown:
        sys.stderr.write(
            "Unknown positional arguments " + ",".join(unknown) + ".\n"
        )
        sys.exit(1)

    input_path = os.path.abspath(args.input)
    if args.cmd == "list_inputs":
        print(input_path)
    output_dir = os.path.abspath(args.output)
    input_basename = os.path.basename(input_path)
    path_base, _ = os.path.splitext(input_basename)
    # avoid -ds and -xccdf suffices in guide filenames
    if path_base.endswith("-ds"):
        path_base = path_base[:-3]
    elif path_base.endswith("-xccdf"):
        path_base = path_base[:-6]

    input_tree = ElementTree.parse(input_path)
    benchmarks = get_benchmark_ids_titles_for_input(input_tree)
    if len(benchmarks) == 0:
        raise RuntimeError(
            "Expected input file '%s' to contain at least 1 xccdf:Benchmark. "
            "No Benchmarks were found!" %
            (input_path)
        )

    benchmark_profile_pairs = []
    for benchmark_id in benchmarks.keys():
        profiles = get_profile_choices_for_input(input_tree, benchmark_id, None)
        # add the default profile
        profiles[""] = "(default)"

        if not profiles:
            raise RuntimeError(
                "No profiles were found in '%s' in xccdf:Benchmark of id='%s'."
                % (input_path, benchmark_id)
            )

        for profile_id in profiles.keys():
            benchmark_profile_pairs.append(
                (benchmark_id, profile_id, profiles[profile_id])
            )

    # TODO: Make the index file nicer

    index_links = []
    index_options = []
    index_initial_src = None

    def benchmark_profile_pair_sort_key(
        benchmark_id, profile_id, profile_title
    ):
        # The "base" benchmarks come first
        if benchmark_id.endswith("_RHEL-7") or \
                benchmark_id.endswith("_RHEL-6") or \
                benchmark_id.endswith("_RHEL-5"):
            benchmark_id = "AAA" + benchmark_id

        # The default profile comes last
        if profile_id == "":
            profile_title = "zzz(default)"

        return (benchmark_id, profile_title)

    queue = Queue.Queue()

    for benchmark_id, profile_id, profile_title in \
            sorted(benchmark_profile_pairs,
                   key=lambda x: benchmark_profile_pair_sort_key(
                       x[0], x[1], x[2]
                   )):
        skip = False
        for blacklisted_id in PROFILE_ID_BLACKLIST:
            if profile_id.endswith(blacklisted_id):
                skip = True
                break

        if skip:
            continue

        profile_id_for_path = "default" if not profile_id else profile_id
        benchmark_id_for_path = benchmark_id
        if benchmark_id_for_path.startswith(
            "xccdf_org.ssgproject.content_benchmark_"
        ):
            benchmark_id_for_path = \
                benchmark_id_for_path[
                    len("xccdf_org.ssgproject.content_benchmark_"):
                ]

        if len(benchmarks) == 1 or \
                len(benchmark_id_for_path) == len("RHEL-X"):
            # treat the base RHEL benchmark as a special case to preserve
            # old guide paths and old URLs that people may be relying on
            guide_filename = \
                "%s-guide-%s.html" % \
                (path_base,
                 get_profile_short_id(profile_id_for_path))
        else:
            guide_filename = \
                "%s-%s-guide-%s.html" % \
                (path_base, benchmark_id_for_path,
                 get_profile_short_id(profile_id_for_path))
        guide_path = os.path.join(output_dir, guide_filename)

        if args.cmd == "list_inputs":
            pass  # noop
        elif args.cmd == "list_outputs":
            print(guide_path)
        elif args.cmd == "build":
            index_links.append(
                "<a target=\"guide\" href=\"%s\">%s</a>" %
                (guide_filename, "%s in %s" % (profile_title, benchmark_id))
            )
            index_options.append(
                "<option value=\"%s\" data-benchmark-id=\"%s\" data-profile-id=\"%s\">%s</option>" %
                (guide_filename,
                 "" if len(benchmarks) == 1 else benchmark_id, profile_id,
                 "%s in %s" % (profile_title, benchmark_id))
            )
            if index_initial_src is None:
                index_initial_src = guide_filename

            queue.put((benchmark_id, profile_id, profile_title, guide_path))

    def builder():
        while True:
            try:
                benchmark_id, profile_id, profile_title, guide_path = \
                    queue.get(False)

                guide_html = generate_guide_for_input_content(
                    input_path, benchmark_id, profile_id
                )
                with open(guide_path, "w") as f:
                    f.write(guide_html.encode("utf-8"))

                queue.task_done()

                print(
                    "Generated '%s' for profile ID '%s' in benchmark '%s'." %
                    (guide_path, profile_id, benchmark_id)
                )

            except Queue.Empty:
                break

            except Exception as e:
                sys.stderr.write(
                    "Fatal error encountered when generating guide '%s'. "
                    "Error details:\n%s\n\n" % (guide_path, e)
                )
                queue.task_done()

    if args.cmd == "build":
        workers = []
        for worker_id in range(args.jobs):
            worker = threading.Thread(
                name="Guide generate worker #%i" % (worker_id),
                target=builder
            )
            workers.append(worker)
            worker.daemon = True
            worker.start()

        queue.join()

        index_source = "<!DOCTYPE html>\n"
        index_source += "<html lang=\"en\">\n"
        index_source += "\t<head>\n"
        index_source += "\t\t<meta charset=\"utf-8\">\n"
        index_source += "\t\t<title>%s</title>\n" % \
                        (benchmarks.itervalues().next())
        index_source += "\t\t<script>\n"
        index_source += "\t\t\tfunction change_profile(option_element)\n"
        index_source += "\t\t\t{\n"
        index_source += "\t\t\t\tvar benchmark_id=option_element.getAttribute('data-benchmark-id');\n"
        index_source += "\t\t\t\tvar profile_id=option_element.getAttribute('data-profile-id');\n"
        index_source += "\t\t\t\tvar eval_snippet=document.getElementById('eval_snippet');\n"
        index_source += "\t\t\t\tvar input_path='/usr/share/xml/scap/ssg/content/%s';\n" % (input_basename)
        index_source += "\t\t\t\tif (profile_id == '')\n"
        index_source += "\t\t\t\t{\n"
        index_source += "\t\t\t\t\tif (benchmark_id == '')\n"
        index_source += "\t\t\t\t\t\teval_snippet.innerHTML='# oscap xccdf eval ' + input_path;\n"
        index_source += "\t\t\t\t\telse\n"
        index_source += "\t\t\t\t\t\teval_snippet.innerHTML='# oscap xccdf eval --benchmark-id ' + benchmark_id + ' ' + input_path;\n"
        index_source += "\t\t\t\t}\n"
        index_source += "\t\t\t\telse\n"
        index_source += "\t\t\t\t{\n"
        index_source += "\t\t\t\t\tif (benchmark_id == '')\n"
        index_source += "\t\t\t\t\t\teval_snippet.innerHTML='# oscap xccdf eval --profile ' + profile_id + ' ' + input_path;\n"
        index_source += "\t\t\t\t\telse\n"
        index_source += "\t\t\t\t\t\teval_snippet.innerHTML='# oscap xccdf eval --benchmark-id ' + benchmark_id + ' --profile ' + profile_id + ' ' + input_path;\n"
        index_source += "\t\t\t\t}\n"
        index_source += "\t\t\t\twindow.open(option_element.value, 'guide');\n"
        index_source += "\t\t\t}\n"
        index_source += "\t\t</script>\n"
        index_source += "\t\t<style>\n"
        index_source += "\t\t\thtml, body { margin: 0; height: 100% }\n"
        index_source += "\t\t\t#js_switcher { position: fixed; right: 30px; top: 10px; padding: 2px; background: #ddd; border: 1px solid #999 }\n"
        index_source += "\t\t\t#guide_div { margin: auto; width: 99%; height: 99% }\n"
        index_source += "\t\t</style>\n"
        index_source += "\t</head>\n"
        index_source += "\t<body onload=\"document.getElementById('js_switcher').style.display = 'block'\">\n"
        index_source += "\t\t<noscript>\n"
        index_source += "Profiles: "
        index_source += ", ".join(index_links) + "\n"
        index_source += "\t\t</noscript>\n"
        index_source += "\t\t<div id=\"js_switcher\" style=\"display: none\">\n"
        index_source += "\t\t\tProfile: \n"
        index_source += "\t\t\t<select style=\"margin-bottom: 5px\" "
        index_source += "onchange=\"change_profile(this.options[this.selectedIndex]);\""
        index_source += ">\n"
        index_source += "\n".join(index_options) + "\n"
        index_source += "\t\t\t</select>\n"
        index_source += "\t\t\t<div id='eval_snippet' style='background: #eee; padding: 3px; border: 1px solid #000'>"
        index_source += "select a profile to display its guide and a command line snippet needed to use it"
        index_source += "</div>\n"
        index_source += "\t\t</div>\n"
        index_source += "\t\t<div id=\"guide_div\">\n"
        index_source += \
            "\t\t\t<iframe src=\"%s\" name=\"guide\" " % (index_initial_src)
        index_source += "width=\"100%\" height=\"100%\">\n"
        index_source += "\t\t\t</iframe>\n"
        index_source += "\t\t</div>\n"
        index_source += "\t</body>\n"
        index_source += "</html>\n"

    index_path = os.path.join(output_dir, "%s-guide-index.html" % (path_base))
    if args.cmd == "list_inputs":
        pass  # noop
    elif args.cmd == "list_outputs":
        print(index_path)
    elif args.cmd == "build":
        with open(index_path, "w") as f:
            f.write(index_source.encode("utf-8"))

if __name__ == "__main__":
    main()
