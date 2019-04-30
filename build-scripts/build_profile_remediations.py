#!/usr/bin/env python2

from __future__ import print_function

"""
Takes given XCCDF or DataStream and for every profile in it it generates one
Ansible Playbook and Bash script.

Author: Martin Preisler <mpreisle@redhat.com>
"""

import os.path
import argparse

import threading
import sys

import ssg.build_guides
import ssg.build_profile_remediations
import ssg.utils
import ssg.xml


def parse_args():
    p = argparse.ArgumentParser()

    sp = p.add_subparsers(help="actions")

    make_sp = sp.add_parser("build",
                            help="Build all the profile remediations")
    make_sp.set_defaults(cmd="build")

    input_sp = sp.add_parser("list-inputs", help="Generate input list")
    input_sp.set_defaults(cmd="list_inputs")

    output_sp = sp.add_parser("list-outputs", help="Generate output list")
    output_sp.set_defaults(cmd="list_outputs")

    p.add_argument("-j", "--jobs", type=int, action="store",
                   default=ssg.utils.get_cpu_count(),
                   help="how many jobs should be processed in parallel")

    p.add_argument("-t", "--template", action="store", required=True,
                   help="the remediation template")
    p.add_argument("-e", "--extension", action="store", required=True,
                   help="the extension of the files")
    p.add_argument("-i", "--input", action="store", required=True,
                   help="input file, can be XCCDF or Source DataStream")
    p.add_argument("-o", "--output", action="store", required=True,
                   help="output directory")

    return p.parse_args()


def main():
    args = parse_args()

    input_path, input_basename, path_base, output_dir = \
        ssg.build_guides.get_path_args(args)
    extension = args.extension
    template = args.template

    ssg_prefix = "ssg-"
    if path_base.startswith(ssg_prefix):
        path_base = path_base[len(ssg_prefix):]

    if args.cmd == "list_inputs":
        print(input_path)
        sys.exit(0)

    input_tree = ssg.xml.ElementTree.parse(input_path)
    benchmarks = ssg.xccdf.get_benchmark_id_title_map(input_tree)
    if len(benchmarks) == 0:
        raise RuntimeError(
            "Expected input file '%s' to contain at least 1 xccdf:Benchmark. "
            "No Benchmarks were found!" %
            (input_path)
        )

    benchmark_profile_pairs = ssg.build_guides.get_benchmark_profile_pairs(
        input_tree, benchmarks)

    if args.cmd == "list_outputs":
        remediation_paths = ssg.build_profile_remediations.get_output_paths(
            benchmarks, benchmark_profile_pairs, path_base, extension,
            output_dir, template
        )

        for remediation_path in role_paths:
            print(remediation_path)

        sys.exit(0)

    queue = ssg.build_profile_remediations.fill_queue(
        benchmarks, benchmark_profile_pairs, input_path, path_base,
        extension, output_dir, template
    )

    workers = []
    for worker_id in range(args.jobs):
        worker = threading.Thread(
            name="Remediation generator worker #%i" % (worker_id),
            target=lambda queue=queue: ssg.build_profile_remediations.builder(queue)
        )
        workers.append(worker)
        worker.daemon = True
        worker.start()

    for worker in workers:
        worker.join()


if __name__ == "__main__":
    main()
