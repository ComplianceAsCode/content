#!/usr/bin/env python3
"""Bundle individual CEL rule and profile YAML files into a single content file.

This is the Python equivalent of the Go cel-bundler in the compliance-operator
repository (cmd/cel-bundler + pkg/celcontent). It reads individual rule and
profile YAML files, validates them, and produces a single bundle YAML that
the compliance-operator parser consumes via ProfileBundle.celContentFile.
"""

import argparse
import os
import sys

import yaml


# -- YAML key ordering --------------------------------------------------------
# The Go bundler (sigs.k8s.io/yaml) emits map keys in alphabetical order.
# We replicate that so the output is byte-for-byte comparable.

_RULE_KEY_ORDER = [
    "checkType", "controls", "description", "expression", "failureReason",
    "id", "inputs", "instructions", "name", "rationale", "severity", "title",
    "variables",
]

_PROFILE_KEY_ORDER = [
    "description", "id", "name", "productName", "productType", "rules",
    "title", "values", "version",
]


def _ordered_rule_dict(rule):
    """Return an OrderedDict-style list of tuples with alphabetical keys."""
    return {k: rule[k] for k in _RULE_KEY_ORDER if k in rule}


def _ordered_profile_dict(profile):
    return {k: profile[k] for k in _PROFILE_KEY_ORDER if k in profile}


# -- Loading helpers -----------------------------------------------------------

def _list_yaml_files(directory):
    """Return sorted list of .yaml/.yml file paths in *directory*."""
    entries = sorted(os.listdir(directory))
    result = []
    for name in entries:
        if os.path.isdir(os.path.join(directory, name)):
            continue
        ext = os.path.splitext(name)[1].lower()
        if ext in (".yaml", ".yml"):
            result.append(os.path.join(directory, name))
    return result


def _load_rules(rules_dir):
    rules = []
    for path in _list_yaml_files(rules_dir):
        with open(path, "r") as fh:
            data = yaml.safe_load(fh)
        if not data:
            raise ValueError(f"empty or invalid YAML in {path}")
        if not data.get("name"):
            raise ValueError(f"rule in {path} has no name")
        if not data.get("expression"):
            raise ValueError(
                f"rule {data['name']!r} in {path} has no expression"
            )
        if not data.get("inputs"):
            raise ValueError(
                f"rule {data['name']!r} in {path} has no inputs"
            )
        rules.append(data)
    rules.sort(key=lambda r: r["name"])
    return rules


def _load_profiles(profiles_dir):
    profiles = []
    for path in _list_yaml_files(profiles_dir):
        with open(path, "r") as fh:
            data = yaml.safe_load(fh)
        if not data:
            raise ValueError(f"empty or invalid YAML in {path}")
        if not data.get("name"):
            raise ValueError(f"profile in {path} has no name")
        if not data.get("rules"):
            raise ValueError(
                f"profile {data['name']!r} in {path} has no rules"
            )
        profiles.append(data)
    profiles.sort(key=lambda p: p["name"])
    return profiles


# -- Public API ----------------------------------------------------------------

def bundle_from_dirs(rules_dir, profiles_dir):
    """Load, validate, and return a bundle dict with *rules* and *profiles*."""
    rules = _load_rules(rules_dir)
    profiles = _load_profiles(profiles_dir)

    rule_names = set()
    for r in rules:
        if r["name"] in rule_names:
            raise ValueError(f"duplicate rule name: {r['name']}")
        rule_names.add(r["name"])

    for p in profiles:
        for rule_ref in p["rules"]:
            if rule_ref not in rule_names:
                raise ValueError(
                    f"profile {p['name']!r} references unknown rule {rule_ref!r}"
                )

    return {
        "rules": rules,
        "profiles": profiles,
    }


def bundle_to_yaml(bundle):
    """Serialize a bundle dict to a YAML string with sorted keys."""
    ordered = {
        "profiles": [_ordered_profile_dict(p) for p in bundle["profiles"]],
        "rules": [_ordered_rule_dict(r) for r in bundle["rules"]],
    }
    return yaml.dump(ordered, default_flow_style=False, sort_keys=True)


def bundle_to_file(rules_dir, profiles_dir, output_path):
    """Load rules/profiles, validate, and write the bundle YAML to a file."""
    bundle = bundle_from_dirs(rules_dir, profiles_dir)
    content = bundle_to_yaml(bundle)
    with open(output_path, "w") as fh:
        fh.write(content)


# -- CLI -----------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Bundle CEL rules and profiles into a single YAML file."
    )
    parser.add_argument(
        "--rules", required=True, help="Path to the CEL rules directory"
    )
    parser.add_argument(
        "--profiles", required=True, help="Path to the CEL profiles directory"
    )
    parser.add_argument(
        "--output", required=True, help="Output path for the bundled YAML file"
    )
    args = parser.parse_args()

    try:
        bundle_to_file(args.rules, args.profiles, args.output)
    except Exception as exc:
        print(f"Error: {exc}", file=sys.stderr)
        sys.exit(1)

    print(f"Generated {args.output}")


if __name__ == "__main__":
    main()
