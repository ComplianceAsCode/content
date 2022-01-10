#!/usr/bin/env python3
import collections
import argparse
import os

from ssg import controls
import ssg.products


SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))


def print_options(opts):
    if len(opts) > 0:
        print("Available options are:\n - " + "\n - ".join(opts))
    else:
        print("The controls file is not written appropriately.")


def validate_args(ctrlmgr, args):
    """ Validates that the appropriate args were given
        and that they're valid entries in the control manager."""

    policy = None
    try:
        policy = ctrlmgr._get_policy(args.id)
    except ValueError as e:
        print("Error: ", e)
        print_options(ctrlmgr.policies.keys())
        exit(1)

    try:
        policy.get_level_with_ancestors_sequence(args.level)
    except ValueError as e:
        print("Error: ", e)
        print_options(policy.levels_by_id.keys())
        exit(1)


def calculate_stats(ctrls):
    total = len(ctrls)
    ctrlstats = collections.defaultdict(int)
    ctrllist = collections.defaultdict(set)

    if total == 0:
        print("No controls founds with the given inputs. Maybe try another level.")
        exit(1)

    for ctrl in ctrls:
        ctrlstats[str(ctrl.status)] += 1
        ctrllist[str(ctrl.status)].add(ctrl)

    applicable = total - ctrlstats[controls.Status.NOT_APPLICABLE]
    assessed = ctrlstats[controls.Status.AUTOMATED] + ctrlstats[controls.Status.SUPPORTED] + \
        ctrlstats[controls.Status.DOCUMENTATION] + ctrlstats[controls.Status.INHERENTLY_MET] + \
        ctrlstats[controls.Status.PARTIAL]

    print("Total controls = {total}".format(total=total))
    print_specific_stat("Applicable", applicable, total)
    print_specific_stat("Assessed", assessed, applicable)
    print()
    print_specific_stat("Automated", ctrlstats[controls.Status.AUTOMATED], applicable)
    print_specific_stat("Manual", ctrlstats[controls.Status.MANUAL], applicable)
    print_specific_stat("Supported", ctrlstats[controls.Status.SUPPORTED], applicable)
    print_specific_stat("Documentation", ctrlstats[controls.Status.DOCUMENTATION], applicable)
    print_specific_stat("Inherently Met", ctrlstats[controls.Status.INHERENTLY_MET], applicable)
    print_specific_stat("Does Not Meet", ctrlstats[controls.Status.DOES_NOT_MEET], applicable)
    print_specific_stat("Partial", ctrlstats[controls.Status.PARTIAL], applicable)

    applicablelist = ctrls - ctrllist[controls.Status.NOT_APPLICABLE]
    assessedlist = set().union(ctrllist[controls.Status.AUTOMATED]).union(ctrllist[controls.Status.SUPPORTED])\
        .union(ctrllist[controls.Status.DOCUMENTATION]).union(ctrllist[controls.Status.INHERENTLY_MET])\
        .union(ctrllist[controls.Status.PARTIAL]).union(ctrllist[controls.Status.MANUAL])
    print("Missing:", ", ".join(sorted(str(c.id) for c in applicablelist - assessedlist)))


def print_specific_stat(stat, current, total):
    print("{stat} = {percent}% -- {current} / {total}".format(
        stat=stat,
        percent=round((current / total) * 100.00, 2),
        current=current,
        total=total))


def stats(ctrlmgr, args):
    validate_args(ctrlmgr, args)
    ctrls = set(ctrlmgr.get_all_controls_of_level(args.id, args.level))
    calculate_stats(ctrls)


subcmds = dict(
    stats=stats
)


def create_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--controls-dir",
        help=("Directory that contains control files with policy controls. "
              "e.g.: ~/scap-security-guide/controls"),
        default="./controls/",
    )
    subparsers = parser.add_subparsers(dest="subcmd", required=True)
    statsparser = subparsers.add_parser(
        'stats',
        help="calculate and return the statistics for the given benchmark")
    statsparser.add_argument(
        "-i", "--id",
        help="the ID or name of the controls file in the controls/ directory",
        required=True)
    statsparser.add_argument(
        "-l", "--level",
        help="the compliance target level to analyze",
        required=True)
    statsparser.add_argument(
        "-p", "--product", help="product to check has required references")
    return parser


def main():
    parser = create_parser()
    args = parser.parse_args()
    product_base = os.path.join(SSG_ROOT, "products", args.product)
    product_yaml = os.path.join(product_base, "product.yml")
    env_yaml = ssg.products.load_product_yaml(product_yaml)
    controls_manager = controls.ControlsManager(args.controls_dir, env_yaml=env_yaml)
    controls_manager.load()
    subcmds[args.subcmd](controls_manager, args)


if __name__ == "__main__":
    main()
