from __future__ import absolute_import
from __future__ import print_function

import os
import sys
from collections import namedtuple

from .ansible import add_minimum_version, remove_multiple_blank_lines, \
                     remove_trailing_whitespace
from .shims import subprocess_check_output, Queue
from .build_guides import _is_blacklisted_profile
from .xccdf import get_profile_short_id
from .constants import OSCAP_PATH, OSCAP_DS_STRING, ansible_system


def generate_for_input_content(input_content, benchmark_id, profile_id,
                               template):
    """Returns remediation for given input_content and profile_id
    combination. This function assumes only one Benchmark exists
    in given input_content!
    """

    args = [OSCAP_PATH, "xccdf", "generate", "fix"]
    # avoid validating the input over and over again for every profile
    args.append("--skip-valid")
    if benchmark_id != "":
        args.extend(["--benchmark-id", benchmark_id])
    if profile_id != "":
        args.extend(["--profile", profile_id])

    args.extend(["--template", template])
    args.append(input_content)

    return subprocess_check_output(args).decode("utf-8")


def _get_filename(path_base, extension, profile_id, benchmark_id, benchmarks,
                  template):
    """
    Returns the filename for a given remediation from the profile_id and
    benchmark_id.
    """
    profile_id_for_path = "default" if not profile_id else profile_id
    benchmark_id_for_path = benchmark_id
    if benchmark_id_for_path.startswith(OSCAP_DS_STRING):
        benchmark_id_for_path = benchmark_id_for_path[len(OSCAP_DS_STRING):]
    if template == ansible_system:
        file_name_base = "playbook"
    else:
        file_name_base = "script"

    if len(benchmarks) == 1 or len(benchmark_id_for_path) == len("RHEL-X"):
        # treat the base RHEL benchmark as a special case to preserve
        # old guide paths and old URLs that people may be relying on
        return "%s-%s-%s.%s" % (path_base, file_name_base,
                                get_profile_short_id(profile_id_for_path),
                                extension)
    return "%s-%s-%s-%s.%s" % \
           (path_base, benchmark_id_for_path, file_name_base,
            get_profile_short_id(profile_id_for_path), extension)


def get_output_paths(benchmarks, benchmark_profile_pairs, path_base, extension,
                     output_dir, template):
    """
    Returns a list of output filenames for each non-blacklisted profile in
    the benchmark.
    """
    paths = []

    for benchmark_id, profile_id, _ in benchmark_profile_pairs:
        # profile (default) is not applicable when generating remediation
        if not profile_id:
            continue

        if _is_blacklisted_profile(profile_id):
            continue

        filename = _get_filename(path_base, extension, profile_id,
                                 benchmark_id, benchmarks, template)
        path = os.path.join(output_dir, filename)
        paths.append(path)

    return paths


def fill_queue(benchmarks, benchmark_profile_pairs, input_path, path_base,
               extension, output_dir, template):
    """
    Returns a queue containing tasks to create each remediation. A task is a
    namedtuple of (benchmark_id, profile_id, input_path, extension,
    remediation_path, template).
    """
    queue = Queue.Queue()
    task = namedtuple('task', ['benchmark_id', 'profile_id', 'input_path',
                               'extension', 'remediation_path', 'template'])

    for benchmark_id, profile_id, _ in benchmark_profile_pairs:
        # profile (default) is not applicable when generating remediation
        if not profile_id:
            continue

        if _is_blacklisted_profile(profile_id):
            continue

        filename = _get_filename(path_base, extension, profile_id,
                                 benchmark_id, benchmarks, template)
        path = os.path.join(output_dir, filename)

        queue.put(task(benchmark_id, profile_id, input_path, extension,
                       path, template))

    return queue


def builder(queue):
    """
    While there are tasks in the queue, process them with
    generate_input_for_content and write their output to the correct
    location.

    Raises any exceptions which occur during handling of a task.
    """

    while True:
        try:
            (benchmark_id, profile_id, input_path, extension, path,
             template) = queue.get(False)

            src = generate_for_input_content(
                input_path, benchmark_id, profile_id, template
            )

            if extension == "yml" and \
               template == "urn:xccdf:fix:script:ansible":
                src = add_minimum_version(src)
                src = remove_multiple_blank_lines(src)
                src = remove_trailing_whitespace(src)
            with open(path, "wb") as _file:
                _file.write(src.encode("utf-8"))

            queue.task_done()
        except Queue.Empty:
            break
        except Exception as error:
            sys.stderr.write(
                "Fatal error encountered when generating '%s'. "
                "Error details:\n%s\n\n" % (path, error)
            )
            queue.task_done()
            with queue.mutex:
                queue.queue.clear()
            raise error
