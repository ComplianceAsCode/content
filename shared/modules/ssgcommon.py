import datetime
import platform
import subprocess
import re


try:
    from xml.etree import cElementTree as ElementTree
except ImportError:
    import cElementTree as ElementTree


xml_version = """<?xml version="1.0" encoding="UTF-8"?>"""

datastream_namespace = "http://scap.nist.gov/schema/scap/source/1.2"
ocil_namespace = "http://scap.nist.gov/schema/ocil/2.0"
oval_footer = "</oval_definitions>"
oval_namespace = "http://oval.mitre.org/XMLSchema/oval-definitions-5"
ocil_cs = "http://scap.nist.gov/schema/ocil/2"
xccdf_header = xml_version + "<xccdf>"
xccdf_footer = "</xccdf>"
bash_system = "urn:xccdf:fix:script:sh"
ansible_system = "urn:xccdf:fix:script:ansible"
puppet_system = "urn:xccdf:fix:script:puppet"
anaconda_system = "urn:redhat:anaconda:pre"
cce_system = "https://nvd.nist.gov/cce/index.cfm"
cce_uri = "http://cce.mitre.org"
stig_ns = "http://iase.disa.mil/stigs/Pages/stig-viewing-guidance.aspx"
ssg_version_uri = \
    "https://github.com/OpenSCAP/scap-security-guide/releases/latest"
OSCAP_VENDOR = "org.ssgproject"
OSCAP_DS_STRING = "xccdf_%s.content_benchmark_" % OSCAP_VENDOR
OSCAP_GROUP = "xccdf_%s.content_group_" % OSCAP_VENDOR
OSCAP_GROUP_PCIDSS = "xccdf_%s.content_group_pcidss-req" % OSCAP_VENDOR
OSCAP_GROUP_VAL = "xccdf_%s.content_group_values" % OSCAP_VENDOR
OSCAP_GROUP_NON_PCI = "xccdf_%s.content_group_non-pci-dss" % OSCAP_VENDOR
XCCDF11_NS = "http://checklists.nist.gov/xccdf/1.1"
XCCDF12_NS = "http://checklists.nist.gov/xccdf/1.2"
min_ansible_version = "2.3"
ansible_version_requirement_pre_task_name = \
    "Verify Ansible meets SCAP-Security-Guide version requirements."

oval_header = (
    """
<oval_definitions
    xmlns="{0}"
    xmlns:oval="http://oval.mitre.org/XMLSchema/oval-common-5"
    xmlns:ind="{0}#independent"
    xmlns:unix="{0}#unix"
    xmlns:linux="{0}#linux"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://oval.mitre.org/XMLSchema/oval-common-5 oval-common-schema.xsd
        {0} oval-definitions-schema.xsd
        {0}#independent independent-definitions-schema.xsd
        {0}#unix unix-definitions-schema.xsd
        {0}#linux linux-definitions-schema.xsd">"""
    .format(oval_namespace))


timestamp = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%S")


class SSGError(RuntimeError):
    pass


def oval_generated_header(product_name, schema_version, ssg_version):
    return xml_version + oval_header + \
        """
    <generator>
        <oval:product_name>%s from SCAP Security Guide</oval:product_name>
        <oval:product_version>ssg: %s, python: %s</oval:product_version>
        <oval:schema_version>%s</oval:schema_version>
        <oval:timestamp>%s</oval:timestamp>
    </generator>""" % (product_name, ssg_version, platform.python_version(),
                       schema_version, timestamp)


def subprocess_check_output(*popenargs, **kwargs):
    # Backport of subprocess.check_output taken from
    # https://gist.github.com/edufelipe/1027906
    #
    # Originally from Python 2.7 stdlib under PSF, compatible with BSD-3
    # Copyright (c) 2003-2005 by Peter Astrand <astrand@lysator.liu.se>
    # Changes by Eduardo Felipe

    process = subprocess.Popen(stdout=subprocess.PIPE, *popenargs, **kwargs)
    output, unused_err = process.communicate()
    retcode = process.poll()
    if retcode:
        cmd = kwargs.get("args")
        if cmd is None:
            cmd = popenargs[0]
        error = subprocess.CalledProcessError(retcode, cmd)
        error.output = output
        raise error
    return output


if hasattr(subprocess, "check_output"):
    # if available we just use the real function
    subprocess_check_output = subprocess.check_output


def get_check_content_ref_if_exists_and_not_remote(check):
    """
    Given an OVAL check element, examine the ``xccdf_ns:check-content-ref``

    If it exists and it isn't remote, pass it as the return value.
    Otherwise, return None.

    ..see-also:: check_content_href_is_remote
    """
    checkcontentref = check.find("./{%s}check-content-ref" % XCCDF11_NS)
    if checkcontentref is None:
        return None
    if check_content_href_is_remote(checkcontentref):
        return None
    else:
        return checkcontentref


def check_content_href_is_remote(check_content_ref):
    """
    Given an OVAL check-content-ref element, examine the 'href' attribute.

    If it starts with 'http://' or 'https://', return True, otherwise return False.

    Raises RuntimeError if the ``href`` element doesn't exist.
    """
    hrefattr = check_content_ref.get("href")
    if hrefattr is None:
        # @href attribute of <check-content-ref> is required by XCCDF standard
        msg = "Invalid OVAL <check-content-ref> detected - missing the 'href' attribute!"
        raise RuntimeError(msg)

    return hrefattr.startswith("http://") or hrefattr.startswith("https://")


def parse_xml_file(filename):
    """
    Given a filename, return the corresponding ElementTree
    """
    with open(filename, 'r') as xml_file:
        filestring = xml_file.read()
        tree = ElementTree.fromstring(filestring)
    return tree


def cce_is_valid(cceid):
    """
    IF CCE ID IS IN VALID FORM (either 'CCE-XXXX-X' or 'CCE-XXXXX-X'
    where each X is a digit, and the final X is a check-digit)
    based on Requirement A17:

    http://people.redhat.com/swells/nist-scap-validation/scap-val-requirements-1.2.html
    """
    match = re.search(r'CCE-\d{4,5}-\d', cceid)
    return match is not None


def map_elements_to_their_ids(tree, xpath_expr):
    """
    Given an ElementTree and an XPath expression,
    iterate through matching elements and create 1:1 id->element mapping.

    Raises AssertionError if a matching element doesn't have the ``id`` attribute.

    Returns mapping as a dictionary
    """
    aggregated = {}
    for element in tree.findall(xpath_expr):
        element_id = element.get("id")
        assert element_id is not None
        aggregated[element_id] = element
    return aggregated
