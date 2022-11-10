#!/usr/bin/python3
import argparse
import collections
import json
import os

# NOTE: This is not to be confused with the https://pypi.org/project/ssg/
# package. The ssg package we're referencing here is actually a relative import
# within this repository. Because of this, you need to ensure
# ComplianceAsCode/content/ssg is discoverable from PYTHONPATH before you
# invoke this script.
try:
    from ssg import controls
    import ssg.products
except ModuleNotFoundError as e:
    # NOTE: Only emit this message if we're dealing with an import error for
    # ssg. Since the local ssg module imports other things, like PyYAML, we
    # don't want to emit misleading errors for legit dependencies issues if the
    # user hasn't installed PyYAML or other transitive dependencies from ssg.
    # We should revisit this if or when we decide to implement a python package
    # management strategy for the python scripts provided in this repository.
    if e.name == 'ssg':
        msg = """Unable to import local 'ssg' module.

The 'ssg' package from within this repository must be discoverable before
invoking this script. Make sure the top-level directory of the
ComplianceAsCode/content repository is available in the PYTHONPATH environment
variable (example: $ export PYTHONPATH=($pwd)).
HINT: $ source .pyenv.sh
"""
        raise RuntimeError(msg) from e
    raise


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
        print("Error:", e)
        print_options(ctrlmgr.policies.keys())
        exit(1)

    try:
        policy.get_level_with_ancestors_sequence(args.level)
    except ValueError as e:
        print("Error:", e)
        print_options(policy.levels_by_id.keys())
        exit(1)


def get_available_products():
    products_dir = os.path.join(SSG_ROOT, "products")
    try:
        return os.listdir(products_dir)
    except Exception as e:
        print(e)
        exit(1)


def validate_product(product):
    products = get_available_products()
    if product not in products:
        print(f"Error: Product '{product}' is not valid.")
        print_options(products)
        exit(1)


def get_product_dir(product):
    validate_product(product)
    return os.path.join(SSG_ROOT, "products", product)


def get_product_yaml(product):
    product_dir = get_product_dir(product)
    product_yml = os.path.join(product_dir, "product.yml")
    if os.path.exists(product_yml):
        return product_yml
    print(f"'{product_yml}' file was not found.")
    exit(1)


def get_formatted_name(text_name):
    for special_char in '-. ':
        text_name = text_name.replace(special_char, '_')
    return text_name


def count_implicit_status(ctrls, status_count):
    automated = status_count[controls.Status.AUTOMATED]
    documentation = status_count[controls.Status.DOCUMENTATION]
    inherently_met = status_count[controls.Status.INHERENTLY_MET]
    manual = status_count[controls.Status.MANUAL]
    not_applicable = status_count[controls.Status.NOT_APPLICABLE]
    pending = status_count[controls.Status.PENDING]

    status_count['all'] = len(ctrls)
    status_count['applicable'] = len(ctrls) - not_applicable
    status_count['assessed'] = status_count['applicable'] - pending
    status_count['not assessed'] = status_count['applicable'] - status_count['assessed']
    status_count['full coverage'] = automated + documentation + inherently_met + manual
    return status_count


def create_implicit_control_lists(ctrls, control_list):
    does_not_meet = control_list[controls.Status.DOES_NOT_MEET]
    not_applicable = control_list[controls.Status.NOT_APPLICABLE]
    partial = control_list[controls.Status.PARTIAL]
    pending = control_list[controls.Status.PENDING]
    planned = control_list[controls.Status.PLANNED]
    supported = control_list[controls.Status.SUPPORTED]

    control_list['all'] = ctrls
    control_list['applicable'] = ctrls - not_applicable
    control_list['assessed'] = control_list['applicable'] - pending
    control_list['not assessed'] = control_list['applicable'] - control_list['assessed']
    control_list['full coverage'] = ctrls - does_not_meet - not_applicable - partial\
        - pending - planned - supported
    return control_list


def count_controls_by_status(ctrls):
    status_count = collections.defaultdict(int)
    control_list = collections.defaultdict(set)

    for status in controls.Status.get_status_list():
        status_count[status] = 0

    for ctrl in ctrls:
        status_count[str(ctrl.status)] += 1
        control_list[str(ctrl.status)].add(ctrl)

    status_count = count_implicit_status(ctrls, status_count)
    control_list = create_implicit_control_lists(ctrls, control_list)

    return status_count, control_list


def print_specific_stat(status, current, total):
    if current > 0:
        print("{status:16} {current:6} / {total:3} = {percent:4}%".format(
            status=status,
            percent=round((current / total) * 100.00, 2),
            current=current,
            total=total))


def sort_controls_by_id(control_list):
    return sorted([(str(c.id), c.title) for c in control_list])


def print_controls(status_count, control_list, args):
    status = args.status
    if status not in status_count:
        print("Error: The informed status is not available")
        print_options(status_count)
        exit(1)

    if status_count[status] > 0:
        print("\nList of the {status} ({total}) controls:".format(
            total=status_count[status], status=status))

        for ctrl in sort_controls_by_id(control_list[status]):
            print("{id:>16} - {title}".format(id=ctrl[0], title=ctrl[1]))
    else:
        print("There is no controls with {status} status.".format(status=status))


def print_stats(status_count, control_list, args):
    implicit_status = controls.Status.get_status_list()
    explicit_status = status_count.keys() - implicit_status

    print("General stats:")
    for status in sorted(explicit_status):
        print_specific_stat(status, status_count[status], status_count['all'])

    print("\nStats grouped by status:")
    for status in sorted(implicit_status):
        print_specific_stat(status, status_count[status], status_count['applicable'])

    if args.show_controls:
        print_controls(status_count, control_list, args)


def print_stats_json(product, id, level, control_list):
    data = dict()
    data["format_version"] = "v0.0.3"
    data["product_name"] = product
    data["benchmark"] = dict()
    data["benchmark"]["name"] = id
    data["benchmark"]["baseline"] = level
    data["total_controls"] = len(control_list['applicable'])
    data["addressed_controls"] = dict()

    for status in sorted(control_list.keys()):
        json_key_name = get_formatted_name(status)
        data["addressed_controls"][json_key_name] = [
            sorted(str(c.id) for c in (control_list[status]))]
    print(json.dumps(data))


def stats(controls_manager, args):
    validate_args(controls_manager, args)
    ctrls = set(controls_manager.get_all_controls_of_level(args.id, args.level))
    total = len(ctrls)

    if total == 0:
        print("No controls founds with the given inputs. Maybe try another level.")
        exit(1)

    status_count, control_list = count_controls_by_status(ctrls)

    if args.output_format == 'json':
        print_stats_json(args.product, args.id, args.level, control_list)
    else:
        print_stats(status_count, control_list, args)


subcmds = dict(
    stats=stats
)


def parse_arguments():
    parser = argparse.ArgumentParser(
        description="Tool used to evaluate control files",
        epilog="Usage example: utils/controleval.py stats -i cis_rhel8 -l l2_server -p rhel8")
    parser.add_argument(
        '--controls-dir', default='./controls/', help=(
            "Directory that contains control files with policy controls. "
            "e.g.: ~/scap-security-guide/controls"))
    subparsers = parser.add_subparsers(dest='subcmd', required=True)

    stats_parser = subparsers.add_parser(
        'stats',
        help="calculate and return the statistics for the given benchmark")
    stats_parser.add_argument(
        '-i', '--id', required=True,
        help="the ID or name of the control file in the 'controls' directory")
    stats_parser.add_argument(
        '-l', '--level', required=True,
        help="the compliance target level to analyze")
    stats_parser.add_argument(
        '-o', '--output-format', choices=['json'],
        help="The output format of the result")
    stats_parser.add_argument(
        '-p', '--product',
        help="product to check has required references")
    stats_parser.add_argument(
        '--show-controls', action='store_true',
        help="list the controls and their respective status")
    stats_parser.add_argument(
        '-s', '--status', default='all',
        help="status used to filter the controls list output")
    return parser.parse_args()


def main():
    args = parse_arguments()
    product_yaml = get_product_yaml(args.product)
    env_yaml = ssg.products.load_product_yaml(product_yaml)
    controls_manager = controls.ControlsManager(
        args.controls_dir, env_yaml=env_yaml)
    controls_manager.load()
    subcmds[args.subcmd](controls_manager, args)


if __name__ == "__main__":
    main()
