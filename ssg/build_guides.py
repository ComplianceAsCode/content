from __future__ import absolute_import
from __future__ import print_function

import os
import sys
from collections import namedtuple

from .shims import subprocess_check_output, Queue
from .xccdf import get_profile_choices_for_input, get_profile_short_id
from .xccdf import PROFILE_ID_BLACKLIST
from .constants import OSCAP_DS_STRING, OSCAP_PATH


def get_path_args(args):
    """
    Return a namedtuple of (input_path, input_basename, path_base,
    output_dir) from an argparse containing args.input and args.output.
    """

    paths = namedtuple('paths', ['input_path', 'input_basename',
                                 'path_base', 'output_dir'])

    input_path = os.path.abspath(args.input)

    output_dir = os.path.abspath(args.output)
    input_basename = os.path.basename(input_path)

    path_base, _ = os.path.splitext(input_basename)
    # avoid -ds and -xccdf suffices in guide filenames
    if path_base.endswith("-ds"):
        path_base = path_base[:-3]
    elif path_base.endswith("-xccdf"):
        path_base = path_base[:-6]

    return paths(input_path, input_basename, path_base, output_dir)


def generate_for_input_content(input_content, benchmark_id, profile_id):
    """
    Returns HTML guide for given input_content and profile_id
    combination. This function assumes only one Benchmark exists
    in given input_content!
    """

    args = [OSCAP_PATH, "xccdf", "generate", "guide"]
    if benchmark_id != "":
        args.extend(["--benchmark-id", benchmark_id])
    if profile_id != "":
        args.extend(["--profile", profile_id])
    args.append(input_content)

    return subprocess_check_output(args).decode("utf-8")


def builder(queue):
    """
    Fetch from a queue of tasks, process tasks until the queue is empty.
    Each task is processed with generate_for_input_content, and the
    guide is written as output.

    Raises: when an error occurred when processing a task.
    """
    while True:
        try:
            benchmark_id, profile_id, input_path, guide_path = \
                queue.get(False)

            guide_html = generate_for_input_content(
                input_path, benchmark_id, profile_id
            )

            with open(guide_path, "wb") as guide_file:
                guide_file.write(guide_html.encode("utf-8"))

            queue.task_done()
        except Queue.Empty:
            break
        except Exception as error:
            sys.stderr.write(
                "Fatal error encountered when generating guide '%s'. "
                "Error details:\n%s\n\n" % (guide_path, error)
            )
            with queue.mutex:
                queue.queue.clear()
            raise error


def _benchmark_profile_pair_sort_key(benchmark_id, profile_id, profile_title):
    # The "base" benchmarks come first
    if (benchmark_id.endswith("_RHEL-7") or
            benchmark_id.endswith("_RHEL-6") or
            benchmark_id.endswith("_RHEL-5")):
        benchmark_id = "AAA" + benchmark_id

    # The default profile comes last
    if not profile_id:
        profile_title = "zzz(default)"

    return (benchmark_id, profile_title)


def get_benchmark_profile_pairs(input_tree, benchmarks):
    benchmark_profile_pairs = []

    for benchmark_id in benchmarks.keys():
        profiles = get_profile_choices_for_input(input_tree, benchmark_id,
                                                 None)

        # add the default profile
        profiles[""] = "(default)"

        for profile_id in profiles:
            pair = (benchmark_id, profile_id, profiles[profile_id])
            benchmark_profile_pairs.append(pair)

    return sorted(benchmark_profile_pairs, key=lambda x:
                  _benchmark_profile_pair_sort_key(x[0], x[1], x[2]))


def _is_blacklisted_profile(profile_id):
    for blacklisted_id in PROFILE_ID_BLACKLIST:
        if profile_id.endswith(blacklisted_id):
            return True
    return False


def _get_guide_filename(path_base, profile_id, benchmark_id, benchmarks):
    profile_id_for_path = "default" if not profile_id else profile_id
    benchmark_id_for_path = benchmark_id
    if benchmark_id_for_path.startswith(OSCAP_DS_STRING):
        benchmark_id_for_path = \
            benchmark_id_for_path[len(OSCAP_DS_STRING):]

    if len(benchmarks) == 1 or len(benchmark_id_for_path) == len("RHEL-X"):
        # treat the base RHEL benchmark as a special case to preserve
        # old guide paths and old URLs that people may be relying on
        return "%s-guide-%s.html" % (path_base,
                                     get_profile_short_id(profile_id_for_path))

    return "%s-%s-guide-%s.html" % \
        (path_base, benchmark_id_for_path,
         get_profile_short_id(profile_id_for_path))


def get_output_guide_paths(benchmarks, benchmark_profile_pairs, path_base,
                           output_dir):
    """
    Return a list of guide paths containing guides for each non-blacklisted
    profile_id in a benchmark.
    """

    guide_paths = []

    for benchmark_id, profile_id, _ in benchmark_profile_pairs:
        if _is_blacklisted_profile(profile_id):
            continue

        guide_filename = _get_guide_filename(path_base, profile_id,
                                             benchmark_id, benchmarks)
        guide_path = os.path.join(output_dir, guide_filename)

        guide_paths.append(guide_path)

    return guide_paths


def fill_queue(benchmarks, benchmark_profile_pairs, input_path, path_base,
               output_dir):
    """
    For each benchmark and profile in the benchmark, create a queue of
    tasks for later processing. A task is a named tuple (benchmark_id,
    profile_id, input_path, guide_path).

    Returns: queue of tasks.
    """

    index_links = []
    index_options = {}
    index_initial_src = None
    queue = Queue.Queue()

    task = namedtuple('task', ['benchmark_id', 'profile_id', 'input_path', 'guide_path'])

    for benchmark_id, profile_id, profile_title in benchmark_profile_pairs:
        if _is_blacklisted_profile(profile_id):
            continue

        guide_filename = _get_guide_filename(path_base, profile_id,
                                             benchmark_id, benchmarks)
        guide_path = os.path.join(output_dir, guide_filename)

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

        queue.put(task(benchmark_id, profile_id, input_path, guide_path))

    return index_links, index_options, index_initial_src, queue


def build_index(benchmarks, input_basename, index_links, index_options,
                index_initial_src):
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
        index_select_options += "\n".join(list(index_options.values())[0])

    return "".join([
        "<!DOCTYPE html>\n",
        "<html lang=\"en\">\n",
        "\t<head>\n",
        "\t\t<meta charset=\"utf-8\">\n",
        "\t\t<title>%s</title>\n" % (list(benchmarks.values())[0]),
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
