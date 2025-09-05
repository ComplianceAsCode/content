#!/usr/bin/env python2

from __future__ import print_function

"""
Takes given XCCDF or DataStream and for every profile in it it generates one
OpenSCAP HTML guide. Also generates an index file that lists all the profiles
and allows the user to navigate between them.

Author: Martin Preisler <mpreisle@redhat.com>
"""

import os.path
import argparse
import threading
import sys

import ssg.build_guides
import ssg.xccdf
import ssg.utils
import ssg.xml


def parse_args():
    p = argparse.ArgumentParser()

    sp = p.add_subparsers(help="actions")

    make_sp = sp.add_parser("build", help="Build all the HTML guides")
    make_sp.set_defaults(cmd="build")

    input_sp = sp.add_parser("list-inputs", help="Generate input list")
    input_sp.set_defaults(cmd="list_inputs")

    output_sp = sp.add_parser("list-outputs", help="Generate output list")
    output_sp.set_defaults(cmd="list_outputs")

    p.add_argument("-j", "--jobs", type=int, action="store",
                   default=ssg.utils.get_cpu_count(),
                   help="how many jobs should be processed in parallel")
    p.add_argument("-i", "--input", action="store", required=True,
                   help="input file, can be XCCDF or Source DataStream")
    p.add_argument("-o", "--output", action="store", required=True,
                   help="output directory")

    return p.parse_args()


def main():
    args = parse_args()

    input_path, input_basename, path_base, output_dir = \
        ssg.build_guides.get_path_args(args)
    index_path = os.path.join(output_dir, "%s-guide-index.html" % (path_base))

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
        guide_paths = ssg.build_guides.get_output_guide_paths(benchmarks,
                                                              benchmark_profile_pairs,
                                                              path_base, output_dir)

        for guide_path in guide_paths:
            print(guide_path)
        print(index_path)
        sys.exit(0)

    index_links, index_options, index_initial_src, queue = \
        ssg.build_guides.fill_queue(benchmarks, benchmark_profile_pairs,
                                    input_path, path_base, output_dir)

    workers = []
    for worker_id in range(args.jobs):
        worker = threading.Thread(
            name="Guide generate worker #%i" % (worker_id),
            target=lambda queue=queue: ssg.build_guides.builder(queue)
        )
        workers.append(worker)
        worker.daemon = True
        worker.start()

    for worker in workers:
        worker.join()

    if queue.unfinished_tasks > 0:
        raise RuntimeError("Some of the guides were not exported successfully")

    index_source = ssg.build_guides.build_index(benchmarks, input_basename,
                                                index_links, index_options,
                                                index_initial_src)

    with open(index_path, "wb") as f:
        f.write(index_source.encode("utf-8"))


if __name__ == "__main__":
    main()
