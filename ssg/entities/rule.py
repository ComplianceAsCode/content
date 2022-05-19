import re

import ssg.build_remediations
from ..xml import ElementTree as ET
from ..rule_yaml import parse_prodtype
from ..cce import is_cce_format_valid, is_cce_value_valid
from ..constants import cce_uri, oval_namespace, ocil_cs, FIX_TYPE_TO_SYSTEM

from . import common
from .platform import Platform, add_platform_if_not_defined


def add_reference_elements(element, references, ref_uri_dict):
    for ref_type, ref_vals in references.items():
        for ref_val in ref_vals.split(","):
            # This assumes that a single srg key may have items from multiple SRG types
            if ref_type == 'srg':
                if ref_val.startswith('SRG-OS-'):
                    ref_href = ref_uri_dict['os-srg']
                elif ref_val.startswith('SRG-APP-'):
                    ref_href = ref_uri_dict['app-srg']
                else:
                    raise ValueError("SRG {0} doesn't have a URI defined.".format(ref_val))
            else:
                try:
                    ref_href = ref_uri_dict[ref_type]
                except KeyError as exc:
                    msg = (
                        "Error processing reference {0}: {1} in Rule {2}."
                        .format(ref_type, ref_vals, self.id_))
                    raise ValueError(msg)

            ref = ET.SubElement(element, 'reference')
            ref.set("href", ref_href)
            ref.text = ref_val


class Rule(common.XCCDFEntity):
    """Represents XCCDF Rule
    """
    KEYS = dict(
        prodtype=lambda: "all",
        title=lambda: "",
        description=lambda: "",
        rationale=lambda: "",
        severity=lambda: "",
        references=lambda: dict(),
        identifiers=lambda: dict(),
        ocil_clause=lambda: None,
        ocil=lambda: None,
        oval_external_content=lambda: None,
        fixtext=lambda: "",
        srg_requirement=lambda: "",
        warnings=lambda: list(),
        conflicts=lambda: list(),
        requires=lambda: list(),
        platform=lambda: None,
        platforms=lambda: set(),
        sce_metadata=lambda: dict(),
        inherited_platforms=lambda: list(),
        template=lambda: None,
        cpe_platform_names=lambda: set(),
        inherited_cpe_platform_names=lambda: list(),
        bash_conditional=lambda: None,
        fixes=lambda: dict(),
        ** common.XCCDFEntity.KEYS
    )

    MANDATORY_KEYS = {
        "title",
        "description",
        "rationale",
        "severity",
    }

    GENERIC_FILENAME = "rule.yml"
    ID_LABEL = "rule_id"

    PRODUCT_REFERENCES = ("stigid", "cis",)
    GLOBAL_REFERENCES = ("srg", "vmmsrg", "disa", "cis-csc",)

    def __init__(self, id_):
        super(Rule, self).__init__(id_)
        self.sce_metadata = None

    def __deepcopy__(self, memo):
        cls = self.__class__
        result = cls.__new__(cls)
        memo[id(self)] = result
        for k, v in self.__dict__.items():
            # These are difficult to deep copy, so let's just re-use them.
            if k != "template" and k != "local_env_yaml":
                setattr(result, k, deepcopy(v, memo))
            else:
                setattr(result, k, v)
        return result

    @classmethod
    def from_yaml(cls, yaml_file, env_yaml=None, product_cpes=None, sce_metadata=None):
        rule = super(Rule, cls).from_yaml(yaml_file, env_yaml, product_cpes)

        # platforms are read as list from the yaml file
        # we need them to convert to set again
        rule.platforms = set(rule.platforms)

        # rule.platforms.update(set(rule.inherited_platforms))

        common.check_warnings(rule)

        # ensure that content of rule.platform is in rule.platforms as
        # well
        if rule.platform is not None:
            rule.platforms.add(rule.platform)

        # Convert the platform names to CPE names
        # But only do it if an env_yaml was specified (otherwise there would be no product CPEs
        # to lookup), and the rule's prodtype matches the product being built
        # also if the rule already has cpe_platform_names specified (compiled rule)
        # do not evaluate platforms again
        if (
                env_yaml and env_yaml["product"] in parse_prodtype(rule.prodtype)
                or env_yaml and rule.prodtype == "all") and product_cpes and not rule.cpe_platform_names:
            # parse platform definition and get CPEAL platform
            for platform in rule.platforms:
                cpe_platform = Platform.from_text(platform, product_cpes)
                cpe_platform = add_platform_if_not_defined(cpe_platform, product_cpes)
                rule.cpe_platform_names.add(cpe_platform.id_)


        if sce_metadata and rule.id_ in sce_metadata:
            rule.sce_metadata = sce_metadata[rule.id_]
            rule.sce_metadata["relative_path"] = os.path.join(
                env_yaml["product"], "checks/sce", rule.sce_metadata['filename'])

        rule.validate_prodtype(yaml_file)
        rule.validate_identifiers(yaml_file)
        rule.validate_references(yaml_file)
        return rule

    def _verify_stigid_format(self, product):
        stig_id = self.references.get("stigid", None)
        if not stig_id:
            return
        if "," in stig_id:
            raise ValueError("Rules can not have multiple STIG IDs.")

    def _verify_disa_cci_format(self):
        cci_id = self.references.get("disa", None)
        if not cci_id:
            return
        cci_ex = re.compile(r'^CCI-[0-9]{6}$')
        for cci in cci_id.split(","):
            if not cci_ex.match(cci):
                raise ValueError("CCI '{}' is in the wrong format! "
                                 "Format should be similar to: "
                                 "CCI-XXXXXX".format(cci))
        self.references["disa"] = cci_id

    def normalize(self, product):
        try:
            self.make_refs_and_identifiers_product_specific(product)
            self.make_template_product_specific(product)
        except Exception as exc:
            msg = (
                "Error normalizing '{rule}': {msg}"
                .format(rule=self.id_, msg=str(exc))
            )
            raise RuntimeError(msg)

    def add_stig_references(self, stig_references):
        stig_id = self.references.get("stigid", None)
        if not stig_id:
            return
        reference = stig_references.get(stig_id, None)
        if not reference:
            return
        self.references["stigref"] = reference

    def _get_product_only_references(self):
        product_references = dict()

        for ref in Rule.PRODUCT_REFERENCES:
            start = "{0}@".format(ref)
            for gref, gval in self.references.items():
                if ref == gref or gref.startswith(start):
                    product_references[gref] = gval
        return product_references

    def make_template_product_specific(self, product):
        product_suffix = "@{0}".format(product)

        if not self.template:
            return

        not_specific_vars = self.template.get("vars", dict())
        specific_vars = self._make_items_product_specific(
            not_specific_vars, product_suffix, True)
        self.template["vars"] = specific_vars

        not_specific_backends = self.template.get("backends", dict())
        specific_backends = self._make_items_product_specific(
            not_specific_backends, product_suffix, True)
        self.template["backends"] = specific_backends

    def make_refs_and_identifiers_product_specific(self, product):
        product_suffix = "@{0}".format(product)

        product_references = self._get_product_only_references()
        general_references = self.references.copy()
        for todel in product_references:
            general_references.pop(todel)
        for ref in Rule.PRODUCT_REFERENCES:
            if ref in general_references:
                msg = "Unexpected reference identifier ({0}) without "
                msg += "product qualifier ({0}@{1}) while building rule "
                msg += "{2}"
                msg = msg.format(ref, product, self.id_)
                raise ValueError(msg)

        to_set = dict(
            identifiers=(self.identifiers, False),
            general_references=(general_references, True),
            product_references=(product_references, False),
        )
        for name, (dic, allow_overwrites) in to_set.items():
            try:
                new_items = self._make_items_product_specific(
                    dic, product_suffix, allow_overwrites)
            except ValueError as exc:
                msg = (
                    "Error processing {what} for rule '{rid}': {msg}"
                    .format(what=name, rid=self.id_, msg=str(exc))
                )
                raise ValueError(msg)
            dic.clear()
            dic.update(new_items)

        self.references = general_references
        self._verify_disa_cci_format()
        self.references.update(product_references)

        self._verify_stigid_format(product)

    def _make_items_product_specific(self, items_dict, product_suffix, allow_overwrites=False):
        new_items = dict()
        for full_label, value in items_dict.items():
            if "@" not in full_label and full_label not in new_items:
                new_items[full_label] = value
                continue

            label = full_label.split("@")[0]

            # this test should occur before matching product_suffix with the product qualifier
            # present in the reference, so it catches problems even for products that are not
            # being built at the moment
            if label in Rule.GLOBAL_REFERENCES:
                msg = (
                    "You cannot use product-qualified for the '{item_u}' reference. "
                    "Please remove the product-qualifier and merge values with the "
                    "existing reference if there is any. Original line: {item_q}: {value_q}"
                    .format(item_u=label, item_q=full_label, value_q=value)
                )
                raise ValueError(msg)

            if not full_label.endswith(product_suffix):
                continue

            if label in items_dict and not allow_overwrites and value != items_dict[label]:
                msg = (
                    "There is a product-qualified '{item_q}' item, "
                    "but also an unqualified '{item_u}' item "
                    "and those two differ in value - "
                    "'{value_q}' vs '{value_u}' respectively."
                    .format(item_q=full_label, item_u=label,
                            value_q=value, value_u=items_dict[label])
                )
                raise ValueError(msg)
            new_items[label] = value
        return new_items

    def validate_identifiers(self, yaml_file):
        if self.identifiers is None:
            raise ValueError("Empty identifier section in file %s" % yaml_file)

        # Validate all identifiers are non-empty:
        for ident_type, ident_val in self.identifiers.items():
            if not isinstance(ident_type, str) or not isinstance(ident_val, str):
                raise ValueError("Identifiers and values must be strings: %s in file %s"
                                 % (ident_type, yaml_file))
            if ident_val.strip() == "":
                raise ValueError("Identifiers must not be empty: %s in file %s"
                                 % (ident_type, yaml_file))
            if ident_type[0:3] == 'cce':
                if not is_cce_format_valid(ident_val):
                    raise ValueError("CCE Identifier format must be valid: invalid format '%s' for CEE '%s'"
                                     " in file '%s'" % (ident_val, ident_type, yaml_file))
                if not is_cce_value_valid("CCE-" + ident_val):
                    raise ValueError("CCE Identifier value is not a valid checksum: invalid value '%s' for CEE '%s'"
                                     " in file '%s'" % (ident_val, ident_type, yaml_file))

    def validate_references(self, yaml_file):
        if self.references is None:
            raise ValueError("Empty references section in file %s" % yaml_file)

        for ref_type, ref_val in self.references.items():
            if not isinstance(ref_type, str) or not isinstance(ref_val, str):
                raise ValueError("References and values must be strings: %s in file %s"
                                 % (ref_type, yaml_file))
            if ref_val.strip() == "":
                raise ValueError("References must not be empty: %s in file %s"
                                 % (ref_type, yaml_file))

        for ref_type, ref_val in self.references.items():
            for ref in ref_val.split(","):
                if ref.strip() != ref:
                    msg = (
                        "Comma-separated '{ref_type}' reference "
                        "in {yaml_file} contains whitespace."
                        .format(ref_type=ref_type, yaml_file=yaml_file))
                    raise ValueError(msg)

    def validate_prodtype(self, yaml_file):
        for ptype in self.prodtype.split(","):
            if ptype.strip() != ptype:
                msg = (
                    "Comma-separated '{prodtype}' prodtype "
                    "in {yaml_file} contains whitespace."
                    .format(prodtype=self.prodtype, yaml_file=yaml_file))
                raise ValueError(msg)

    def add_fixes(self, fixes):
        self.fixes = fixes

    def _add_fixes_elements(self, rule_el):
        for fix_type, fix in self.fixes.items():
            fix_el = ET.SubElement(rule_el, "fix")
            fix_el.set("system", FIX_TYPE_TO_SYSTEM[fix_type])
            fix_el.set("id", self.id_)
            fix_contents, config = fix
            for key in ssg.build_remediations.REMEDIATION_ELM_KEYS:
                if config[key]:
                    fix_el.set(key, config[key])
            fix_el.text = fix_contents + "\n"
            # Expand shell variables and remediation functions
            # into corresponding XCCDF <sub> elements
            ssg.build_remediations.expand_xccdf_subs(fix_el, fix_type)

    def to_xml_element(self, env_yaml=None):
        rule = ET.Element('Rule')
        rule.set('selected', 'false')
        rule.set('id', self.id_)
        rule.set('severity', self.severity)
        common.add_sub_element(rule, 'title', self.title)
        common.add_sub_element(rule, 'description', self.description)
        common.add_warning_elements(rule, self.warnings)

        if env_yaml:
            ref_uri_dict = env_yaml['reference_uris']
        else:
            ref_uri_dict = SSG_REF_URIS
        add_reference_elements(rule, self.references, ref_uri_dict)

        common.add_sub_element(rule, 'rationale', self.rationale)

        for cpe_platform_name in sorted(self.cpe_platform_names):
            platform_el = ET.SubElement(rule, "platform")
            platform_el.set("idref", "#"+cpe_platform_name)

        common.add_nondata_subelements(rule, "requires", "idref", self.requires)
        common.add_nondata_subelements(rule, "conflicts", "idref", self.conflicts)

        for ident_type, ident_val in self.identifiers.items():
            ident = ET.SubElement(rule, 'ident')
            if ident_type == 'cce':
                ident.set('system', cce_uri)
                ident.text = ident_val
        self._add_fixes_elements(rule)

        ocil_parent = rule
        check_parent = rule

        if self.sce_metadata:
            # TODO: This is pretty much another hack, just like the previous OVAL
            # one. However, we avoided the external SCE content as I'm not sure it
            # is generally useful (unlike say, CVE checking with external OVAL)
            #
            # Additionally, we build the content (check subelement) here rather
            # than in xslt due to the nature of our SCE metadata.
            #
            # Finally, before we begin, we might have an element with both SCE
            # and OVAL. We have no way of knowing (right here) whether that is
            # the case (due to a variety of issues, most notably, that linking
            # hasn't yet occurred). So we must rely on the content author's
            # good will, by annotating SCE content with a complex-check tag
            # if necessary.

            if 'complex-check' in self.sce_metadata:
                # Here we have an issue: XCCDF allows EITHER one or more check
                # elements OR a single complex-check. While we have an explicit
                # case handling the OVAL-and-SCE interaction, OCIL entries have
                # (historically) been alongside OVAL content and been in an
                # "OR" manner -- preferring OVAL to SCE. In order to accomplish
                # this, we thus need to add _yet another parent_ when OCIL data
                # is present, and add update ocil_parent accordingly.
                if self.ocil or self.ocil_clause:
                    ocil_parent = ET.SubElement(ocil_parent, "complex-check")
                    ocil_parent.set('operator', 'OR')

                check_parent = ET.SubElement(ocil_parent, "complex-check")
                check_parent.set('operator', self.sce_metadata['complex-check'])

            # Now, add the SCE check element to the tree.
            check = ET.SubElement(check_parent, "check")
            check.set("system", SCE_SYSTEM)

            if 'check-import' in self.sce_metadata:
                if isinstance(self.sce_metadata['check-import'], str):
                    self.sce_metadata['check-import'] = [self.sce_metadata['check-import']]
                for entry in self.sce_metadata['check-import']:
                    check_import = ET.SubElement(check, 'check-import')
                    check_import.set('import-name', entry)
                    check_import.text = None

            if 'check-export' in self.sce_metadata:
                if isinstance(self.sce_metadata['check-export'], str):
                    self.sce_metadata['check-export'] = [self.sce_metadata['check-export']]
                for entry in self.sce_metadata['check-export']:
                    export, value = entry.split('=')
                    check_export = ET.SubElement(check, 'check-export')
                    check_export.set('value-id', value)
                    check_export.set('export-name', export)
                    check_export.text = None

            check_ref = ET.SubElement(check, "check-content-ref")
            href = self.sce_metadata['relative_path']
            check_ref.set("href", href)

        check = ET.SubElement(check_parent, 'check')
        check.set("system", oval_namespace)
        check_content_ref = ET.SubElement(check, "check-content-ref")
        if self.oval_external_content:
            check_content_ref.set("href", self.oval_external_content)
        else:
            # TODO: This is pretty much a hack, oval ID will be the same as rule ID
            #       and we don't want the developers to have to keep them in sync.
            #       Therefore let's just add an OVAL ref of that ID.
            # TODO  Can we not add the check element if the rule doesn't have an OVAL check?
            #       At the moment, the check elements of rules without OVAL are removed by
            #       relabel_ids.py
            check_content_ref.set("href", "oval-unlinked.xml")
            check_content_ref.set("name", self.id_)

        if self.ocil or self.ocil_clause:
            ocil_check = ET.SubElement(check_parent, "check")
            ocil_check.set("system", ocil_cs)
            ocil_check_ref = ET.SubElement(ocil_check, "check-content-ref")
            ocil_check_ref.set("href", "ocil-unlinked.xml")
            ocil_check_ref.set("name", self.id_ + "_ocil")

        return rule

    def to_file(self, file_name):
        root = self.to_xml_element()
        tree = ET.ElementTree(root)
        tree.write(file_name)

    def to_ocil(self):
        if not self.ocil and not self.ocil_clause:
            raise ValueError("Rule {0} doesn't have OCIL".format(self.id_))
        # Create <questionnaire> for the rule
        questionnaire = ET.Element("questionnaire", id=self.id_ + "_ocil")
        title = ET.SubElement(questionnaire, "title")
        title.text = self.title
        actions = ET.SubElement(questionnaire, "actions")
        test_action_ref = ET.SubElement(actions, "test_action_ref")
        test_action_ref.text = self.id_ + "_action"
        # Create <boolean_question_test_action> for the rule
        action = ET.Element(
            "boolean_question_test_action",
            id=self.id_ + "_action",
            question_ref=self.id_ + "_question")
        when_true = ET.SubElement(action, "when_true")
        result = ET.SubElement(when_true, "result")
        result.text = "PASS"
        when_true = ET.SubElement(action, "when_false")
        result = ET.SubElement(when_true, "result")
        result.text = "FAIL"
        # Create <boolean_question>
        boolean_question = ET.Element(
            "boolean_question", id=self.id_ + "_question")
        # TODO: The contents of <question_text> element used to be broken in
        # the legacy XSLT implementation. The following code contains hacks
        # to get the same results as in the legacy XSLT implementation.
        # This enabled us a smooth transition to new OCIL generator
        # without a need to mass-edit rule YAML files.
        # We need to solve:
        # TODO: using variables (aka XCCDF Values) in OCIL content
        # TODO: using HTML formating tags eg. <pre> in OCIL content
        #
        # The "ocil" key in compiled rules contains HTML and XML elements
        # but OCIL question texts shouldn't contain HTML or XML elements,
        # therefore removing them.
        if self.ocil is not None:
            ocil_without_tags = re.sub(r"</?[^>]+>", "", self.ocil)
        else:
            ocil_without_tags = ""
        # The "ocil" key in compiled rules contains XML entities which would
        # be escaped by ET.Subelement() so we need to use add_sub_element()
        # instead because we don't want to escape them.
        question_text = common.add_sub_element(
            boolean_question, "question_text", ocil_without_tags)
        # The "ocil_clause" key in compiled rules also contains HTML and XML
        # elements but unlike the "ocil" we want to escape the '<' and '>'
        # characters.
        # The empty ocil_clause causing broken question is in line with the
        # legacy XSLT implementation.
        ocil_clause = self.ocil_clause if self.ocil_clause else ""
        question_text.text = (
            u"{0}\n      Is it the case that {1}?\n      ".format(
                question_text.text if question_text.text is not None else "",
                ocil_clause))
        return (questionnaire, action, boolean_question)

    def __hash__(self):
        """ Controls are meant to be unique, so using the
        ID should suffice"""
        return hash(self.id_)

    def __eq__(self, other):
        return isinstance(other, self.__class__) and self.id_ == other.id_

    def __ne__(self, other):
        return not self != other

    def __lt__(self, other):
        return self.id_ < other.id_

    def __str__(self):
        return self.id_