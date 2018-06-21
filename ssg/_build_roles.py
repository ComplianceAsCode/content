import sys
try:
    import queue as Queue
except ImportError:
    import Queue

from ssg._ansible import add_minimum_version
from ssg._shims import subprocess_check_output
from ssg._build_guides import _is_blacklisted_profile
from ssg._xccdf import *
from ssg._constants import *


def generate_for_input_content(input_content, benchmark_id, profile_id,
                               template):
    """Returns remediation role for given input_content and profile_id
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


def _get_filename(path_base, extension, profile_id, benchmark_id, benchmarks):
    profile_id_for_path = "default" if not profile_id else profile_id
    benchmark_id_for_path = benchmark_id
    if benchmark_id_for_path.startswith(OSCAP_DS_STRING):
        benchmark_id_for_path = benchmark_id_for_path[len(OSCAP_DS_STRING):]

    if len(benchmarks) == 1 or len(benchmark_id_for_path) == len("RHEL-X"):
        # treat the base RHEL benchmark as a special case to preserve
        # old guide paths and old URLs that people may be relying on
        return "%s-role-%s.%s" % (path_base,
                                  get_profile_short_id(profile_id_for_path),
                                  extension)
    else:
        return "%s-%s-role-%s.%s" % \
            (path_base, benchmark_id_for_path,
             get_profile_short_id(profile_id_for_path), extension)


def get_output_paths(benchmarks, benchmark_profile_pairs, path_base, extension,
                     output_dir):
    role_paths = []

    for benchmark_id, profile_id, profile_title in benchmark_profile_pairs:
        if _is_blacklisted_profile(profile_id):
            continue

        role_filename = _get_filename(path_base, extension, profile_id,
                                      benchmark_id, benchmarks)
        role_path = os.path.join(output_dir, role_filename)

        role_paths.append(role_path)

    return role_paths


def fill_queue(benchmarks, benchmark_profile_pairs, input_path, path_base,
               extension, output_dir, template):
    queue = Queue.Queue()

    for benchmark_id, profile_id, profile_title in benchmark_profile_pairs:
        if _is_blacklisted_profile(profile_id):
            continue

        role_filename = _get_filename(path_base, extension, profile_id,
                                      benchmark_id, benchmarks)
        role_path = os.path.join(output_dir, role_filename)

        queue.put((benchmark_id, profile_id, profile_title, input_path,
                   extension, role_path, template))

    return queue


def builder(queue):
    while True:
        try:
            (benchmark_id, profile_id, profile_title, input_path, extension,
                role_path, template) = queue.get(False)

            role_src = generate_for_input_content(
                input_path, benchmark_id, profile_id, template
            )

            if extension == "yml" and \
               template == "urn:xccdf:fix:script:ansible":
                role_src = add_minimum_version(role_src)
            with open(role_path, "wb") as f:
                f.write(role_src.encode("utf-8"))

            queue.task_done()
        except Queue.Empty:
            break
        except Exception as e:
            sys.stderr.write(
                "Fatal error encountered when generating role '%s'. "
                "Error details:\n%s\n\n" % (role_path, e)
            )
            queue.task_done()
            with queue.mutex:
                queue.queue.clear()
            raise e
