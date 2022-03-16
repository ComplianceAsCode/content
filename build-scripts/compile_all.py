from __future__ import print_function

import argparse
import logging
import sys
import os.path
from glob import glob

import ssg.build_profile
import ssg.build_yaml
import ssg.utils
import ssg.controls
import ssg.products
import ssg.environment
from ssg.build_cpe import ProductCPEs

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
        "--controls-dir",
        help="Directory that contains control files with policy controls. "
        "e.g.: ~/scap-security-guide/controls",
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
    benchmark_root = os.path.join(os.path.dirname(product_yaml), relative_benchmark_root)

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


def get_all_resolved_profiles_by_id(env_yaml, product_yaml, loader, product_cpes, controls_dir=None):
    controls_manager = None
    if controls_dir:
        controls_manager = ssg.controls.ControlsManager(controls_dir, env_yaml)
        controls_manager.load()

    profile_files = ssg.products.get_profile_files_from_root(env_yaml, product_yaml)
    profiles_by_id = load_resolve_and_validate_profiles(env_yaml, profile_files, loader, controls_manager, product_cpes)
    return profiles_by_id


def load_resolve_and_validate_profiles(env_yaml, profile_files, loader, controls_manager, product_cpes):
    profiles_by_id = ssg.build_profile.make_name_to_profile_mapping(profile_files, env_yaml, product_cpes)

    for p in profiles_by_id.values():
        p.resolve(profiles_by_id, loader.all_rules, controls_manager)

        p.validate_variables(loader.all_values.values())
        p.validate_rules(loader.all_rules.values(), loader.all_groups.values())
        p.validate_refine_rules(loader.all_rules.values())
    return profiles_by_id


def save_everything(base_dir, loader, profiles):
    loader.save_all_entities(base_dir)
    for p in profiles:
        dump_compiled_profile(base_dir, p)


def main():
    parser = create_parser()
    args = parser.parse_args()

    env_yaml = get_env_yaml(args.build_config_yaml, args.product_yaml)
    product_cpes = ProductCPEs()
    product_cpes.load_product_cpes(env_yaml)
    product_cpes.load_content_cpes(env_yaml)

    build_root = os.path.dirname(args.build_config_yaml)

    logfile = "{build_root}/{product}/control_profiles.log".format(
            build_root=build_root,
            product=env_yaml["product"])
    logging.basicConfig(filename=logfile, level=logging.INFO)

    loader = ssg.build_yaml.BuildLoader(
        None, env_yaml, product_cpes, args.sce_metadata, args.stig_references)
    load_benchmark_source_data_from_directory_tree(loader, env_yaml, args.product_yaml)

    profiles_by_id = get_all_resolved_profiles_by_id(env_yaml, args.product_yaml, loader, product_cpes, args.controls_dir)

    save_everything(args.resolved_base, loader, profiles_by_id.values())


if __name__ == "__main__":
    main()
