from __future__ import absolute_import
from __future__ import print_function
import sys


from .constants import oval_namespace, XCCDF11_NS, cce_uri, ocil_cs, ocil_namespace
from .constants import OVAL_TO_XCCDF_DATATYPE_CONSTRAINTS
from .parse_oval import resolve_definition, find_extending_defs, get_container_groups
from .xml import parse_file, map_elements_to_their_ids


from .checks import get_content_ref_if_exists_and_not_remote, is_cce_value_valid, is_cce_format_valid
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

    def __init__(self, translator, xccdftree, checks):
        self.translator = translator
        self.checks_related_to_us = self._get_related_checks(checks)
        self.fname = self._get_input_fname()
        self.tree = None
        self.linked_fname = self.fname.replace("unlinked", "linked")
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

            checkexports = check.findall("./{%s}check-export" % XCCDF11_NS)

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

    def __init__(self, translator, xccdftree, checks):
        super(OVALFileLinker, self).__init__(translator, xccdftree, checks)
        self.oval_groups = None

    def _get_checkid_string(self):
        return "{%s}definition" % self.CHECK_NAMESPACE

    def link(self):
        self.oval_groups = get_container_groups(self.fname)
        self.tree = parse_file(self.fname)
        try:
            self._link_oval_tree()

            # Verify if CCE identifiers present in the XCCDF follow the required form
            # (either CCE-XXXX-X, or CCE-XXXXX-X). Drop from XCCDF those who don't follow it
            verify_correct_form_of_referenced_cce_identifiers(self.xccdftree)
        except SSGError as exc:
            raise SSGError(
                "Error processing {0}: {1}"
                .format(self.fname, str(exc)))
        self.tree = self.translator.translate(self.tree, store_defname=True)

    def _link_oval_tree(self):
        xccdf_to_cce_id_mapping = create_xccdf_id_to_cce_id_mapping(self.xccdftree)

        indexed_oval_defs = map_elements_to_their_ids(
            self.tree, ".//{0}".format(self._get_checkid_string()))

        drop_oval_checks_extending_non_existing_checks(
            self.tree, self.oval_groups, indexed_oval_defs)

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

            if ovalid not in idmappingdict:
                continue

            ovaldesc = rule.find(".//{%s}description" % self.CHECK_NAMESPACE)
            assert ovaldesc is not None, \
                "OVAL rule '{0}' doesn't have a description, which is mandatory".format(ovalid)

            xccdfcceid = idmappingdict[ovalid]
            if is_cce_format_valid(xccdfcceid) and is_cce_value_valid(xccdfcceid):
                # Then append the <reference source="CCE" ref_id="CCE-ID" /> element right
                # after <description> element of specific OVAL check
                ccerefelem = ET.Element('{%s}reference' % self.CHECK_NAMESPACE, ref_id=xccdfcceid,
                                        source="CCE")
                metadata = rule.find(".//{%s}metadata" % self.CHECK_NAMESPACE)
                metadata.append(ccerefelem)

    def get_nested_definitions(self, oval_def_id):
        processed_def_ids = set()
        queue = set([oval_def_id])
        while queue:
            def_id = queue.pop()
            processed_def_ids.add(def_id)
            definition_tree = self.oval_groups["definitions"].get(def_id)
            if definition_tree is None:
                print("WARNING: Definition '%s' was not found, can't figure "
                      "out what depends on it." % (def_id), file=sys.stderr)
                continue
            extensions = find_extending_defs(self.oval_groups, definition_tree)
            if not extensions:
                continue
            queue |= extensions - processed_def_ids
        return processed_def_ids

    def add_missing_check_exports(self, check, checkcontentref):
        check_name = checkcontentref.get("name")
        if check_name is None:
            return
        oval_def = self.oval_groups["definitions"].get(check_name)
        if oval_def is None:
            return
        all_vars = set()
        for def_id in self.get_nested_definitions(check_name):
            extended_def = self.oval_groups["definitions"].get(def_id)
            if extended_def is None:
                print("WARNING: Definition '%s' was not found, can't figure "
                      "out which variables it needs." % (def_id), file=sys.stderr)
                continue
            all_vars |= resolve_definition(self.oval_groups, extended_def)
        for varname in all_vars:
            export = ET.Element("{%s}check-export" % XCCDF11_NS)
            export.attrib["export-name"] = varname
            export.attrib["value-id"] = varname
            check.insert(0, export)

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

            for check in rule.findall(".//{%s}check" % (XCCDF11_NS)):
                if check.get("system") != oval_cs:
                    continue

                if get_content_ref_if_exists_and_not_remote(check) is None:
                    continue

                # For local OVAL drop the reference to OVAL definition from XCCDF document
                # in the case:
                # * OVAL definition is referenced from XCCDF file,
                # * But not defined in OVAL file
                rule.remove(check)


class OCILFileLinker(FileLinker):
    CHECK_SYSTEM = ocil_cs
    CHECK_NAMESPACE = ocil_namespace

    def _get_checkid_string(self):
        return "{%s}questionnaire" % self.CHECK_NAMESPACE

    def link(self):
        self.tree = parse_file(self.fname)
        self.tree = self.translator.translate(self.tree, store_defname=True)


def _find_identcce(rule):
    for ident in rule.findall("./{%s}ident" % XCCDF11_NS):
        if ident.get("system") == cce_uri:
            return ident
    return None


def rules_with_ids_generator(xccdftree):
    xccdfrules = xccdftree.findall(".//{%s}Rule" % XCCDF11_NS)
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


def drop_oval_checks_extending_non_existing_checks(ovaltree, oval_groups, indexed_oval_defs):
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
        del oval_groups["definitions"][definition.get("id")]
        del indexed_oval_defs[definition.get("id")]
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
    indexed_xccdf_values = map_elements_to_their_ids(
        xccdftree, ".//{%s}Value" % (XCCDF11_NS))

    # Loop through all <external_variables> in the OVAL document
    ovalextvars = ovaltree.findall(".//{%s}external_variable" % oval_ns)
    if ovalextvars is None:
        return

    for ovalextvar in ovalextvars:
        # Verify the found external variable has both 'id' and 'datatype' set
        if 'id' not in ovalextvar.attrib or 'datatype' not in ovalextvar.attrib:
            msg = "Invalid OVAL <external_variable> found - either without 'id' or 'datatype'."
            raise SSGError(msg)

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
            raise SSGError(msg)

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
                "content to dismiss this warning!\n" %
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
    xccdfrules = xccdftree.findall(".//{%s}Rule" % XCCDF11_NS)
    for rule in xccdfrules:
        identcce = _find_identcce(rule)
        if identcce is not None:
            cceid = identcce.text
            if not is_cce_format_valid(cceid):
                print("Warning: CCE '{0}' is invalid for rule '{1}'. Removing CCE..."
                      .format(cceid, rule.get("id"), file=sys.stderr))
                rule.remove(identcce)
                sys.exit(1)


def assert_that_check_ids_match_rule_id(checks, xccdf_rule):
    for check in checks:
        check_name = check.get("name")
        # Verify match of XCCDF vs OVAL / OCIL IDs for
        # * the case of OVAL <check>
        # * the case of OCIL <check>
        if (xccdf_rule != check_name and check_name is not None and
                xccdf_rule + '_ocil' != check_name and
                xccdf_rule != 'sample_rule'):
            msg_lines = ["The OVAL / OCIL ID does not match the XCCDF Rule ID!"]
            if '_ocil' in check_name:
                id_name = "OCIL ID"
            else:
                id_name = "OVAL ID"
            msg_lines.append(" {0:>14}: {1}".format(id_name, check_name))
            msg_lines.append(" {0:>14}: {1}".format("XCCDF Rule ID", xccdf_rule))
            raise SSGError("\n".join(msg_lines))


def check_that_oval_and_rule_id_match(xccdftree):
    for xccdfid, rule in rules_with_ids_generator(xccdftree):
        checks = rule.find("./{%s}check" % XCCDF11_NS)
        if checks is None:
            print("Rule {0} doesn't have checks."
                  .format(xccdfid), file=sys.stderr)
            continue

        assert_that_check_ids_match_rule_id(checks, xccdfid)
