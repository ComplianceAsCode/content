#!/usr/bin/python3
import argparse

from prometheus_client import CollectorRegistry, Gauge, generate_latest, write_to_textfile
from utils.controleval import (
    count_controls_by_status,
    get_controls_used_by_products,
    get_policy_levels,
    load_controls_manager
)

try:
    from ssg import controls
except ModuleNotFoundError as e:
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


def create_prometheus_policy_metric(
        unit: str, description: str, registry: CollectorRegistry) -> Gauge:
    metric = Gauge(unit, description, ['level', 'status'], registry=registry)
    return metric


def append_prometheus_policy_metric(
        metric: object, level: str, status: str, value: float) -> Gauge:
    metric.labels(level=level, status=status).set(value)
    return metric


def get_prometheus_metrics_registry(
        used_controls: list, ctrls_mgr: controls.ControlsManager) -> CollectorRegistry:
    registry = CollectorRegistry()
    for policy_id in sorted(used_controls):
        metric_id = f'policy_requirements_status_{policy_id}'
        metric_description = f'{policy_id} Requirements Status'
        metric = create_prometheus_policy_metric(metric_id, metric_description, registry=registry)
        for level in get_policy_levels(ctrls_mgr, policy_id):
            ctrls = set(ctrls_mgr.get_all_controls_of_level(policy_id, level))
            status_count, _ = count_controls_by_status(ctrls)
            for status in status_count.keys():
                metric = append_prometheus_policy_metric(
                    metric, level, status, status_count[status])
    return registry


def prometheus(args):
    ctrls_mgr = load_controls_manager(args.controls_dir, args.products[0])
    used_controls = get_controls_used_by_products(ctrls_mgr, args.products)
    registry = get_prometheus_metrics_registry(used_controls, ctrls_mgr)
    if args.output_file:
        write_to_textfile(args.output_file, registry)
    else:
        metrics = generate_latest(registry)
        print(metrics.decode('utf-8'))


subcmds = dict(
    prometheus=prometheus
)


def parse_arguments():
    parser = argparse.ArgumentParser(
        description="Tool used to evaluate control files",
        epilog="Usage example: utils/controleval.py prometheus -p rhel9")
    parser.add_argument(
        '--controls-dir', default='./controls/', help=(
            "Directory that contains control files with policy controls. "
            "e.g.: ~/scap-security-guide/controls"))
    subparsers = parser.add_subparsers(dest='subcmd', required=True)

    prometheus_parser = subparsers.add_parser(
        'prometheus',
        help="calculate and return benchmarks metrics in Prometheus format")
    prometheus_parser.add_argument(
        '-p', '--products', nargs='+', required=True,
        help="list of products to process the respective controls files")
    prometheus_parser.add_argument(
        '-f', '--output-file',
        help="save policy metrics in a file instead of showing in stdout")
    return parser.parse_args()


def main():
    args = parse_arguments()
    subcmds[args.subcmd](args)


if __name__ == "__main__":
    main()
