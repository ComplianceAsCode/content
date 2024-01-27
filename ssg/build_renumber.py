from __future__ import absolute_import
from __future__ import print_function
import sys
import os


from .constants import (
    OSCAP_RULE, OSCAP_VALUE, oval_namespace, XCCDF12_NS, cce_uri, ocil_cs,
    ocil_namespace, OVAL_TO_XCCDF_DATATYPE_CONSTRAINTS
)
from . import utils
from .xml import parse_file, map_elements_to_their_ids
from .oval_object_model import load_oval_document, OVALDefinitionReference

from .checks import get_content_ref_if_exists_and_not_remote
from .cce import is_cce_value_valid, is_cce_format_valid
from .utils import SSGError
from .xml import ElementTree as ET

oval_ns = oval_namespace
oval_cs = oval_namespace


class FileLinker(object):
    """
    Bass class which represents the linking of checks to their identifiers.
    """

    CHECK_SYSTEM = None
    CHECK_NAMESPACE = None

    def __init__(self, translator, xccdftree, checks, output_file_name):
        self.translator = translator
        self.checks_related_to_us = self._get_related_checks(checks)
        self.fname = self._get_input_fname()
        self.tree = None
        self.linked_fname = output_file_name
        self.linked_fname_basename = os.path.basename(self.linked_fname)
        self.xccdftree = xccdftree

    def _get_related_checks(self, checks):
        """
        Returns a list of checks which have the same check system as this
        class.
        """
        return [ch for ch in checks if ch.get("system") == self.CHECK_SYSTEM]

    def _get_fnames_from_related_checks(self):
        """
        Returns a list of filenames from non-remote check content href
        attributes.
        """
        checkfiles = set()
        for check in self.checks_related_to_us:
            # Include the file in the particular check system only if it's NOT
            # a remotely located file (to allow OVAL checks to reference http://
            # and https:// formatted URLs)
            checkcontentref = get_content_ref_if_exists_and_not_remote(check)
            if checkcontentref is not None:
                checkfiles.add(checkcontentref.get("href"))
        return checkfiles

    def _get_input_fname(self):
        """
        Returns the input filename referenced from the related check.

        Raises SSGError if there are more than one filenames related to
        this check system.
        """
        fnames = self._get_fnames_from_related_checks()
        if len(fnames) > 1:
            msg = ("referencing more than one file per check system "
                   "is not yet supported by this script.")
            raise SSGError(msg)
        return fnames.pop() if fnames else None

    def save_linked_tree(self):
        """
        Write internal tree to the file in self.linked_fname.
        """
        assert self.tree is not None, \
            "There is no tree to save, you have probably skipped the linking phase"
        ET.ElementTree(self.tree).write(self.linked_fname)

    def _get_checkid_string(self):
        raise NotImplementedError()

    def add_missing_check_exports(self, check, checkcontentref):
        pass

    def link_xccdf(self):
        for check in self.checks_related_to_us:
            checkcontentref = get_content_ref_if_exists_and_not_remote(check)
            if checkcontentref is None:
                continue

            self.add_missing_check_exports(check, checkcontentref)

            checkexports = check.findall("./{%s}check-export" % XCCDF12_NS)

            self._link_xccdf_checkcontentref(checkcontentref, checkexports)

    def _link_xccdf_checkcontentref(self, checkcontentref, checkexports):
        checkid = self.translator.generate_id(
            self._get_checkid_string(), checkcontentref.get("name"))
        checkcontentref.set("name", checkid)
        checkcontentref.set("href", self.linked_fname_basename)

        variable_str = "{%s}variable" % self.CHECK_NAMESPACE
        for checkexport in checkexports:
            newexportname = self.translator.generate_id(
                variable_str, checkexport.get("export-name"))
            checkexport.set("export-name", newexportname)


class OVALFileLinker(FileLinker):
    CHECK_SYSTEM = oval_cs
    CHECK_NAMESPACE = oval_ns
    build_ovals_dir = None

    def __init__(self, translator, xccdftree, checks, output_file_name):
        super(OVALFileLinker, self).__init__(
            translator, xccdftree, checks, output_file_name)
        self.oval_document = None

    def _get_checkid_string(self):
        return "{%s}definition" % self.CHECK_NAMESPACE

    def _translate_name_to_oval_definition_id(self, name):
        return self.translator.generate_id(self._get_checkid_string(), name)

    def _get_path_for_oval_document(self, name):
        if self.build_ovals_dir:
            utils.mkdir_p(self.build_ovals_dir)
        return os.path.join(self.build_ovals_dir, name + ".xml")

    def _get_list_of_names_of_oval_checks(self):
        out = []
        for _, rule in rules_with_ids_generator(self.xccdftree):
            for check in rule.findall(".//{%s}check" % (XCCDF12_NS)):
                checkcontentref = get_content_ref_if_exists_and_not_remote(check)
                if checkcontentref is None or check.get("system") != oval_cs:
                    continue

                out.append(checkcontentref.get("name"))
        return out

    def _save_oval_document_for_each_xccdf_rule(self):
        for name in self._get_list_of_names_of_oval_checks():
            oval_id = self._translate_name_to_oval_definition_id(name)

            refs = self.oval_document.get_all_references_of_definition(oval_id)
            path = self._get_path_for_oval_document(name)
            with open(path, "wb+") as fd:
                self.oval_document.save_as_xml(fd, refs)

    def save_linked_tree(self):
        """
        Write internal tree to the file in self.linked_fname.
        """
        with open(self.linked_fname, "wb+") as fd:
            self.oval_document.save_as_xml(fd)

        if self.build_ovals_dir:
            self._save_oval_document_for_each_xccdf_rule()

    def link(self):
        self.oval_document = load_oval_document(parse_file(self.fname))
        self.oval_document.product_name = "OVALFileLinker"
        try:
            self._link_oval_tree()

            # Verify if CCE identifiers present in the XCCDF follow the required form
            # (either CCE-XXXX-X, or CCE-XXXXX-X). Drop from XCCDF those who don't follow it
            verify_correct_form_of_referenced_cce_identifiers(self.xccdftree)
        except SSGError as exc:
            raise SSGError("Error processing {0}: {1}".format(self.fname, str(exc)))

        self.oval_document = self.translator.translate_oval_document(
            self.oval_document, store_defname=True
        )

    def _link_oval_tree(self):

        self.oval_document.validate_references()

        xccdf_to_cce_id_mapping = create_xccdf_id_to_cce_id_mapping(self.xccdftree)

        self._add_cce_id_refs_to_oval_checks(xccdf_to_cce_id_mapping)

        # Verify all by XCCDF referenced (local) OVAL checks are defined in OVAL file
        # If not drop the <check-content> OVAL checksystem reference from XCCDF
        self._ensure_by_xccdf_referenced_oval_def_is_defined_in_oval_file()
        self._ensure_by_xccdf_referenced_oval_no_extra_def_in_oval_file()

        check_and_correct_xccdf_to_oval_data_export_matching_constraints(
            self.xccdftree, self.oval_document
        )

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
        for oval_definition in self.oval_document.definitions.values():
            ovalid = oval_definition.id_
            assert ovalid is not None, "An OVAL rule doesn't have an ID"

            if ovalid not in idmappingdict:
                continue

            xccdfcceid = idmappingdict[ovalid]
            if is_cce_format_valid(xccdfcceid) and is_cce_value_valid(xccdfcceid):
                # Then append the <reference source="CCE" ref_id="CCE-ID" /> element right
                # after <description> element of specific OVAL check
                oval_definition.metadata.add_reference(xccdfcceid, "CCE")

    def add_missing_check_exports(self, check, checkcontentref):
        check_name = checkcontentref.get("name")
        if check_name is None:
            return
        oval_def_id = self._translate_name_to_oval_definition_id(check_name)
        oval_def = self.oval_document.definitions.get(oval_def_id)
        if oval_def is None:
            return
        all_vars = set()
        references = self.oval_document.get_all_references_of_definition(oval_def_id)
        for var_id in references.variables:
            variable = self.oval_document.variables[var_id]
            if "external_variable" in variable.tag:
                all_vars.add(variable.name)
        for varname in sorted(all_vars):
            export = ET.Element("{%s}check-export" % XCCDF12_NS)
            export.attrib["export-name"] = varname
            export.attrib["value-id"] = OSCAP_VALUE + varname
            check.insert(0, export)

    def _ensure_by_xccdf_referenced_oval_def_is_defined_in_oval_file(self):
        # Ensure all OVAL checks referenced by XCCDF are implemented in OVAL file
        # Drop the reference from XCCDF to OVAL definition if:
        # * Particular OVAL definition isn't present in OVAL file,
        # * That OVAL definition doesn't constitute a remote OVAL
        #   (@href of <check-content-ref> doesn't start with 'http'

        for xccdfid, rule in rules_with_ids_generator(self.xccdftree):
            # Search OVAL ID in OVAL document
            ovalid = self.oval_document.definitions.get(xccdfid)
            if ovalid is not None:
                # The OVAL check was found, we can continue
                continue

            for check in rule.findall(".//{%s}check" % (XCCDF12_NS)):
                if check.get("system") != oval_cs:
                    continue

                if get_content_ref_if_exists_and_not_remote(check) is None:
                    continue

                # For local OVAL drop the reference to OVAL definition from XCCDF document
                # in the case:
                # * OVAL definition is referenced from XCCDF file,
                # * But not defined in OVAL file
                rule.remove(check)

    def _ensure_by_xccdf_referenced_oval_no_extra_def_in_oval_file(self):
        # Remove all OVAL checks that are not referenced by XCCDF Rules (checks)
        # or internally via extend-definition

        xccdf_oval_check_refs = [name for name in self._get_list_of_names_of_oval_checks()]
        document_def_keys = list(self.oval_document.definitions.keys())

        references_from_xccdf_to_keep = OVALDefinitionReference()
        for def_id in document_def_keys:
            if def_id in xccdf_oval_check_refs:
                oval_def_refs = self.oval_document.get_all_references_of_definition(def_id)
                references_from_xccdf_to_keep += oval_def_refs

        self.oval_document.keep_referenced_components(references_from_xccdf_to_keep)


class OCILFileLinker(FileLinker):
    CHECK_SYSTEM = ocil_cs
    CHECK_NAMESPACE = ocil_namespace

    def _get_checkid_string(self):
        return "{%s}questionnaire" % self.CHECK_NAMESPACE

    def link(self, tree):
        self.tree = tree
        self.tree = self.translator.translate(self.tree, store_defname=True)


def _find_identcce(rule, namespace=XCCDF12_NS):
    for ident in rule.findall("./{%s}ident" % namespace):
        if ident.get("system") == cce_uri:
            return ident
    return None


def rules_with_ids_generator(xccdftree):
    xccdfrules = xccdftree.findall(".//{%s}Rule" % XCCDF12_NS)
    for rule in xccdfrules:
        xccdfid = rule.get("id").replace(OSCAP_RULE, "")
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


def check_and_correct_xccdf_to_oval_data_export_matching_constraints(
    xccdftree, oval_document
):
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
    indexed_xccdf_values = map_elements_to_their_ids(
        xccdftree, ".//{%s}Value" % (XCCDF12_NS)
    )

    # Loop through all <external_variables> in the OVAL document
    oval_extvars = [
        var
        for var in oval_document.variables.values()
        if "external_variable" in var.tag
    ]

    for oval_extvar in oval_extvars:

        oval_var_id = oval_extvar.id_
        oval_var_type = oval_extvar.data_type

        # Locate the corresponding <xccdf:Value> with the same ID in the XCCDF
        xccdf_var = indexed_xccdf_values.get(oval_var_id)

        if xccdf_var is None:
            return

        xccdf_var_type = xccdf_var.get("type")
        # Verify the found value has 'type' attribute set
        if xccdf_var_type is None:
            msg = "Invalid XCCDF variable '{0}': Missing the 'type' attribute.".format(
                xccdf_var.get("id")
            )
            raise SSGError(msg)

        # This is the required XCCDF 'type' for <xccdf:Value> derived
        # from OVAL variable 'datatype' and mapping above
        assert (
            oval_var_type in OVAL_TO_XCCDF_DATATYPE_CONSTRAINTS
        ), 'datatype not known: "%s" "%s known types "%s"' % (
            oval_var_id,
            oval_var_type,
            OVAL_TO_XCCDF_DATATYPE_CONSTRAINTS,
        )
        req_xccdf_type = OVAL_TO_XCCDF_DATATYPE_CONSTRAINTS[oval_var_type]
        # Compare the actual value of 'type' of <xccdf:Value> with the requirement
        if xccdf_var_type != req_xccdf_type:
            # If discrepancy is found, issue a warning
            sys.stderr.write(
                "Warning: XCCDF 'type' of \"%s\" value does "
                "not meet the XCCDF value 'type' to OVAL "
                "variable 'datatype' export matching "
                'constraint! Got: "%s", Expected: "%s". '
                "Resetting it! Set 'type' of \"%s\" "
                "<xccdf:value> to '%s' directly in the XCCDF "
                "content to dismiss this warning!\n"
                % (
                    oval_var_id,
                    xccdf_var_type,
                    req_xccdf_type,
                    oval_var_id,
                    req_xccdf_type,
                )
            )
            # And reset the 'type' attribute of such a <xccdf:Value> to the required type
            xccdf_var.attrib["type"] = req_xccdf_type


def verify_correct_form_of_referenced_cce_identifiers(xccdftree):
    """
    In SSG benchmarks, the CCEs till unassigned have the form of e.g. "RHEL7-CCE-TBD"
    (or any other format possibly not matching the above two requirements)

    If this is the case for specific SSG product, drop such CCE identifiers from the XCCDF
    since they are in invalid format!
    """
    xccdfrules = xccdftree.findall(".//{%s}Rule" % XCCDF12_NS)
    for rule in xccdfrules:
        identcce = _find_identcce(rule)
        if identcce is None:
            continue
        cceid = identcce.text
        if not is_cce_format_valid(cceid):
            msg = (
                "Warning: CCE '{0}' is invalid for rule '{1}'. "
                "Removing CCE...".format(cceid, rule.get("id")))
            raise SSGError(msg)
