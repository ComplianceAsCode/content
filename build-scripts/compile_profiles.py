from __future__ import print_function

import argparse
import sys
import os.path
from glob import glob

import ssg.build_yaml


class ResolvableProfile(ssg.build_yaml.Profile):
    def __init__(self, * args, ** kwargs):
        super(ResolvableProfile, self).__init__(* args, ** kwargs)
        self.raw_selections = set()
        self.resolved = False

    def resolve(self, all_profiles):
        if self.resolved:
            return
        if self.extends:
            if self.extends not in all_profiles:
                msg = (
                    "Profile {name} extends profile {extended}, but"
                    "only profiles {known_profiles} are available for resolution."
                    .format(name=self.id_, extended=self.extends,
                            profiles=list(all_profiles.keys())))
                raise RuntimeError(msg)
            extended_profile = all_profiles[self.extends]
            extended_profile.resolve(all_profiles)

            extended_selects = extended_profile.raw_selections
            self.raw_selections.update(extended_selects)

            updated_variables = dict(extended_profile.variables)
            updated_variables.update(self.variables)
            self.variables = updated_variables

            updated_refinements = dict(extended_profile.refine_rules)
            updated_refinements.update(self.refine_rules)
            self.refine_rules = updated_refinements

        self.raw_selections.update(set(self.selected))
        for uns in self.unselected:
            self.raw_selections.discard(uns)

        self.resolved = True


def create_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument("profile_file", nargs="*")
    parser.add_argument(
        "--build-config-yaml",
        help="YAML file with information about the build configuration. "
        "e.g.: ~/scap-security-guide/build/build_config.yml "
        "needed for autodetection of profile root"
    )
    parser.add_argument(
        "--product-yaml",
        help="YAML file with information about the product we are building. "
        "e.g.: ~/scap-security-guide/rhel7/product.yml "
        "needed for autodetection of profile root"
    )
    parser.add_argument(
        "--output", "-o", default="{name}.profile",
        help="The template for saving processed profile files."
    )
    return parser


def make_name_to_profile_mapping(profile_files):
    name_to_profile = {}
    for f in profile_files:
        try:
            p = ResolvableProfile.from_yaml(f)
            name_to_profile[p.id_] = p
        except Exception as exc:
            # The profile is probably doc-incomplete
            msg = "Not building profile from {fname}: {err}".format(
                fname=f, err=str(exc))
            print(msg, file=sys.stderr)
    return name_to_profile


def get_env_yaml(build_config_yaml, product_yaml):
    if build_config_yaml is None or product_yaml is None:
        return None

    env_yaml = ssg.yaml.open_environment(build_config_yaml, product_yaml)
    return env_yaml


def get_profile_files_from_root(env_yaml, product_yaml):
    profile_files = []
    if env_yaml:
        base_dir = os.path.dirname(product_yaml)
        profiles_root = ssg.utils.required_key(env_yaml, "profiles_root")
        profile_files = glob("{base_dir}/{profiles_root}/*.profile"
                             .format(profiles_root=profiles_root, base_dir=base_dir))
    return profile_files


def main():
    parser = create_parser()
    args = parser.parse_args()
    env_yaml = get_env_yaml(args.build_config_yaml, args.product_yaml)

    profile_files = get_profile_files_from_root(env_yaml, args.product_yaml)
    profile_files.extend(args.profile_file)
    profiles = make_name_to_profile_mapping(profile_files)
    for pname in profiles:
        profiles[pname].resolve(profiles)

    for name, p in profiles.items():
        p.selected = sorted(list(p.raw_selections))
        p.unselected = []
        p.dump_yaml(args.output.format(name=name))


if __name__ == "__main__":
    main()
