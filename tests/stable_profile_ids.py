#!/usr/bin/env python3

from __future__ import print_function

import os
import ssg.xml
import ssg.xccdf
import ssg.build_guides
import argparse
import glob
from collections import defaultdict


# Maps shortened benchmark IDs to list of profiles that need to be contained
# in said benchmarks. Delete the predictable prefix of each benchmark ID to get
# the shortened ID. For example xccdf_org.ssgproject.content_benchmark_RHEL-7
# becomes just RHEL-7. Apply the same to profile IDs:
# xccdf_org.ssgproject.content_profile_ospp42 becomes ospp42

STABLE_PROFILE_IDS = {
    "RHEL-6": ["pci-dss"],
    "RHEL-7": ["ospp", "ospp42", "pci-dss"],
}

BENCHMARK_ID_PREFIX = "xccdf_org.ssgproject.content_benchmark_"
PROFILE_ID_PREFIX = "xccdf_org.ssgproject.content_profile_"


def parse_args():
    p = argparse.ArgumentParser()

    p.add_argument("build_dir", type=str,
                   help="Directory with the datastreams that will be checked "
                        "for stable profile IDs. All files matching "
                        "$BUILD_DIR/ssg-*-ds.xml checked.")

    return p.parse_args()


def gather_profiles_from_datastream(path, profiles_per_benchmark):
    input_tree = ssg.xml.ElementTree.parse(path)
    benchmarks = ssg.xccdf.get_benchmark_id_title_map(input_tree)
    if len(benchmarks) == 0:
        raise RuntimeError(
            "Expected input file '%s' to contain at least 1 xccdf:Benchmark. "
            "No Benchmarks were found!" % (path)
        )

    benchmark_profile_pairs = ssg.build_guides.get_benchmark_profile_pairs(
        input_tree, benchmarks)

    for bench_id, profile_id, title in benchmark_profile_pairs:
        if not bench_id.startswith(BENCHMARK_ID_PREFIX):
            raise RuntimeError("Expected benchmark ID '%s' from '%s' to be "
                               "prefixed with '%s'."
                               % (bench_id, path, BENCHMARK_ID_PREFIX))

        if profile_id == "":
            # default profile can be skipped, we know for sure that
            # it will be present in all benchmarks
            continue

        if not profile_id.startswith(PROFILE_ID_PREFIX):
            raise RuntimeError("Expected profile ID '%s' from '%s' to be "
                               "prefixed with '%s'."
                               % (profile_id, path, PROFILE_ID_PREFIX))

        bench_id = bench_id[len(BENCHMARK_ID_PREFIX):]
        profile_id = profile_id[len(PROFILE_ID_PREFIX):]

        profiles_per_benchmark[bench_id].append(profile_id)


def main():
    args = parse_args()

    profiles_per_benchmark = defaultdict(list)
    for path in glob.glob(os.path.join(args.build_dir, "ssg-*-ds.xml")):
        gather_profiles_from_datastream(path, profiles_per_benchmark)

    for bench_id in STABLE_PROFILE_IDS.keys():
        if bench_id not in profiles_per_benchmark:
            raise RuntimeError("Benchmark of shortened ID '%s' was not found "
                               "within any of the datastreams!" % (bench_id))

        for profile_id in STABLE_PROFILE_IDS[bench_id]:
            if profile_id not in profiles_per_benchmark[bench_id]:
                raise RuntimeError("Profile '%s' is required to be in the "
                                   "'%s' benchmark. It is a stable profile "
                                   "that can't be renamed or removed!"
                                   % (profile_id, bench_id))


if __name__ == "__main__":
    main()
