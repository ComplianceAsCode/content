#!/usr/bin/python3

import os
import argparse

import ssg.rules
import ssg.utils
import ssg.products
import ssg.rule_yaml
import ssg.build_yaml
import ssg.build_profile
import ssg.entities.profile_base
import ssg.controls
import ssg.build_cpe
import ssg.yaml

SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
GUIDE_RULES = {}


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("-p", "--product", type=str, action="store",
                        help="Product (defaults to all if not set)")
    return parser.parse_args()


def collect_rule_ids_and_dirs(rules_dir):
    for rule_dir in sorted(ssg.rules.find_rule_dirs(rules_dir)):
        yield ssg.rules.get_rule_dir_id(rule_dir), rule_dir


def handle_rule_yaml(env, rule_dir):
    rule_file = ssg.rules.get_rule_dir_yaml(rule_dir)
    rule_yaml = ssg.build_yaml.Rule.from_yaml(rule_file, env)
    return rule_file, rule_yaml


def get_rules(product, product_path, env):
    guide_path = os.path.abspath(os.path.join(product_path, product['benchmark_root']))
    if guide_path not in GUIDE_RULES:
        print(f"Loading rules from '{guide_path}'...", end=""),
        GUIDE_RULES[guide_path] = {}
        for rule_id, rule_dir in collect_rule_ids_and_dirs(guide_path):
            try:
                rule_file, rule_yaml = handle_rule_yaml(env, rule_dir)
                GUIDE_RULES[guide_path][rule_yaml.id_] = rule_yaml
            except ssg.yaml.DocumentationNotComplete:
                # Happens on non-debug build when a rule is "documentation-incomplete"
                continue
        print(len(GUIDE_RULES[guide_path]))
    return GUIDE_RULES[guide_path]


def get_products_and_rules(root_path):
    linux_products, other_products = ssg.products.get_all(root_path)
    all_products = linux_products.union(other_products)
    for product_id in all_products:
        product_path = ssg.products.product_yaml_path(root_path, product_id)
        product_props_path = os.path.join(root_path, "product_properties")
        product = ssg.products.load_product_yaml(product_path)
        product.read_properties_from_directory(product_props_path)
        env = dict(product)
        rules = get_rules(product, os.path.join(root_path, "products", product_id), env)
        yield product_id, product, env, rules


def unselect_rules_in_profile(product, profile, profile_path, prof_unsel):
    if len(prof_unsel) == 0:
        return

    comment = f"# Following rules once had a prodtype incompatible with the {product['product']} product"
    with open(profile_path, 'r') as f:
        lines = f.readlines()
    comment_line = 0
    indent = 0
    sel_start = 0
    sel_end = 0
    already_unselected = []
    for i, line in enumerate(lines):
        strip_line = line.strip()
        if strip_line.startswith("- '!") or strip_line.startswith('- "!'):
            already_unselected.append(strip_line[4:-1])
            continue
        if comment in line:
            comment_line = i
            continue
        if strip_line.startswith("#") or not strip_line.strip():
            continue
        if line.startswith("selections:"):
            sel_start = i
            sel_end = len(lines) - 1
            continue
        if sel_start != 0:
            if not strip_line.startswith("-"):
                sel_end = i - 1
            elif indent == 0:
                indent = line.find("-")

    for unsel in prof_unsel:
        if unsel in already_unselected:
            continue
        lines.insert(sel_end+1, f"{indent * ' '}- '!{unsel}'\n")
    if comment_line == 0:
        lines.insert(sel_end+1, f"{indent * ' '}{comment}\n")

    with open(profile_path, 'w') as f:
        f.writelines(lines)


def select_rules_in_default_profile(product, profiles_root, prof_def_sel):
    if len(prof_def_sel) == 0:
        return

    prefix = (f"documentation_complete: true\n"
              f"\n"
              f"hidden: true\n"
              f"\n"
              f"title: Default Profile for {product['full_name']}\n"
              f"\n"
              f"description: |-\n"
              f"    This profile contains all the rules that once belonged to the\n"
              f"    {product['product']} product via 'prodtype'. This profile won't\n"
              f"    be rendered into an XCCDF Profile entity, nor it will select any\n"
              f"    of these rules by default. The only purpose of this profile\n"
              f"    is to keep a rule in the product's XCCDF Benchmark.\n"
              f"\n"
              f"selections:\n")

    path = os.path.join(SSG_ROOT, "products", product['product'], profiles_root)
    with open(f"{path}/default.profile", "w") as f:
        f.write(prefix)
        for sel in prof_def_sel:
            f.write(f"    - {sel}\n")


def main():
    args = parse_args()
    for product_id, product, env, all_rules in get_products_and_rules(SSG_ROOT):
        if args.product:
            if product_id != args.product:
                continue
        print(f"Product '{product_id}', profiles:")

        product_cpes = ssg.build_cpe.ProductCPEs()
        product_cpes.load_product_cpes(env)

        controls_path = os.path.join(SSG_ROOT, "controls")
        controls_manager = ssg.controls.ControlsManager(controls_path, env)
        controls_manager.load()

        profile_paths = ssg.products.get_profile_files_from_root(env, product)
        all_sels = set()
        for profile_path in profile_paths:
            try:
                profile = ssg.build_yaml.ProfileWithInlinePolicies.from_yaml(profile_path, env, product_cpes)
            except ssg.yaml.DocumentationNotComplete:
                continue
            if profile.id_ == 'default':
                # Whatever is there — we are going to overwrite it
                continue
            profile.resolve_controls(controls_manager)
            sels = sorted(profile.selected)
            unsels = sorted(profile.unselected)
            extends = profile.extends if profile.extends else "no"
            print(f"  {profile.id_} (extends: {extends}, selections: {len(sels)}/{len(unsels)})", end="")
            prof_unsel = set()
            for sel in sels:
                if sel in all_rules:
                    if all_rules[sel].prodtype == '' or all_rules[sel].prodtype is None:
                        raise Exception("Should not happen!")
                    if product_id not in all_rules[sel].prodtype and all_rules[sel].prodtype != 'all':
                        if sel not in unsels:
                            #print(f'  - {sel}')
                            prof_unsel.add(sel)
            print(f' -{len(prof_unsel)}')
            all_sels.update(sels)
            all_sels.difference_update(unsels)

            unselect_rules_in_profile(product, profile, profile_path, prof_unsel)

        prof_def_sel = set()
        print('  default (hidden)', end="")
        for rul_id, rul in all_rules.items():
            if product_id in rul.prodtype or rul.prodtype == 'all':
                if rul_id not in all_sels:
                    #print(f'  + {rul_id}')
                    prof_def_sel.add(rul_id)
        print(f' +{len(prof_def_sel)}')

        select_rules_in_default_profile(product, env['profiles_root'], prof_def_sel)


if __name__ == "__main__":
    main()
