#!/usr/bin/env python2

from __future__ import print_function

import sys
import os

import argparse

# Put shared python modules in path
sys.path.insert(0, os.path.join(
        os.path.dirname(os.path.dirname(os.path.realpath(__file__))),
        "modules"))
import idtranslate_module as idtranslate
import ssgcommon

# This script requires two arguments: an "unlinked" XCCDF file and an ID name
# scheme. This script is designed to convert and synchronize check IDs
# referenced from the XCCDF document for the supported checksystems, which are
# currently OVAL and OCIL.  The IDs are to be converted from strings to
# meaningless numbers.


oval_ns = ssgcommon.oval_namespace
oval_cs = ssgcommon.oval_namespace
xccdf_ns = ssgcommon.XCCDF11_NS
cce_uri = ssgcommon.cce_uri


OVAL_TO_XCCDF_DATATYPE_CONSTRAINTS = {
    'int': 'number',
    'float': 'number',
    'boolean': 'boolean',
    'string': 'string',
    'evr_string': 'string',
    'version': 'string',
    'ios_version': 'string',
    'fileset_revision': 'string',
    'binary': 'string'
}


class FileLinker(object):
    CHECK_SYSTEM = None
    CHECK_NAMESPACE = None

    def __init__(self, translator, xccdftree, checks):
        self.translator = translator
        self.checks_related_to_us = self._get_related_checks(checks)
        self.fname = self._get_input_fname()
        self.tree = None
        self.linked_fname = self.fname.replace("unlinked", "linked")
        self.xccdftree = xccdftree

    def _get_related_checks(self, checks):
        return [ch for ch in checks if ch.get("system") == self.CHECK_SYSTEM]

    def _get_fnames_from_related_checks(self):
        checkfiles = set()
        for check in self.checks_related_to_us:
            # Include the file in the particular check system only if it's NOT
            # a remotely located file (to allow OVAL checks to reference http://
            # and https:// formatted URLs)
            checkcontentref = ssgcommon.get_check_content_ref_if_exists_and_not_remote(check)
            if checkcontentref is not None:
                checkfiles.add(checkcontentref.get("href"))
        return checkfiles

    def _get_input_fname(self):
        fnames = self._get_fnames_from_related_checks()
        if len(fnames) > 1:
            msg = ("referencing more than one file per check system "
                   "is not yet supported by this script.")
            raise ssgcommon.SSGError(msg)
        return fnames.pop() if fnames else None

    def save_linked_tree(self):
        assert self.tree is not None, \
            "There is no tree to save, you have probably skipped the linking phase"
        ssgcommon.ElementTree.ElementTree(self.tree).write(self.linked_fname)

    def _get_checkid_string(self):
        raise NotImplementedError()

    def link_xccdf(self):
        for check in self.checks_related_to_us:
            checkcontentref = ssgcommon.get_check_content_ref_if_exists_and_not_remote(check)
            if checkcontentref is None:
                continue

            checkexports = check.findall("./{%s}check-export" % xccdf_ns)

            self._link_xccdf_checkcontentref(checkcontentref, checkexports)

    def _link_xccdf_checkcontentref(self, checkcontentref, checkexports):
        checkid = self.translator.generate_id(
            self._get_checkid_string(), checkcontentref.get("name"))
        checkcontentref.set("name", checkid)
        checkcontentref.set("href", self.linked_fname)

        variable_str = "{%s}variable" % self.CHECK_NAMESPACE
        for checkexport in checkexports:
            newexportname = self.translator.generate_id(
                variable_str, checkexport.get("export-name"))
            checkexport.set("export-name", newexportname)


class OVALFileLinker(FileLinker):
    CHECK_SYSTEM = oval_cs
    CHECK_NAMESPACE = oval_ns

    def _get_checkid_string(self):
        return "{%s}definition" % self.CHECK_NAMESPACE

    def link(self):
        self.tree = ssgcommon.parse_xml_file(self.fname)
        try:
            self._link_oval_tree()

            # Verify if CCE identifiers present in the XCCDF follow the required form
            # (either CCE-XXXX-X, or CCE-XXXXX-X). Drop from XCCDF those who don't follow it
            verify_correct_form_of_referenced_cce_identifiers(self.xccdftree)
        except ssgcommon.SSGError as exc:
            raise ssgcommon.SSGError(
                "Error processing {0}: {1}"
                .format(self.fname, str(exc)))
        self.tree = self.translator.translate(self.tree, store_defname=True)

    def _link_oval_tree(self):
        xccdf_to_cce_id_mapping = create_xccdf_id_to_cce_id_mapping(self.xccdftree)

        indexed_oval_defs = ssgcommon.map_elements_to_their_ids(
            self.tree, ".//{0}".format(self._get_checkid_string()))

        drop_oval_checks_extending_non_existing_checks(
            self.tree, indexed_oval_defs)

        self._add_cce_id_refs_to_oval_checks(xccdf_to_cce_id_mapping)

        # Verify all by XCCDF referenced (local) OVAL checks are defined in OVAL file
        # If not drop the <check-content> OVAL checksystem reference from XCCDF
        self._ensure_by_xccdf_referenced_oval_def_is_defined_in_oval_file(
            indexed_oval_defs)

        check_and_correct_xccdf_to_oval_data_export_matching_constraints(self.xccdftree, self.tree)

    def _add_cce_id_refs_to_oval_checks(self, idmappingdict):
        """
        For each XCCDF rule ID having <ident> CCE set and
        having OVAL check implemented (remote OVAL isn't sufficient!)
        add a new <reference> element into the OVAL definition having the
        following form:

        <reference source="CCE" ref_id="CCE-ID" />

        where "CCE-ID" is the CCE identifier for that particular rule
        retrieved from the XCCDF file
        """
        ovalrules = self.tree.findall(".//{0}".format(self._get_checkid_string()))
        for rule in ovalrules:
            ovalid = rule.get("id")
            assert ovalid is not None, \
                "An OVAL rule doesn't have an ID"

            ovaldesc = rule.find(".//{%s}description" % self.CHECK_NAMESPACE)
            assert ovaldesc is not None, \
                "OVAL rule '{0}' doesn't have a description, which is mandatory".format(ovalid)

            if ovalid not in idmappingdict:
                print("OVAL ID '{0}' has not XCCDF rule ID <ident> CCE set"
                      .format(ovalid), file=sys.stderr)
                continue

            xccdfcceid = idmappingdict[ovalid]
            if not ssgcommon.cce_is_valid(xccdfcceid):
                msg = "The CCE ID {0} is not in valid form.".format(xccdfcceid)
                raise ssgcommon.SSGError(msg)

            # Then append the <reference source="CCE" ref_id="CCE-ID" /> element right
            # after <description> element of specific OVAL check
            ccerefelem = ssgcommon.ElementTree.Element(
                'reference', ref_id=xccdfcceid, source="CCE")
            ovaldesc.addnext(ccerefelem)
            # Sanity check if appending succeeded
            if ccerefelem.getprevious() is not ovaldesc:
                msg = "Failed to add CCE ID to {0}.".format(ovalid)
                raise ssgcommon.SSGError(msg)

    def _ensure_by_xccdf_referenced_oval_def_is_defined_in_oval_file(
            self, indexed_oval_defs):
        # Ensure all OVAL checks referenced by XCCDF are implemented in OVAL file
        # Drop the reference from XCCDF to OVAL definition if:
        # * Particular OVAL definition isn't present in OVAL file,
        # * That OVAL definition doesn't constitute a remote OVAL
        #   (@href of <check-content-ref> doesn't start with 'http'

        for xccdfid, rule in rules_with_ids_generator(self.xccdftree):
            # Search OVAL ID in OVAL document
            ovalid = indexed_oval_defs.get(xccdfid)
            if ovalid is not None:
                # The OVAL check was found, we can continue
                continue

            for check in rule.findall(".//{%s}check" % (xccdf_ns)):
                if check.get("system") != oval_cs:
                    continue

                if ssgcommon.get_check_content_ref_if_exists_and_not_remote(check) is None:
                    continue

                # For local OVAL drop the reference to OVAL definition from XCCDF document
                # in the case:
                # * OVAL definition is referenced from XCCDF file,
                # * But not defined in OVAL file
                print("WARNING: OVAL check '{0}' was not found, removing "
                      "<check-content> element from the XCCDF rule."
                      .format(xccdfid), file=sys.stderr)
                rule.remove(check)


class OCILFileLinker(FileLinker):
    CHECK_SYSTEM = ssgcommon.ocil_cs
    CHECK_NAMESPACE = ssgcommon.ocil_namespace

    def _get_checkid_string(self):
        return "{%s}questionnaire" % self.CHECK_NAMESPACE

    def link(self):
        self.tree = ssgcommon.parse_xml_file(self.fname)
        self.tree = self.translator.translate(self.tree, store_defname=True)


def _find_identcce(rule):
    for ident in rule.findall("./{%s}ident" % xccdf_ns):
        if ident.get("system") == cce_uri:
            return ident
    return None


def rules_with_ids_generator(xccdftree):
    xccdfrules = xccdftree.findall(".//{%s}Rule" % xccdf_ns)
    for rule in xccdfrules:
        xccdfid = rule.get("id")
        if xccdfid is None:
            continue
        yield xccdfid, rule


def create_xccdf_id_to_cce_id_mapping(xccdftree):
    #
    # Create dictionary having form of
    #
    # 'XCCDF ID' : 'CCE ID'
    #
    # for each XCCDF rule having <ident system='http://cce.mitre.org'>CCE-ID</ident>
    # element set in the XCCDF document
    xccdftocce_idmapping = {}

    for xccdfid, rule in rules_with_ids_generator(xccdftree):
        identcce = _find_identcce(rule)
        if identcce is None:
            continue

        xccdftocce_idmapping[xccdfid] = identcce.text

    return xccdftocce_idmapping


def get_nonexisting_check_definition_extends(definition, indexed_oval_defs):
    # TODO: handle multiple levels of referrals.
    # OVAL checks that go beyond one level of extend_definition won't be properly identified
    for extdefinition in definition.findall(".//{%s}extend_definition" % oval_ns):
        # Verify each extend_definition in the definition
        extdefinitionref = extdefinition.get("definition_ref")

        # Search the OVAL tree for a definition with the referred ID
        referreddefinition = indexed_oval_defs.get(extdefinitionref)

        if referreddefinition is None:
            # There is no oval satisfying the extend_definition referal
            return extdefinitionref
    return None


def drop_oval_checks_extending_non_existing_checks(ovaltree, indexed_oval_defs):
    # Incomplete OVAL checks are as useful as non existing checks
    # Here we check if all extend_definition refs from a definition exists in local OVAL file
    definitions = ovaltree.find(".//{%s}definitions" % oval_ns)
    defstoremove = set()
    for definition in definitions:
        nonexisting_ref = get_nonexisting_check_definition_extends(definition, indexed_oval_defs)
        if nonexisting_ref is not None:
            print("WARNING: OVAL definition '{0}' extends non-existing '{1}', "
                  "removing it from OVAL definitions."
                  .format(definition.get("id"), nonexisting_ref),
                  file=sys.stderr)
            defstoremove.add(definition)

    for definition in defstoremove:
        definitions.remove(definition)


def check_and_correct_xccdf_to_oval_data_export_matching_constraints(xccdftree, ovaltree):
    """
    Verify if <xccdf:Value> 'type' to corresponding OVAL variable
    'datatype' export matching constraint:

    http://csrc.nist.gov/publications/nistpubs/800-126-rev2/SP800-126r2.pdf#page=30&zoom=auto,69,313

    is met. Also correct the 'type' attribute of those <xccdf:Value> elements where necessary
    in order the produced content to meet this constraint.

    To correct the constraint we use simpler approach - prefer to fix
    'type' attribute of <xccdf:Value> rather than 'datatype' attribute
    of the corresponding OVAL variable since there might be additional
    OVAL variables, derived from the affected OVAL variable, and in that
    case we would need to fix the 'datatype' attribute in each of them.

    Define the <xccdf:Value> 'type' to OVAL variable 'datatype' export matching
    constraints mapping as specified in Table 16 of XCCDF v1.2 standard:

    http://csrc.nist.gov/publications/nistpubs/800-126-rev2/SP800-126r2.pdf#page=30&zoom=auto,69,313
    """
    indexed_xccdf_values = ssgcommon.map_elements_to_their_ids(
        xccdftree, ".//{%s}Value" % (xccdf_ns))

    # Loop through all <external_variables> in the OVAL document
    ovalextvars = ovaltree.findall(".//{%s}external_variable" % oval_ns)
    if ovalextvars is None:
        return

    for ovalextvar in ovalextvars:
        # Verify the found external variable has both 'id' and 'datatype' set
        if 'id' not in ovalextvar.attrib or 'datatype' not in ovalextvar.attrib:
            msg = "Invalid OVAL <external_variable> found - either without 'id' or 'datatype'."
            raise ssgcommon.SSGError(msg)

        ovalvarid = ovalextvar.get('id')
        ovalvartype = ovalextvar.get('datatype')

        # Locate the corresponding <xccdf:Value> with the same ID in the XCCDF
        xccdfvar = indexed_xccdf_values.get(ovalvarid)

        if xccdfvar is None:
            return

        xccdfvartype = xccdfvar.get('type')
        # Verify the found value has 'type' attribute set
        if xccdfvartype is None:
            msg = (
                "Invalid XCCDF variable '{0}': Missing the 'type' attribute."
                .format(xccdfvar.attrib("id")))
            raise ssgcommon.SSGError(msg)

        # This is the required XCCDF 'type' for <xccdf:Value> derived
        # from OVAL variable 'datatype' and mapping above
        reqxccdftype = OVAL_TO_XCCDF_DATATYPE_CONSTRAINTS[ovalvartype]
        # Compare the actual value of 'type' of <xccdf:Value> with the requirement
        if xccdfvartype != reqxccdftype:
            # If discrepancy is found, issue a warning
            sys.stderr.write(
                "Warning: XCCDF 'type' of \"%s\" value does "
                "not meet the XCCDF value 'type' to OVAL "
                "variable 'datatype' export matching "
                "constraint! Got: \"%s\", Expected: \"%s\". "
                "Resetting it! Set 'type' of \"%s\" "
                "<xccdf:value> to '%s' directly in the XCCDF "
                "content to dismiss this warning!" %
                (ovalvarid, xccdfvartype, reqxccdftype,
                 ovalvarid, reqxccdftype)
            )
            # And reset the 'type' attribute of such a <xccdf:Value> to the required type
            xccdfvar.attrib['type'] = reqxccdftype


def verify_correct_form_of_referenced_cce_identifiers(xccdftree):
    """
    In SSG benchmarks, the CCEs till unassigned have the form of e.g. "RHEL7-CCE-TBD"
    (or any other format possibly not matching the above two requirements)

    If this is the case for specific SSG product, drop such CCE identifiers from the XCCDF
    since they are in invalid format!
    """
    xccdfrules = xccdftree.findall(".//{%s}Rule" % xccdf_ns)
    for rule in xccdfrules:
        identcce = _find_identcce(rule)
        if identcce is None:
            continue

        cceid = identcce.text
        if not ssgcommon.cce_is_valid(cceid):
            msg = "The CCE ID {0} is not in valid form.".format(cceid)
            raise ssgcommon.SSGError(msg)


def create_parser():
    parser = argparse.ArgumentParser(
        description="This script finds check-content files (currently, "
        "OVAL and OCIL) referenced from XCCDF and synchronizes all IDs.")
    parser.add_argument("xccdf_file")
    parser.add_argument("id_name", help="ID naming scheme")
    return parser


def assert_that_check_ids_match_rule_id(checks, xccdf_rule):
    for check in checks:
        check_name = check.get("name")
        # Verify match of XCCDF vs OVAL / OCIL IDs for
        # * the case of OVAL <check>
        # * the case of OCIL <check>
        if (xccdf_rule != check_name
                and check_name is not None
                and xccdf_rule + '_ocil' != check_name
                and xccdf_rule != 'sample_rule'):
            msg_lines = ["The OVAL / OCIL ID does not match the XCCDF Rule ID!"]
            if '_ocil' in check_name:
                id_name = "OCIL ID"
            else:
                id_name = "OVAL ID"
            msg_lines.append(" {0:>14}: {1}".format(id_name, check_name))
            msg_lines.append(" {0:>14}: {1}".format("XCCDF Rule ID", xccdf_rule))
            raise ssgcommon.SSGError("\n".join(msg_lines))


def check_that_oval_and_rule_id_match(xccdftree):
    for xccdfid, rule in rules_with_ids_generator(xccdftree):
        checks = rule.find("./{%s}check" % xccdf_ns)
        if checks is None:
            print("Rule {0} doesn't have checks."
                  .format(xccdfid), file=sys.stderr)
            continue

        assert_that_check_ids_match_rule_id(checks, xccdfid)


def main():
    parser = create_parser()
    args = parser.parse_args()
    xccdffile = args.xccdf_file
    idname = args.id_name

    # Step over xccdf file, and find referenced check files
    xccdftree = ssgcommon.parse_xml_file(xccdffile)

    if 'unlinked-ocilref' not in xccdffile:
        check_that_oval_and_rule_id_match(xccdftree)

    checks = xccdftree.findall(".//{%s}check" % xccdf_ns)

    translator = idtranslate.IDTranslator(idname)

    oval_linker = OVALFileLinker(translator, xccdftree, checks)
    oval_linker.link()
    oval_linker.save_linked_tree()
    oval_linker.link_xccdf()

    ocil_linker = OCILFileLinker(translator, xccdftree, checks)
    ocil_linker.link()
    ocil_linker.save_linked_tree()
    ocil_linker.link_xccdf()

    newxccdffile = xccdffile.replace("unlinked", "linked")
    ssgcommon.ElementTree.ElementTree(xccdftree).write(newxccdffile)
    sys.exit(0)


if __name__ == "__main__":
    try:
        main()
    except ssgcommon.SSGError as exc:
        raise
