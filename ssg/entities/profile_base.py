from xml.sax.saxutils import escape

from ..xml import ElementTree as ET

from .common import XCCDFEntity, SelectionHandler, add_sub_element


from ..constants import (
    XCCDF12_NS,
    OSCAP_GROUP,
    OSCAP_PROFILE,
    OSCAP_RULE,
    OSCAP_VALUE,
)


def noop_rule_filterfunc(rule):
    return True


def rule_filter_from_def(filterdef):
    if filterdef is None or filterdef == "":
        return noop_rule_filterfunc

    def filterfunc(rule):
        # Remove globals for security and only expose
        # variables relevant to the rule
        return eval(filterdef, {"__builtins__": None}, rule.__dict__)
    return filterfunc


class Profile(XCCDFEntity, SelectionHandler):
    """Represents XCCDF profile
    """
    KEYS = dict(
        description=lambda: "",
        extends=lambda: "",
        metadata=lambda: None,
        reference=lambda: None,
        selections=lambda: list(),
        unselected_groups=lambda: list(),
        platforms=lambda: set(),
        cpe_names=lambda: set(),
        platform=lambda: None,
        filter_rules=lambda: "",
        ** XCCDFEntity.KEYS
    )

    MANDATORY_KEYS = {
        "title",
        "description",
        "selections",
    }

    @classmethod
    def process_input_dict(cls, input_contents, env_yaml, product_cpes):
        input_contents = super(Profile, cls).process_input_dict(input_contents, env_yaml)

        platform = input_contents.get("platform")
        if platform is not None:
            input_contents["platforms"].add(platform)

        if env_yaml:
            for platform in input_contents["platforms"]:
                try:
                    new_cpe_name = product_cpes.get_cpe_name(platform)
                    input_contents["cpe_names"].add(new_cpe_name)
                except CPEDoesNotExist:
                    msg = (
                        "Unsupported platform '{platform}' in a profile."
                        .format(platform=platform))
                    raise CPEDoesNotExist(msg)

        return input_contents

    @property
    def rule_filter(self):
        if self.filter_rules:
            return rule_filter_from_def(self.filter_rules)
        else:
            return noop_rule_filterfunc

    def _add_selects(self, element, selections, prefix, selected):
        for selection in selections:
            select = ET.Element("{%s}select" % XCCDF12_NS)
            select.set("idref", prefix + selection)
            select.set("selected", selected)
            element.append(select)

    def to_xml_element(self):
        element = ET.Element('{%s}Profile' % XCCDF12_NS)
        element.set("id", OSCAP_PROFILE + self.id_)
        if self.extends:
            element.set("extends", self.extends)
        title = add_sub_element(element, "title", XCCDF12_NS, self.title)
        title.set("override", "true")
        desc = add_sub_element(
            element, "description", XCCDF12_NS, self.description)
        desc.set("override", "true")

        if self.reference:
            add_sub_element(
                element, "reference", XCCDF12_NS, escape(self.reference))

        for cpe_name in self.cpe_names:
            plat = ET.SubElement(element, "{%s}platform" % XCCDF12_NS)
            plat.set("idref", cpe_name)

        self._add_selects(element, self.selected, OSCAP_RULE, "true")
        self._add_selects(element, self.unselected, OSCAP_RULE, "false")
        self._add_selects(element, self.unselected_groups, OSCAP_GROUP, "false")

        for value_id, selector in self.variables.items():
            refine_value = ET.Element("{%s}refine-value" % XCCDF12_NS)
            refine_value.set("idref", OSCAP_VALUE + value_id)
            refine_value.set("selector", selector)
            element.append(refine_value)

        for refined_rule, refinement_list in self.refine_rules.items():
            refine_rule = ET.Element("{%s}refine-rule" % XCCDF12_NS)
            refine_rule.set("idref", OSCAP_RULE + refined_rule)
            for refinement in refinement_list:
                refine_rule.set(refinement[0], refinement[1])
            element.append(refine_rule)

        return element

    def get_rule_selectors(self):
        return self.selected + self.unselected

    def get_variable_selectors(self):
        return self.variables

    def validate_refine_rules(self, rules):
        existing_rule_ids = [r.id_ for r in rules]
        for refine_rule, refinement_list in self.refine_rules.items():
            # Take first refinement to ilustrate where the error is
            # all refinements in list are invalid, so it doesn't really matter
            a_refinement = refinement_list[0]

            if refine_rule not in existing_rule_ids:
                msg = (
                    "You are trying to refine a rule that doesn't exist. "
                    "Rule '{rule_id}' was not found in the benchmark. "
                    "Please check all rule refinements for rule: '{rule_id}', for example: "
                    "- {rule_id}.{property_}={value}' in profile {profile_id}."
                    .format(rule_id=refine_rule, profile_id=self.id_,
                            property_=a_refinement[0], value=a_refinement[1])
                    )
                raise ValueError(msg)

            if refine_rule not in self.get_rule_selectors():
                msg = ("- {rule_id}.{property_}={value}' in profile '{profile_id}' is refining "
                       "a rule that is not selected by it. The refinement will not have any "
                       "noticeable effect. Either select the rule or remove the rule refinement."
                       .format(rule_id=refine_rule, property_=a_refinement[0],
                               value=a_refinement[1], profile_id=self.id_)
                       )
                raise ValueError(msg)

    def validate_variables(self, variables):
        variables_by_id = dict()
        for var in variables:
            variables_by_id[var.id_] = var

        for var_id, our_val in self.variables.items():
            if var_id not in variables_by_id:
                all_vars_list = [" - %s" % v for v in variables_by_id.keys()]
                msg = (
                    "Value '{var_id}' in profile '{profile_name}' is not known. "
                    "We know only variables:\n{var_names}"
                    .format(
                        var_id=var_id, profile_name=self.id_,
                        var_names="\n".join(sorted(all_vars_list)))
                )
                raise ValueError(msg)

            allowed_selectors = [str(s) for s in variables_by_id[var_id].options.keys()]
            if our_val not in allowed_selectors:
                msg = (
                    "Value '{var_id}' in profile '{profile_name}' "
                    "uses the selector '{our_val}'. "
                    "This is not possible, as only selectors {all_selectors} are available. "
                    "Either change the selector used in the profile, or "
                    "add the selector-value pair to the variable definition."
                    .format(
                        var_id=var_id, profile_name=self.id_, our_val=our_val,
                        all_selectors=allowed_selectors,
                    )
                )
                raise ValueError(msg)

    def validate_rules(self, rules, groups):
        existing_rule_ids = [r.id_ for r in rules]
        rule_selectors = self.get_rule_selectors()
        for id_ in rule_selectors:
            if id_ in groups:
                msg = (
                    "You have selected a group '{group_id}' instead of a "
                    "rule. Groups have no effect in the profile and are not "
                    "allowed to be selected. Please remove '{group_id}' "
                    "from profile '{profile_id}' before proceeding."
                    .format(group_id=id_, profile_id=self.id_)
                )
                raise ValueError(msg)
            if id_ not in existing_rule_ids:
                msg = (
                    "Rule '{rule_id}' was not found in the benchmark. Please "
                    "remove rule '{rule_id}' from profile '{profile_id}' "
                    "before proceeding."
                    .format(rule_id=id_, profile_id=self.id_)
                )
                raise ValueError(msg)

    def _find_empty_groups(self, group, profile_rules):
        is_empty = True
        empty_groups = []
        for child in group.groups.values():
            child_empty, child_empty_groups = self._find_empty_groups(child, profile_rules)
            if not child_empty:
                is_empty = False
            empty_groups.extend(child_empty_groups)
        if is_empty:
            group_rules = set(group.rules.keys())
            if profile_rules & group_rules:
                is_empty = False
        if is_empty:
            empty_groups.append(group.id_)
        return is_empty, empty_groups

    def unselect_empty_groups(self, root_group):
        # Unselecting empty groups is necessary to make HTML guides shorter
        # and the XCCDF more usable in tools such as SCAP Workbench.
        profile_rules = set(self.selected)
        is_empty, empty_groups = self._find_empty_groups(root_group, profile_rules)
        if is_empty:
            msg = "Profile {0} unselects all groups.".format(self.id_)
            raise ValueError(msg)
        self.unselected_groups.extend(sorted(empty_groups))

    def __sub__(self, other):
        profile = Profile(self.id_)
        profile.title = self.title
        profile.description = self.description
        profile.extends = self.extends
        profile.platforms = self.platforms
        profile.platform = self.platform
        profile.selected = list(set(self.selected) - set(other.selected))
        profile.selected.sort()
        profile.unselected = list(set(self.unselected) - set(other.unselected))
        profile.variables = dict(
            (k, v) for (k, v) in self.variables.items()
            if k not in other.variables or v != other.variables[k])
        return profile
