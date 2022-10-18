#!/usr/bin/python3

import difflib
import os
import re
import sys
import xml.etree.ElementTree as ET

import ssg.xml
from ssg.constants import FIX_TYPE_TO_SYSTEM, XCCDF12_NS


class StandardContentDiffer(object):

    def __init__(self, old_content, new_content, rule_id, show_diffs, rule_diffs,
                 only_rules, output_dir):
        self.old_content = old_content
        self.new_content = new_content

        self.rule_id = rule_id
        self.show_diffs = show_diffs
        self.rule_diffs = rule_diffs
        self.only_rules = only_rules

        self.context_lines = 3

        self.check_system_map = {
            "OVAL": {"uri": ssg.constants.oval_namespace, "comp_func": self.compare_ovals},
            "OCIL": {"uri": ssg.constants.ocil_cs, "comp_func": self.compare_ocils}
        }

        self.output_dir = output_dir
        if self.rule_diffs:
            self._ensure_output_dir_exists()

    def _ensure_output_dir_exists(self):
        if os.path.exists(self.output_dir):
            if not os.path.isdir(self.output_dir):
                print("Output path '%s' exists and it is not a directory." % self.output_dir)
                sys.exit(1)
        else:
            os.mkdir(self.output_dir)

    def output_diff(self, identifier, diff, mode="a"):
        if not diff:
            return

        if self.rule_diffs:
            with open("%s/%s" % (self.output_dir, identifier), mode) as f:
                f.write(diff)
        else:
            print(diff)

    def _get_rules_to_compare(self, benchmark):
        rule_to_find = self.rule_id
        if self.rule_id:
            if not self.rule_id.startswith(ssg.constants.OSCAP_RULE):
                rule_to_find = ssg.constants.OSCAP_RULE + self.rule_id
        rules = benchmark.find_rules(rule_to_find)
        return rules

    def compare_rules(self, old_benchmark, new_benchmark):
        missing_rules = []
        try:
            rules_in_old_benchmark = self._get_rules_to_compare(old_benchmark)
        except ValueError as e:
            print(str(e))
            return

        for old_rule in rules_in_old_benchmark:
            rule_id = old_rule.get_attr("id")
            new_rule = new_benchmark.find_rule(rule_id)
            if new_rule is None:
                missing_rules.append(rule_id)
                print("%s is missing in new datastream." % (rule_id))
                continue
            if self.only_rules:
                continue
            self.compare_rule(old_rule, new_rule, rule_id)
            self.compare_platforms(old_rule, new_rule,
                                   old_benchmark, new_benchmark, rule_id)

        if self.rule_diffs:
            print("Diff files saved at %s." % self.output_dir)

    def compare_rule(self, old_rule, new_rule, identifier):
        self.compare_rule_texts(old_rule, new_rule, identifier)
        self.compare_checks(old_rule, new_rule, "OVAL", identifier)
        self.compare_checks(old_rule, new_rule, "OCIL", identifier)
        for remediation_type in FIX_TYPE_TO_SYSTEM.keys():
            self.compare_remediations(old_rule, new_rule, remediation_type, identifier)

    def _get_list_of_platforms(self, cpe_platforms):
        cpe_list = []
        if len(cpe_platforms) == 0:
            print("Platform {0} not defined in platform specification".format(idref))
            return cpe_list
        elif len(cpe_platforms) > 1:
            print("Platform {0} defined more than once".format(idref))
            for cpe_p in cpe_platforms:
                ET.dump(cpe_p)
        for cpe_platform in cpe_platforms:
            fact_refs = cpe_platform.find_all_fact_ref_elements()
            for fact_ref in fact_refs:
                cpe_list.append(fact_ref.get("name"))
        return cpe_list

    def compare_platforms(self, old_rule, new_rule, old_benchmark, new_benchmark, identifier):
        entries = [{
                "benchmark": old_benchmark,
                "rule": old_rule,
                "cpe": []
            }, {
                "benchmark": new_benchmark,
                "rule": new_rule,
                "cpe": []
            }]

        for entry in entries:
            for platform in entry["rule"].get_all_platform_elements():
                idref = platform.get("idref")
                if idref.startswith("#"):
                    cpe_platforms = entry["benchmark"].find_all_cpe_platforms(idref)
                    entry["cpe"] += self._get_list_of_platforms(cpe_platforms)
                else:
                    entry["cpe"].append(idref)

        if entries[0]["cpe"] != entries[1]["cpe"]:
            print("Platform has been changed for rule '{0}'".format(identifier))

            if self.show_diffs:
                diff = self.generate_diff_text("\n".join(entries[0]["cpe"])+"\n",
                                               "\n".join(entries[1]["cpe"])+"\n",
                                               fromfile=identifier, tofile=identifier)
                self.output_diff(identifier, diff)

    def compare_rule_texts(self, old_rule, new_rule, identifier):
        old_rule_text = old_rule.join_text_elements()
        new_rule_text = new_rule.join_text_elements()

        if old_rule_text == new_rule_text:
            return

        if old_rule_text != "":
            print(
                "New content has different text for rule '%s'." % (identifier))

        if self.show_diffs:
            diff = self.generate_diff_text(old_rule_text, new_rule_text,
                                           fromfile=identifier, tofile=identifier,
                                           n=self.context_lines)

            self.output_diff(identifier, diff, mode="w")

    def compare_check_ids(self, system, identifier, old_check_id, new_check_id):
        if old_check_id != new_check_id:
            print(
                "%s definition ID for rule '%s' has changed from "
                "'%s' to '%s'." % (
                    system, identifier, old_check_id, new_check_id)
            )

    def compare_check_file_names(self, system, identifier,
                                 old_check_file_name, new_check_file_name):
        if old_check_file_name != new_check_file_name:
            print(
                "%s definition file for rule '%s' has changed from "
                "'%s' to '%s'." % (
                    system, identifier, old_check_file_name, new_check_file_name)
            )

    def get_check_docs(self, system, identifier, old_check_file_name, new_check_file_name):
        try:
            old_check_doc = self.old_content.components.get(system)[old_check_file_name]
        except (KeyError, TypeError):
            print(
                "Rule '%s' points to '%s' which isn't a part of the "
                "old datastream" % (identifier, old_check_file_name))
            old_check_doc = None
        try:
            new_check_doc = self.new_content.components.get(system)[new_check_file_name]
        except (KeyError, TypeError):
            print(
                "Rule '%s' points to '%s' which isn't a part of the "
                "new datastream" % (identifier, new_check_file_name))
            new_check_doc = None
        return old_check_doc, new_check_doc

    def compare_checks(self, old_rule, new_rule, system, identifier):
        check_system_uri = self.check_system_map[system]["uri"]
        old_check = old_rule.get_check_element(check_system_uri)
        new_check = new_rule.get_check_element(check_system_uri)
        if (old_check is None and new_check is not None):
            print("New datastream adds %s for rule '%s'." % (system, identifier))
        elif (old_check is not None and new_check is None):
            print(
                "New datastream is missing %s for rule '%s'." % (system, identifier))
        elif (old_check is not None and new_check is not None):
            old_check_content_ref = old_rule.get_check_content_ref_element(old_check)
            new_check_content_ref = new_rule.get_check_content_ref_element(new_check)
            old_check_id = old_check_content_ref.get("name")
            new_check_id = new_check_content_ref.get("name")
            old_check_file_name = old_check_content_ref.get("href")
            new_check_file_name = new_check_content_ref.get("href")

            self.compare_check_ids(system, identifier, old_check_id, new_check_id)
            self.compare_check_file_names(system, identifier,
                                          old_check_file_name, new_check_file_name)

            if (self.show_diffs and
               identifier != "xccdf_org.ssgproject.content_rule_security_patches_up_to_date"):

                old_check_doc, new_check_doc = self.get_check_docs(system, identifier,
                                                                   old_check_file_name,
                                                                   new_check_file_name)
                if not old_check_doc or not new_check_doc:
                    return

                self.check_system_map[system]["comp_func"](old_check_doc, old_check_id,
                                                           new_check_doc, new_check_id, identifier)

    def compare_ovals(self, old_oval_def_doc, old_oval_def_id,
                      new_oval_def_doc, new_oval_def_id, identifier):
        old_def = old_oval_def_doc.find_oval_definition(old_oval_def_id)
        new_def = new_oval_def_doc.find_oval_definition(new_oval_def_id)
        old_els = old_def.get_elements()
        new_els = new_def.get_elements()

        old_els_text = self.serialize_elements(old_els)
        new_els_text = self.serialize_elements(new_els)
        diff = self.generate_diff_text(old_els_text, new_els_text,
                                       fromfile=old_oval_def_id, tofile=new_oval_def_id)
        if diff:
            print("OVAL for rule '%s' differs." % (identifier))
        self.output_diff(identifier, diff)

    def compare_ocils(self, old_ocil_doc, old_ocil_id, new_ocil_doc, new_ocil_id, identifier):
        try:
            old_question = old_ocil_doc.find_boolean_question(old_ocil_id)
            new_question = new_ocil_doc.find_boolean_question(new_ocil_id)
        except ValueError as e:
            print("Rule '%s' OCIL can't be found: %s" % (identifier, str(e)))
            return
        diff = self.generate_diff_text(old_question, new_question,
                                       fromfile=old_ocil_id, tofile=new_ocil_id)
        if diff:
            print("OCIL for rule '%s' differs." % identifier)
        self.output_diff(identifier, diff)

    def compare_remediations(self, old_rule, new_rule, remediation_type, identifier):
        system = FIX_TYPE_TO_SYSTEM[remediation_type]
        old_fix = old_rule.get_fix_element(system)
        new_fix = new_rule.get_fix_element(system)
        if (old_fix is None and new_fix is not None):
            print("New datastream adds %s remediation for rule '%s'." % (
                remediation_type, identifier))
        elif (old_fix is not None and new_fix is None):
            print("New datastream is missing %s remediation for rule '%s'." % (
                remediation_type, identifier))
        elif (old_fix is not None and new_fix is not None):
            self._compare_fix_elements(
                old_fix, new_fix, remediation_type, identifier)

    def _compare_fix_elements(self, old_fix, new_fix, remediation_type, identifier):
        old_fix_id = old_fix.get("id")
        new_fix_id = new_fix.get("id")
        if old_fix_id != new_fix_id:
            print(
                "%s remediation ID for rule '%s' has changed from "
                "'%s' to '%s'." % (
                    remediation_type, identifier, old_fix_id, new_fix_id)
            )
        if self.show_diffs:
            old_fix_text = "".join(old_fix.itertext())
            new_fix_text = "".join(new_fix.itertext())
            diff = self.generate_diff_text(old_fix_text, new_fix_text,
                                           fromfile=identifier, tofile=identifier)
            if diff:
                print("%s remediation for rule '%s' differs." % (remediation_type, identifier))
            self.output_diff(identifier, diff)

    def generate_diff_text(self, old_r, new_r,
                           fromfile="old datastream", tofile="new datastream", n=3):
        if old_r != new_r:
            diff = "".join(difflib.unified_diff(
                old_r.splitlines(keepends=True), new_r.splitlines(keepends=True),
                fromfile=fromfile, tofile=tofile, n=n))
            return diff
        return None

    def serialize_elements(self, elements):
        text = ""
        for thing, atrribute in elements:
            text += "%s %s\n" % (thing, atrribute)
        return text


class StigContentDiffer(StandardContentDiffer):

    def __init__(self, old_content, new_content, rule_id, show_diffs, rule_diffs,
                 only_rules, output_dir):
        super(StigContentDiffer, self).__init__(old_content, new_content, rule_id,
                                                show_diffs, rule_diffs, only_rules, output_dir)

        self.context_lines = 200

    def _get_stig_id(self, element):
        return element.get_version_element().text

    def get_stig_rule_SV(self, sv_rule_id):
        stig_rule_id = re.search(r'(SV-\d+)r\d+_rule', sv_rule_id)
        if not stig_rule_id:
            print("The rule '%s' doesn't have the usual STIG format: 'SV-XXXXXXrXXXXXX_rule.\n"
                  "Please make sure the input contents are DISA STIG Benchmarks." % sv_rule_id)
            sys.exit(1)
        return stig_rule_id.group(1)

    def compare_rules(self, old_benchmark, new_benchmark):
        missing_rules = []
        try:
            rules_in_old_benchmark = self._get_rules_to_compare(old_benchmark)
            rules_in_new_benchmark = self._get_rules_to_compare(new_benchmark)
        except ValueError as e:
            print(str(e))
            return

        # The rules in STIG Benchmarks will have their IDS changed whenever there is an update.
        # However, only the release number changes, the SV number stays the same.
        # This creates map the SV numbers to their equivalent full IDs in the new Benchmark.
        new_rule_mapping = {self.get_stig_rule_SV(rule.get_attr("id")): rule.get_attr("id")
                            for rule in rules_in_new_benchmark}
        old_rule_mapping = {self.get_stig_rule_SV(rule.get_attr("id")): rule.get_attr("id")
                            for rule in rules_in_old_benchmark}

        self.compare_existing_rules(new_benchmark,
                                    old_benchmark, rules_in_old_benchmark, new_rule_mapping)

        self.check_for_new_rules(rules_in_new_benchmark, old_rule_mapping)

        if self.rule_diffs:
            print("Diff files saved at %s." % self.output_dir)

    def compare_existing_rules(self, new_benchmark, old_benchmark,
                               rules_in_old_benchmark, new_rule_mapping):
        for old_rule in rules_in_old_benchmark:
            old_sv_rule_id = self.get_stig_rule_SV(old_rule.get_attr("id"))
            old_stig_id = self._get_stig_id(old_rule)
            try:
                new_sv_rule_id = new_rule_mapping[old_sv_rule_id]
            except KeyError:
                missing_rules.append(old_sv_rule_id)
                print("%s is missing in new datastream." % old_stig_id)
                continue
            if self.only_rules:
                continue

            new_rule = new_benchmark.find_rule(new_sv_rule_id)
            new_stig_id = self._get_stig_id(new_rule)

            self.compare_rule(old_rule, new_rule, new_stig_id)
            self.compare_platforms(old_rule, new_rule,
                                   old_benchmark, new_benchmark, new_stig_id)

    def check_for_new_rules(self, rules_in_new_benchmark, old_rule_mapping):
        # Check for rules added in new content
        for new_rule in rules_in_new_benchmark:
            new_stig_id = self._get_stig_id(new_rule)
            new_sv_rule_id = self.get_stig_rule_SV(new_rule.get_attr("id"))
            try:
                old_sv_rule_id = old_rule_mapping[new_sv_rule_id]
            except KeyError:
                print("%s was added in new datastream." % (new_stig_id))

                # Compare against empty rule so that a diff is generated
                empty_rule = ssg.xml.XMLRule(ET.Element("{%s}Rule" % XCCDF12_NS))
                self.compare_rule(empty_rule, new_rule, new_stig_id)

