#!/usr/bin/env python2

"""
Takes given XCCDF or DataStream and for every profile in it it generates one
ansible and bash remediation roles.

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


def generate_role_for_input_content(input_content, benchmark_id, profile_id, template):
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

    make_sp = sp.add_parser("build", help="Build all the remediation roles")
    make_sp.set_defaults(cmd="build")

    input_sp = sp.add_parser("list-inputs", help="Generate input list")
    input_sp.set_defaults(cmd="list_inputs")

    output_sp = sp.add_parser("list-outputs", help="Generate output list")
    output_sp.set_defaults(cmd="list_outputs")

    p.add_argument("-j", "--jobs", type=int, action="store",
                   default=get_cpu_count(),
                   help="how many jobs should be processed in parallel")

    p.add_argument("-t", "--template", action="store", required=True,
                   help="the remediation template")
    p.add_argument("-e", "--extension", action="store", required=True,
                   help="the extension of the roles")
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
    # TODO: [:1] is here because oscap generate fix can't handle multiple
    # benchmarks. This needs to be removed once
    # https://github.com/OpenSCAP/openscap/issues/722 is fixed
    for benchmark_id in benchmarks.keys()[:1]:
        profiles = xccdf_utils.get_profile_choices_for_input(
            input_tree, benchmark_id, None
        )

        if not profiles:
            raise RuntimeError(
                "No profiles were found in '%s' in xccdf:Benchmark of id='%s'."
                % (input_path, benchmark_id)
            )

        for profile_id in profiles.keys():
            benchmark_profile_pairs.append(
                (benchmark_id, profile_id, profiles[profile_id])
            )

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

    for benchmark_id, profile_id, profile_title in benchmark_profile_pairs:
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
            role_filename = \
                "%s-role-%s.%s" % \
                (path_base,
                 xccdf_utils.get_profile_short_id(profile_id_for_path),
                 args.extension)
        else:
            role_filename = \
                "%s-%s-role-%s.%s" % \
                (path_base, benchmark_id_for_path,
                 xccdf_utils.get_profile_short_id(profile_id_for_path),
                 args.extension)
        role_path = os.path.join(output_dir, role_filename)

        if args.cmd == "list_inputs":
            pass  # noop
        elif args.cmd == "list_outputs":
            print(role_path)
        elif args.cmd == "build":
            queue.put((benchmark_id, profile_id, profile_title, role_path))

    def builder():
        while True:
            try:
                benchmark_id, profile_id, profile_title, role_path = \
                    queue.get(False)

                role_src = generate_role_for_input_content(
                    input_path, benchmark_id, profile_id, args.template
                )
                with open(role_path, "w") as f:
                    f.write(role_src.encode("utf-8"))

                queue.task_done()

                print(
                    "Generated '%s' for profile ID '%s' in benchmark '%s', template=%s." %
                    (role_path, profile_id, benchmark_id, args.template)
                )

            except Queue.Empty:
                break

            except Exception as e:
                sys.stderr.write(
                    "Fatal error encountered when generating role '%s'. "
                    "Error details:\n%s\n\n" % (role_path, e)
                )
                queue.task_done()

    if args.cmd == "build":
        workers = []
        for worker_id in range(args.jobs):
            worker = threading.Thread(
                name="Role generate worker #%i" % (worker_id),
                target=builder
            )
            workers.append(worker)
            worker.daemon = True
            worker.start()

        queue.join()


if __name__ == "__main__":
    main()
