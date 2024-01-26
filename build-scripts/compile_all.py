from __future__ import print_function

import argparse
import os.path

import ssg.build_profile
import ssg.build_yaml
import ssg.utils
import ssg.controls
import ssg.products
import ssg.environment
from ssg.build_cpe import ProductCPEs
from ssg.constants import BENCHMARKS

def create_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--build-config-yaml", required=True,
        help="YAML file with information about the build configuration. "
        "e.g.: ~/scap-security-guide/build/build_config.yml "
        "needed for autodetection of profile root"
    )
    parser.add_argument(
        "--product-yaml", required=True,
        help="YAML file with information about the product we are building. "
        "e.g.: ~/scap-security-guide/products/rhel7/product.yml "
        "needed for autodetection of profile root"
    )
    parser.add_argument(
        "--resolved-base", required=True,
        help="To which directory to put processed rule/group/value YAMLs.")
    parser.add_argument(
        "--project-root",
        help="Path to the repository ie. project root "
        "e.g.: ~/scap-security-guide/",
    )
    parser.add_argument(
        "--sce-metadata",
        help="Combined SCE metadata to read."
    )
    parser.add_argument(
        "--stig-references", help="DISA STIG Reference XCCDF file"
    )
    return parser


def get_env_yaml(build_config_yaml, product_yaml):
    if build_config_yaml is None or product_yaml is None:
        return None

    env_yaml = ssg.environment.open_environment(build_config_yaml, product_yaml)
    return env_yaml


def get_all_content_directories(env_yaml, product_yaml):
    relative_benchmark_root = ssg.utils.required_key(env_yaml, "benchmark_root")
    benchmark_root = os.path.join(product_yaml["product_dir"], relative_benchmark_root)

    add_content_dirs = get_additional_content_directories(env_yaml)
    return [benchmark_root] + add_content_dirs


def get_additional_content_directories(env_yaml):
    # we assume that the project root is one directory above build-scripts
    project_root = os.path.dirname(os.path.dirname(__file__))
    additional_content_directories = env_yaml.get("additional_content_directories", [])

    absolute_additional_content_dirs = []
    for dirname in additional_content_directories:
        if not os.path.isabs(dirname):
            dirname = os.path.join(project_root, dirname)
        absolute_additional_content_dirs.append(dirname)
    return absolute_additional_content_dirs


def load_benchmark_source_data_from_directory_tree(loader, env_yaml, product_yaml):
    relevant_benchmark_sources = get_all_content_directories(env_yaml, product_yaml)
    loader.process_directory_trees(relevant_benchmark_sources)


def dump_compiled_profile(base_dir, profile):
    dest = os.path.join(base_dir, "profiles", "{name}.profile".format(name=profile.id_))
    profile.dump_yaml(dest)


def get_all_resolved_profiles_by_id(
        env_yaml, product_yaml, loader, product_cpes, controls_manager, controls_dir=None):
    profile_files = ssg.products.get_profile_files_from_root(env_yaml, product_yaml)
    profiles_by_id = load_resolve_and_validate_profiles(
        env_yaml, profile_files, loader, controls_manager, product_cpes)
    return profiles_by_id


def load_resolve_and_validate_profiles(env_yaml, profile_files, loader, controls_manager, product_cpes):
    profiles_by_id = ssg.build_profile.make_name_to_profile_mapping(profile_files, env_yaml, product_cpes)

    for p in profiles_by_id.values():
        p.resolve(profiles_by_id, loader.all_rules, controls_manager)

        p.validate_variables(loader.all_values.values())
        p.validate_rules(loader.all_rules.values(), loader.all_groups.values())
        p.validate_refine_rules(loader.all_rules.values())
    return profiles_by_id


def save_everything(base_dir, loader, controls_manager, profiles):
    controls_manager.save_everything(os.path.join(base_dir, "controls"))
    loader.save_all_entities(base_dir)
    for p in profiles:
        dump_compiled_profile(base_dir, p)


def find_existing_rules(project_root):
    rules = set()
    for benchmark in BENCHMARKS:
        benchmark = os.path.join(project_root, benchmark)
        for dirpath, _, filenames in os.walk(benchmark):
            if "rule.yml" in filenames:
                rule_id = os.path.basename(dirpath)
                rules.add(rule_id)
    return rules


def main():
    parser = create_parser()
    args = parser.parse_args()

    project_root_abspath = os.path.abspath(args.project_root)

    env_yaml = get_env_yaml(args.build_config_yaml, args.product_yaml)
    product_yaml = ssg.products.Product(args.product_yaml)

    product_cpes = ProductCPEs()
    product_cpes.load_product_cpes(env_yaml)

    # Rules in the same benchmark_root might have a product CPE set as
    # a platform and could be shared between all the products.
    # TODO: This is a hackish feature of 'ocp4' and 'eks' products
    #       we should fix that as it brings implicit dependency between
    #       products with shared guide directory
    for extra_product_yaml in ssg.products.get_all_products_with_same_guide_directory(
                                           project_root_abspath, product_yaml):
        product_cpes.load_cpes_from_list(extra_product_yaml.get("cpes", []))
    product_cpes.load_content_cpes(env_yaml)

    loader = ssg.build_yaml.BuildLoader(
        None, env_yaml, product_cpes, args.sce_metadata, args.stig_references)
    loader.load_components()
    load_benchmark_source_data_from_directory_tree(loader, env_yaml, product_yaml)

    controls_dir = os.path.join(project_root_abspath, "controls")

    existing_rules = find_existing_rules(project_root_abspath)

    controls_manager = ssg.controls.ControlsManager(
        controls_dir, env_yaml, existing_rules)
    controls_manager.load()
    controls_manager.remove_selections_not_known(loader.all_rules)

    profiles_by_id = get_all_resolved_profiles_by_id(
        env_yaml, product_yaml, loader, product_cpes, controls_manager, controls_dir)

    save_everything(
        args.resolved_base, loader, controls_manager, profiles_by_id.values())


if __name__ == "__main__":
    main()
