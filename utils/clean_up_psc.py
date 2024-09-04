#!/usr/bin/env python3
import json
import os

import ssg.yaml
import ssg.environment
import utils.srg_utils.yaml as srg_yaml

SSG_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

def main():
    product_path = os.path.join(SSG_ROOT, "products", "rhel9", "product.yml")
    build_config = os.path.join(SSG_ROOT, "build", "build_config.yml")
    rule_dirs_path = os.path.join(SSG_ROOT, "build", "rule_dirs.json")
    env_yaml = ssg.environment.open_environment(
            build_config, product_path)
    ssg.yaml.load_macros(env_yaml)


    with open(rule_dirs_path) as rules_dir_fp:
        rule_dirs = json.load(rules_dir_fp)

    for rule_id, rule_obj in rule_dirs.items():
        psc_path = os.path.join(rule_obj["dir"], "policy", "stig", "shared.yml")
        if not os.path.exists(psc_path):
            continue
        psc_yaml = ssg.yaml.open_and_expand(psc_path, env_yaml)
        if 'vuln_discussion' in psc_yaml.keys():
            srg_yaml.replace_yaml_section("vuldiscussion", psc_yaml["vuln_discussion"],
                                          rule_obj)
            remove_section("vuln_discussion", psc_path, psc_yaml)
    return 0

def remove_section(section: str, file_path: str, psc_yaml: dict):
    if not os.path.exists(file_path):
        raise FileNotFoundError
    if section not in psc_yaml.keys():
        raise ValueError
    with open(file_path, 'r+') as fp:
        file_lines = fp.readlines()
        for index, line in enumerate(file_lines):
            if line.startswith("vuln_discussion:"):
                start_line = index
                end_line = index
                if line.startswith("    "):
                    end_line += 1
    with open(file_path, 'w') as fp:
        fp.writelines(file_lines[:start_line])
        fp.flush()

    with open(file_path, "r") as final_fp:
        text = final_fp.read()
        if 'vuln_discussion' in text:
            raise ValueError
        else:
            print(file_path)
if __name__ == "__main__":
    raise SystemExit(main())
