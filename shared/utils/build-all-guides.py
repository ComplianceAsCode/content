#!/usr/bin/env python2

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
import sys
import multiprocessing

# Put shared python modules in path
sys.path.insert(0, os.path.join(
        os.path.dirname(os.path.dirname(os.path.realpath(__file__))),
        "modules"))
import xccdf_utils


OSCAP_PATH = "oscap"


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
    benchmarks = xccdf_utils.get_benchmark_ids_titles_for_input(input_tree)
    if len(benchmarks) == 0:
        raise RuntimeError(
            "Expected input file '%s' to contain at least 1 xccdf:Benchmark. "
            "No Benchmarks were found!" %
            (input_path)
        )

    benchmark_profile_pairs = []
    for benchmark_id in benchmarks.keys():
        profiles = xccdf_utils.get_profile_choices_for_input(
            input_tree, benchmark_id, None
        )
        # add the default profile
        profiles[""] = "(default)"

        for profile_id in profiles.keys():
            benchmark_profile_pairs.append(
                (benchmark_id, profile_id, profiles[profile_id])
            )

    # TODO: Make the index file nicer

    index_links = []
    index_options = {}
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
        for blacklisted_id in xccdf_utils.PROFILE_ID_BLACKLIST:
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
                 xccdf_utils.get_profile_short_id(profile_id_for_path))
        else:
            guide_filename = \
                "%s-%s-guide-%s.html" % \
                (path_base, benchmark_id_for_path,
                 xccdf_utils.get_profile_short_id(profile_id_for_path))
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

            if benchmark_id not in index_options:
                index_options[benchmark_id] = []
            index_options[benchmark_id].append(
                "<option value=\"%s\" data-benchmark-id=\"%s\" data-profile-id=\"%s\">%s</option>" %
                (guide_filename,
                 "" if len(benchmarks) == 1 else benchmark_id, profile_id,
                 profile_title)
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

        index_select_options = ""
        if len(index_options.keys()) > 1:
            # we sort by length of the benchmark_id to make sure the "default"
            # comes up first in the list
            for benchmark_id in sorted(index_options.keys(),
                                       key=lambda val: (len(val), val)):
                index_select_options += "<optgroup label=\"benchmark: %s\">\n" \
                    % (benchmark_id)
                index_select_options += "\n".join(index_options[benchmark_id])
                index_select_options += "</optgroup>\n"
        else:
            index_select_options += "\n".join(index_options.values()[0])

        index_source = "".join([
            "<!DOCTYPE html>\n",
            "<html lang=\"en\">\n",
            "\t<head>\n",
            "\t\t<meta charset=\"utf-8\">\n",
            "\t\t<title>%s</title>\n" % (benchmarks.itervalues().next()),
            "\t\t<script>\n",
            "\t\t\tfunction change_profile(option_element)\n",
            "\t\t\t{\n",
            "\t\t\t\tvar benchmark_id=option_element.getAttribute('data-benchmark-id');\n",
            "\t\t\t\tvar profile_id=option_element.getAttribute('data-profile-id');\n",
            "\t\t\t\tvar eval_snippet=document.getElementById('eval_snippet');\n",
            "\t\t\t\tvar input_path='/usr/share/xml/scap/ssg/content/%s';\n" % (input_basename),
            "\t\t\t\tif (profile_id == '')\n",
            "\t\t\t\t{\n",
            "\t\t\t\t\tif (benchmark_id == '')\n",
            "\t\t\t\t\t\teval_snippet.innerHTML='# oscap xccdf eval ' + input_path;\n",
            "\t\t\t\t\telse\n",
            "\t\t\t\t\t\teval_snippet.innerHTML='# oscap xccdf eval --benchmark-id ' + benchmark_id + ' &#92;<br/>' + input_path;\n",
            "\t\t\t\t}\n",
            "\t\t\t\telse\n",
            "\t\t\t\t{\n",
            "\t\t\t\t\tif (benchmark_id == '')\n",
            "\t\t\t\t\t\teval_snippet.innerHTML='# oscap xccdf eval --profile ' + profile_id + ' &#92;<br/>' + input_path;\n",
            "\t\t\t\t\telse\n",
            "\t\t\t\t\t\teval_snippet.innerHTML='# oscap xccdf eval --benchmark-id ' + benchmark_id + ' &#92;<br/>--profile ' + profile_id + ' &#92;<br/>' + input_path;\n",
            "\t\t\t\t}\n",
            "\t\t\t\twindow.open(option_element.value, 'guide');\n",
            "\t\t\t}\n",
            "\t\t</script>\n",
            "\t\t<style>\n",
            "\t\t\thtml, body { margin: 0; height: 100% }\n",
            "\t\t\t#js_switcher { position: fixed; right: 30px; top: 10px; padding: 2px; background: #ddd; border: 1px solid #999 }\n",
            "\t\t\t#guide_div { margin: auto; width: 99%; height: 99% }\n",
            "\t\t</style>\n",
            "\t</head>\n",
            "\t<body onload=\"document.getElementById('js_switcher').style.display = 'block'\">\n",
            "\t\t<noscript>\n",
            "Profiles: ",
            ", ".join(index_links) + "\n",
            "\t\t</noscript>\n",
            "\t\t<div id=\"js_switcher\" style=\"display: none\">\n",
            "\t\t\tProfile: \n",
            "\t\t\t<select style=\"margin-bottom: 5px\" ",
            "onchange=\"change_profile(this.options[this.selectedIndex]);\"",
            ">\n",
            "\n", index_select_options, "\n",
            "\t\t\t</select>\n",
            "\t\t\t<div id='eval_snippet' style='background: #eee; padding: 3px; border: 1px solid #000'>",
            "select a profile to display its guide and a command line snippet needed to use it",
            "</div>\n",
            "\t\t</div>\n",
            "\t\t<div id=\"guide_div\">\n",
            "\t\t\t<iframe src=\"%s\" name=\"guide\" " % (index_initial_src),
            "width=\"100%\" height=\"100%\">\n",
            "\t\t\t</iframe>\n",
            "\t\t</div>\n",
            "\t</body>\n",
            "</html>\n"
        ])

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
