#!/usr/bin/env python

import sys
import os
import argparse
import json

import ssg.build_yaml
import ssg.products
import ssg.rules
import ssg.yaml
import ssg.utils
import ssg.rule_yaml

from refchecker import load_for_product

SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
SECTION_KEY_FUNC = ssg.rule_yaml.add_or_modify_nested_section_key


"""
Nicely laid out profiles have a structure matching their corresponding
benchmarks. I'm thinking the CIS and STIG profiles here.

Let's formalize that structure a bit.

Given a profile with format:

```yaml
    selection:
        # <identifier> description
        - rule_choice
```

Where one or more comments precede one or more rules, and the closest
comment that matches the given format for a reference identifier wins.

Let's take this as an example:

```yaml
    ## 5.3 Configure PAM ##
    ### 5.3.1 Ensure password creation requirements are configured (Automated)
    - var_password_pam_minlen=14
    - accounts_password_pam_minlen
    - var_password_pam_minclass=4
    - accounts_password_pam_minclass
```

Here both accounts_password_pam_minlen and
accounts_password_pam_minclass should get CIS reference value 5.3.1. The
other two entries are vars, and since 5.3 is further away than 5.3.1,
5.3.1 should win.

Some ground rules:

 - We should avoid guessing when possible.
 - We should create minimal diffs.
 - Some rules lack a references section; we should add them in that
   case.
 - If we're not sure, ignore the rule and print info telling the caller
   about it.
 - Rules that don't belong to a section shouldn't be in the profile!
 - If we're adding a reference, don't clutter other products! Only do
   our current product.
"""


def parse_args():
    parser = argparse.ArgumentParser(description="Utility to parse a given profile and "
                                     "automatically add or update a given reference "
                                     "in all included rules")
    parser.add_argument("-j", "--json", type=str, action="store",
                        default="build/rule_dirs.json", help="File to read "
                        "json output of rule_dir_json from (defaults to "
                        "build/rule_dirs.json")
    parser.add_argument("-c", "--build-config-yaml", default="build/build_config.yml",
                        help="YAML file with information about the build configuration. "
                        "Defaults to build/build_config.yml")
    parser.add_argument("-p", "--profiles-root",
                        help="Override where to look for profile files.")
    parser.add_argument("product", type=str, help="Product to check has required references")
    parser.add_argument("profile", type=str, help="Profile to iterate over")
    parser.add_argument("reference", type=str,
                        help="Required reference system to automatically add")

    return parser.parse_args()


def find_value_line(lines, value):
    # Hack: within the lines in a file, return the line number matching
    # the given value. We assume a "nice" file.

    matches = []
    for index, line in enumerate(lines):
        no_trailing_comment = line.split('#', 1)[0].strip()
        if no_trailing_comment.endswith(value):
            matches.append(index)
        if no_trailing_comment.endswith(value + '"'):
            matches.append(index)
        if no_trailing_comment.endswith(value + "'"):
            matches.append(index)

    if len(matches) > 1 or not matches:
        msg = "While searching for pattern `{0}` in file lines, got no or "
        msg += "several matches: {1}"
        msg = msg.format(value, matches)
        raise ValueError(msg)

    return matches[0]


def is_reference_identifier_comment(line, reference):
    stripped = line.strip()
    if not stripped.startswith('#'):
        return False, None

    # Sometimes we add lots of nested comment symbols to show depth of a
    # section. Handle that nicely.
    no_comment_symbol = stripped[1:].strip()
    while no_comment_symbol.startswith('#'):
        no_comment_symbol = no_comment_symbol[1:].strip()

    # Assume the initial token now is the reference identifier's value.
    ref_identifier = no_comment_symbol.split(' ', 1)[0].strip()

    # Try and validate our identifier based on what reference system we have.
    # Currently the only one we know of is CIS.
    if reference == 'cis':
        valid_id = '.' in ref_identifier and not ref_identifier.lower().islower()
        if ref_identifier.endswith('.'):
            # We might've copied an extra period after our reference identifier;
            # handle trimming it nicely.
            ref_identifier = ref_identifier[:-1]
        if valid_id:
            return True, ref_identifier
        return False, None

    return False, ref_identifier


def reference_add(env_yaml, rule_dirs, profile_path, product, reference):
    profile = ssg.build_yaml.ProfileWithInlinePolicies.from_yaml(profile_path, env_yaml)
    profile_lines = ssg.utils.read_file_list(profile_path)

    updated = False
    for rule_id in profile.selected + profile.unselected:
        if rule_id not in rule_dirs:
            msg = "Unable to find rule in rule_dirs.json: {0}"
            msg = msg.format(rule_id)
            raise ValueError(msg)

        rule_obj = rule_dirs[rule_id]
        rule = load_for_product(rule_obj, product, env_yaml=env_yaml)

        # Now we're attempting to parse the profile file and see if we can't
        # determine the correct reference identifier to add.
        rule_line_num = find_value_line(profile_lines, rule_id)

        # Maximum delta (inclusive) to search from the current point to find a
        # matching reference identifier. This is from experimental evidence (see
        # the accounts_password_pam_retry rule).
        MAX_DELTA = 20
        ref_id = None

        for delta in range(1, MAX_DELTA+1):
            abs_line_num = rule_line_num - delta
            line = profile_lines[abs_line_num]

            # Only use this reference if we're absolutely sure.
            valid, ref_id = is_reference_identifier_comment(line, reference)
            if not valid and ref_id:
                msg = "Got suspected reference identifier {0} on line {1}, but due to "
                msg += "unknown reference system {2}, cannot confirm. Refusing to add."
                msg = msg.format(ref_id, abs_line_num, reference)
                print(msg, file=sys.stderr)
                ref_id = None
                break
            if valid and ref_id:
                break

        if not ref_id:
            msg = "Unknown reference identifier for rule {0}; ignoring."
            msg = msg.format(rule_id)
            print(msg, file=sys.stderr)
            continue

        # Now we definitely have a reference identifier. We have three cases:
        #
        #  1. Our reference identifier is correct; don't need to do anything.
        #  2. We need to update our reference identifier; it was wrong in the rule.yml.
        #  3. We don't have a reference identifier in the rule.yml and we need to add one.

        if reference in rule.references and rule.references[reference] == ref_id:
            print("ok", rule_id, ref_id)
            continue

        # Load the 'raw' rule.yml file and get the lines corresponding with the references
        # section.
        rule_path, rule_lines = ssg.rule_yaml.get_yaml_contents(rule_obj)

        # Here, we make a judgement call. If we're modifying a product reference,
        # only add a product-qualified value.
        reference_key = reference
        if reference in ssg.build_yaml.Rule.PRODUCT_REFERENCES:
            reference_key += "@" + product

        # Lastly, some post-processing magic. When we have a CIS identifier with only a
        # single period, it is going to get picked up as a float, so quote it.
        if reference == 'cis' and ref_id.count('.') == 1:
            ref_id = "'" + ref_id + "'"

        print("Updating " + rule_id + " to include " + reference_key + ": " + ref_id)

        new_lines = SECTION_KEY_FUNC(rule_path, rule_lines, 'references', reference_key,
                                     ref_id, new_section_after_if_missing='identifiers')

        if new_lines != rule_lines:
            ssg.utils.write_list_file(rule_path, new_lines)
            updated = True

    return updated


def main():
    args = parse_args()

    json_file = open(args.json, 'r')
    all_rules = json.load(json_file)

    linux_products, other_products = ssg.products.get_all(SSG_ROOT)
    all_products = linux_products.union(other_products)
    if args.product not in all_products:
        msg = "Unknown product {0}: check SSG_ROOT and try again"
        msg = msg.format(args.product)
        raise ValueError(msg)

    product_base = os.path.join(SSG_ROOT, args.product)
    product_yaml = os.path.join(product_base, "product.yml")
    env_yaml = ssg.yaml.open_environment(args.build_config_yaml, product_yaml)

    profiles_root = os.path.join(product_base, "profiles")
    if args.profiles_root:
        profiles_root = args.profiles_root

    profile_filename = args.profile + ".profile"
    profile_path = os.path.join(profiles_root, profile_filename)
    if not os.path.exists(profile_path):
        msg = "Unknown profile {0}: check profile, --profiles-root, and try again"
        msg = msg.format(args.profile)
        raise ValueError(msg)

    updated = reference_add(env_yaml, all_rules, profile_path, args.product, args.reference)
    if updated:
        print("One or more rules were modified to add missing references.", file=sys.stderr)


if __name__ == "__main__":
    main()
