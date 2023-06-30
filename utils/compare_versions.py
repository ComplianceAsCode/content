#!/usr/bin/python3

import argparse
import json
import os
import subprocess
import tempfile


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="""
        Show differences between two ComplianceAsCode versions.
        Lists added or removed rules, profiles, changes in profile composition
        and changes in remediations and platforms.
        For comparison, you can use git tags or ComplianceAsCode JSON manifest
        files directly.
        """)
    subparsers = parser.add_subparsers()
    parser_compare_manifests = subparsers.add_parser("compare_manifests")
    parser_compare_manifests.set_defaults(func=compare_manifests)
    parser_compare_manifests.add_argument(
        "manifest1", help="Path to a ComplianceAsCode JSON manifest file")
    parser_compare_manifests.add_argument(
        "manifest2", help="Path to a ComplianceAsCode JSON manifest file")
    parser_compare_tags = subparsers.add_parser("compare_tags")
    parser_compare_tags.set_defaults(func=compare_tags)
    parser_compare_tags.add_argument("tag1", help="git tag, eg. v0.1.67")
    parser_compare_tags.add_argument("tag2", help="git tag, eg. v0.1.68")
    parser_compare_tags.add_argument(
        "product", help="product ID, eg. 'rhel9'")
    return parser.parse_args()


def load_manifest(file_path: str) -> dict:
    with open(file_path) as f:
        manifest = json.load(f)
    return manifest


def print_set(elements: set) -> None:
    for element in sorted(list(elements)):
        print(" - " + element)


def compare_sets(set1: set, set2: set) -> tuple:
    added = set2 - set1
    removed = set1 - set2
    return added, removed


def print_diff(added: set, removed: set, title: str, name: str) -> None:
    if not added and not removed:
        return
    print(title)
    if added:
        print(f"The following {name} were added:")
        print_set(added)
    if removed:
        print(f"The following {name} were removed:")
        print_set(removed)
    print()


class ManifestComparator():
    def __init__(self, manifest1_path: str, manifest2_path: str) -> None:
        self.manifest1 = load_manifest(manifest1_path)
        self.manifest2 = load_manifest(manifest2_path)
        pass

    def compare_products(self) -> None:
        product_name1 = self.manifest1["product_name"]
        product_name2 = self.manifest2["product_name"]
        if product_name1 != product_name2:
            print("Product names differ")

    def compare_rules(self) -> None:
        rules1 = set(self.manifest1["rules"].keys())
        rules2 = set(self.manifest2["rules"].keys())
        added, removed = compare_sets(rules1, rules2)
        print_diff(added, removed, "Rules in benchmark:", "rules")

    def _get_reports(self, rules: list) -> list:
        rule_reports = []
        for rule_id in rules:
            rule1 = self.manifest1["rules"][rule_id]
            rule2 = self.manifest2["rules"][rule_id]
            content1 = set(rule1["content"])
            platforms1 = set(rule1["platform_names"])
            content2 = set(rule2["content"])
            platforms2 = set(rule2["platform_names"])
            content_added, content_removed = compare_sets(content1, content2)
            platforms_added, platforms_removed = compare_sets(
                platforms1, platforms2)
            if (content_added or content_removed or platforms_added
                    or platforms_removed):
                msgs = []
                if content_added:
                    msgs.append("adds " + ", ".join(content_added))
                if content_removed:
                    msgs.append("removes " + ", ".join(content_removed))
                if platforms_added:
                    msgs.append("adds platform " + ", ".join(platforms_added))
                if platforms_removed:
                    msgs.append(
                        "removes platform " + ", ".join(platforms_removed))
                rule_report = "Rule " + rule_id + " " + ", ".join(msgs) + "."
                rule_reports.append(rule_report)
        return rule_reports

    def compare_rule_details(self) -> None:
        rules1 = set(self.manifest1["rules"].keys())
        rules2 = set(self.manifest2["rules"].keys())
        rules_intersection = sorted(rules1 & rules2)
        rule_reports = self._get_reports(rules_intersection)
        if len(rule_reports) > 0:
            print("Differences in rules:")
            for report in rule_reports:
                print(" - " + report)
            print()

    def compare_profiles(self) -> None:
        profiles1 = set(self.manifest1["profiles"].keys())
        profiles2 = set(self.manifest2["profiles"].keys())
        added, removed = compare_sets(profiles1, profiles2)
        print_diff(added, removed, "Profiles in benchmark:", "profiles")
        profiles_intersection = sorted(profiles1 & profiles2)
        for profile_id in profiles_intersection:
            rules1 = set(self.manifest1["profiles"][profile_id]["rules"])
            rules2 = set(self.manifest2["profiles"][profile_id]["rules"])
            rules_added, rules_removed = compare_sets(rules1, rules2)
            values1 = set(self.manifest1["profiles"][profile_id]["values"])
            values2 = set(self.manifest2["profiles"][profile_id]["values"])
            values_added, values_removed = compare_sets(values1, values2)
            if rules_added or rules_removed or values_added or values_removed:
                print(f"Profile {profile_id} differs:")
                if rules_added:
                    print(f"The following rules were added:")
                    print_set(rules_added)
                if rules_removed:
                    print(f"The following rules were removed:")
                    print_set(rules_removed)
                if values_added:
                    print(f"The following values were added:")
                    print_set(values_added)
                if values_removed:
                    print(f"The following values were removed:")
                    print_set(values_removed)
                print()


    def compare(self) -> None:
        self.compare_products()
        self.compare_rules()
        self.compare_rule_details()
        self.compare_profiles()


def compare_manifests(args: argparse.Namespace) -> None:
    comparator = ManifestComparator(args.manifest1, args.manifest2)
    comparator.compare()


def clone_git(tag: str, target_directory_path: str) -> None:
    cac_uri = "https://github.com/ComplianceAsCode/content.git"
    cmd = ["git", "clone", cac_uri, "-b", tag, target_directory_path]
    subprocess.run(cmd, check=True, capture_output=True)


def build_product(cac_root: str, product: str) -> None:
    cmd = ["./build_product", product]
    subprocess.run(cmd, cwd=cac_root, check=True, capture_output=True)


def generate_manifest(build_root: str, manifest_file_path: str) -> None:
    cmd = [
        "python3", "build-scripts/generate_manifest.py",
        "--build-root", build_root, "--output", manifest_file_path]
    subprocess.run(cmd, check=True, capture_output=True)


def prepare(tmpdirname: str, tag: str, product: str) -> str:
    git_dir_path = os.path.join(tmpdirname, tag)
    clone_git(tag, git_dir_path)
    build_product(git_dir_path, product)
    build_dir_path = os.path.join(git_dir_path, "build", product)
    manifest_file_path = os.path.join(tmpdirname, tag + ".manifest.json")
    generate_manifest(build_dir_path, manifest_file_path)
    return manifest_file_path


def compare_tags(args: argparse.Namespace) -> None:
    with tempfile.TemporaryDirectory() as tmpdirname:
        manifest1 = prepare(tmpdirname, args.tag1, args.product)
        manifest2 = prepare(tmpdirname, args.tag2, args.product)
        comparator = ManifestComparator(manifest1, manifest2)
        comparator.compare()


def main() -> None:
    args = parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
