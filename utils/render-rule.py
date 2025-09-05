#!/usr/bin/python3

from glob import glob
import collections
import sys
import pathlib
import re

import pygments
import pygments.lexers
import pygments.formatters

import ssg.build_yaml
import ssg.controls
import ssg.yaml
import ssg.jinja
import template_renderer
from rendering import common


POLICY_FIELDS_MAPPING = dict(
    checktext="checks",
    fixtext="fixes",
    srg_requirement="prose",
    vuldiscussion="prose",
)


class Namespace:
    def __init__(self):
        self.policy_specific_content = collections.defaultdict(dict)

    def contains_something(self):
        copy_of_attributes = dict(vars(self))

        if self.policy_specific_content:
            return True
        else:
            copy_of_attributes.pop("policy_specific_content")

        for stuff in copy_of_attributes:
            if stuff:
                return True
        return False

    def sub_newlines_with_br(self):
        attributes = vars(self)
        for attr, value in attributes.items():
            if not value:
                continue
            attributes[attr] = re.sub(r"\n+", r"<br/>\n", value)


class HtmlOutput(template_renderer.Renderer):
    TEMPLATE_NAME = "rendering/rule-template.html"

    def process_rule(self, rule_id):
        self.built_content_path = pathlib.Path(self.built_content_path)

        rule_fname = self.built_content_path / "rules" / (rule_id + ".yml")
        try:
            rule = ssg.build_yaml.Rule.from_yaml(rule_fname, self.env_yaml)
        except RuntimeError as exc:
            msg = (
                f"{str(exc)}. Make sure that the product is compiled, "
                f"and '{rule_id}' is a short rule ID.")
            print(msg, file=sys.stderr)
            sys.exit(1)

        prose = Namespace()
        prose.description = common.resolve_var_substitutions(rule.description)
        prose.rationale = common.resolve_var_substitutions(rule.rationale)
        prose.sub_newlines_with_br()

        self.template_data["prose"] = prose
        self.template_data["fixes"] = self._get_fixes(rule_id)
        self.template_data["checks"] = self._get_checks(rule_id)
        self.template_data["rule"] = rule

        self._add_policy_content_to_categories(rule.policy_specific_content)

    def _add_policy_content_to_categories(self, policy_specific_content):
        for policy, contents in policy_specific_content.items():
            for field_name, text in contents.items():
                target_category = POLICY_FIELDS_MAPPING.get(field_name)
                if target_category is None:
                    continue

                target_destination = self.template_data[target_category]
                text = re.sub(r"\n+", r"<br/>\n", text)
                target_destination.policy_specific_content[policy][field_name] = text

    def _highlight_file(self, fname, lexer):
        with open(fname, "r") as f:
            code = f.read()
            code = common.resolve_var_substitutions(code)
            return pygments.highlight(code, lexer, pygments.formatters.HtmlFormatter())

    def _get_fixes(self, rule_id):
        fixes = Namespace()

        basename = rule_id + ".sh"
        bash_loc = self.built_content_path / "fixes" / "bash" / basename
        if not bash_loc.exists():
            bash_loc = self.built_content_path / "fixes_from_templates" / "bash" / basename
        if bash_loc.exists():
            fixes.bash = self._highlight_file(bash_loc, pygments.lexers.BashLexer())

        basename = rule_id + ".yml"
        ansible_loc = self.built_content_path / "fixes" / "ansible" / basename
        if not ansible_loc.exists():
            ansible_loc = self.built_content_path / "fixes_from_templates" / "ansible" / basename
        if ansible_loc.exists():
            fixes.ansible = self._highlight_file(ansible_loc, pygments.lexers.YamlLexer())

        return fixes

    def _get_checks(self, rule_id):
        checks = Namespace()

        basename = rule_id + ".xml"
        oval_loc = self.built_content_path / "checks" / "oval" / basename
        if not oval_loc.exists():
            oval_loc = self.built_content_path / "checks_from_templates" / "oval" / basename
        if oval_loc.exists():
            checks.oval = self._highlight_file(oval_loc, pygments.lexers.XmlLexer())

        return checks


def parse_args():
    parser = HtmlOutput.create_parser(
        "Pass a short rule ID, and the script will render the rule fields and "
        "associated content in a form of a single HTML file, "
        "so consistency of the rule can be conveniently examined. "
        "To get syntax highlighting, you will need a highlight.css file in the same directory, "
        "you can generate one using pygmentize e.g. by running "
        "pygmentize -S solarized-dark -f html > highlight.css")
    parser.add_argument(
        "rule", metavar="RULE_ID", help="The rule short ID")
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    renderer = HtmlOutput(args.product, args.build_dir)
    renderer.process_rule(args.rule)
    renderer.output_results(args)
