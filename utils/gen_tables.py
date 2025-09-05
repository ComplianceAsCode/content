from glob import glob
import collections
import os

import argparse

import ssg.build_yaml


class References:
    def __init__(self):
        self.ref_by_family = collections.defaultdict(lambda: collections.defaultdict(set))

    def handle_rule_ref_family(self, rule_name, family, rule_content):
        ids = rule_content.split(",")
        for id in ids:
            self.ref_by_family[family][id].add(rule_name)

    def handle_rule(self, rule_entry):
        for family, content in rule_entry.references.items():
            self.handle_rule_ref_family(rule_entry.id_, family, content)

    def sorted(self):
        refs_by_family = collections.OrderedDict()
        families = sorted(self.ref_by_family.keys())
        for f in families:
            refs_by_family[f] = collections.OrderedDict()
            sorted_refs = sorted(self.ref_by_family[f].keys())
            for ref in sorted_refs:
                refs_by_family[f][ref] = sorted(self.ref_by_family[f][ref])
        return refs_by_family


class Output(object):
    def __init__(self, product, build_dir):
        path = "{build_dir}/{product}/rules".format(build_dir=build_dir, product=product)
        rule_files = glob("{path}/*".format(path=path))
        if not rule_files:
            msg = (
                "No files found in '{path}', please make sure that you select the build dir "
                "correctly and that the appropriate product is built.".format(path=path)
            )
            raise ValueError(msg)
        rules_dict = dict()
        for r_file in rule_files:
            rule = ssg.build_yaml.Rule.from_yaml(r_file)
            rules_dict[rule.id_] = rule

        references = References()
        for rule in rules_dict.values():
            references.handle_rule(rule)

        self.product = product
        self.sorted_refs = references.sorted()
        self.rules_dict = rules_dict

    def get_result(self):
        raise NotImplementedError()


class HtmlOutput(Output):
    def get_result(self):
        import ssg.jinja
        subst_dict = dict(all_refs=self.sorted_refs, rules=self.rules_dict, product=self.product)
        html_jinja_template = os.path.join(os.path.dirname(__file__), "references-template.html")
        return ssg.jinja.process_file(html_jinja_template, subst_dict)


class JsonOutput(Output):
    def get_result(self):
        import json
        return json.dumps(self.sorted_refs, indent=2, sort_keys=True)


def parse_args():
    parser = argparse.ArgumentParser(description="Generate reference-rule mapping.")
    parser.add_argument("product", help="What product to consider")
    parser.add_argument("--build-dir", default="build", help="Path to the build directory")
    parser.add_argument("--output-type", choices=("html", "json"), default="html")
    parser.add_argument("--output", help="The filename to generate")
    parser.add_argument("--family", help="Which family of references to output (output all by default)")
    return parser.parse_args()


if __name__ == "__main__":
    output_class_map = dict(
            html=HtmlOutput,
            json=JsonOutput,
    )
    args = parse_args()
    result = output_class_map[args.output_type](args.product, args.build_dir).get_result()
    if not args.output:
        print(result)
    else:
        with open(args.output, "w") as outfile:
            outfile.write(result)
