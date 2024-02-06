import collections
import os
import re

import ssg.build_yaml
import ssg.constants

import template_renderer


def process_refs(ref_format, relevant_refs):
    matching_relevant_refs = []
    not_matching_relevant_refs = []

    for ref in relevant_refs:
        match = re.match(ref_format, ref)
        if match:
            matching_relevant_refs.append(ref)
        else:
            not_matching_relevant_refs.append(ref)

    sorted_relevant_refs = matching_relevant_refs + not_matching_relevant_refs
    return sorted_relevant_refs


def shorten_relevant_ref(ref_format, ref):
    match = re.match(ref_format, ref)
    if match:
        groups = []
        for refpart in match.groups():
            if refpart is None:
                refpart = ""
            try:
                refpart = "{0:07d}".format(int(refpart))
            except ValueError:
                pass
            groups.append(refpart)
        return tuple(groups)
    else:
        return TableHtmlOutput.DEFAULT_SHORTENED_REF


class TableHtmlOutput(template_renderer.Renderer):
    DEFAULT_SHORTENED_REF = ("~",)

    def __init__(self, * args, ** kwargs):
        super(TableHtmlOutput, self).__init__(* args, ** kwargs)

        self.rules_root = os.path.join(self.built_content_path, "rules")
        self.var_root = os.path.join(self.built_content_path, "values")

    def _get_var_value(self, varname):
        return self._get_var_value_from_default(varname)

    def _get_var_value_from_default(self, varname):
        var_path = os.path.join(self.var_root, varname + ".yml")
        var = ssg.build_yaml.Value.from_yaml(var_path, self.env_yaml)
        return var.options["default"]

    def _fix_var_sub_in_text(self, text, varname, value):
        return re.sub(
            r'<sub\s+idref="{var}"\s*/>'.format(var=varname),
            r"<tt>{val}</tt>".format(val=value), text)

    def _resolve_var_substitutions(self, rule):
        # The <sub .../> here is not the HTML subscript element <sub>...</sub>,
        # and therefore is invalid HTML.
        # so this code substitutes the whole sub element with contents of its idref prefixed by $
        # as occurrence of sub with idref implies that substitution of XCCDF values takes place
        variables = re.findall(r'<sub\s+idref="([^"]*)"\s*/>', rule.description)
        variables = set(variables)
        rule.substitutions = dict()
        for var in variables:
            val = self._get_var_value(var)
            rule.description = self._fix_var_sub_in_text(rule.description, var, val)
            rule.substitutions[var] = val

    def _get_eligible_rules(self, refcat):
        raise NotImplementedError

    def _generate_shortened_ref(self, reference, rule):
        if not rule.relevant_refs:
            return self.DEFAULT_SHORTENED_REF
        shortened_ref = shorten_relevant_ref(reference.regex_with_groups, rule.relevant_refs[0])
        if not shortened_ref:
            shortened_ref = self.DEFAULT_SHORTENED_REF
        return shortened_ref

    def process_rules(self, reference):
        eligible_rules = self._get_eligible_rules(reference.id)

        output_rules = collections.defaultdict(list)
        for rule in eligible_rules:
            self._resolve_var_substitutions(rule)
            relevant_refs = rule.references.get(reference.id, "")
            rule.relevant_refs = process_refs(reference.regex_with_groups, relevant_refs)
            shortened_ref = self._generate_shortened_ref(reference, rule)
            output_rules[shortened_ref].append(rule)

        self.template_data["rules_by_shortref"] = output_rules
        self.template_data["sorted_refs"] = sorted(list(output_rules.keys()))
        self.template_data["reference_title"] = reference.name
        self.template_data["product"] = self.product
        self.template_data["product_full_name"] = self.product
        for full, short in ssg.constants.FULL_NAME_TO_PRODUCT_MAPPING.items():
            if short == self.product:
                self.template_data["product_full_name"] = full
                break


def update_parser(parser):
    parser.add_argument(
        "refcategory", metavar="REFERENCE_ID",
        choices=ssg.constants.REFERENCES.keys(), help="Category of the rule reference")
