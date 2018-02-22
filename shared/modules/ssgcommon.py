import datetime
import platform
import subprocess


xml_version = """<?xml version="1.0" encoding="UTF-8"?>"""
oval_header = """
<oval_definitions
    xmlns="http://oval.mitre.org/XMLSchema/oval-definitions-5"
    xmlns:oval="http://oval.mitre.org/XMLSchema/oval-common-5"
    xmlns:ind="http://oval.mitre.org/XMLSchema/oval-definitions-5#independent"
    xmlns:unix="http://oval.mitre.org/XMLSchema/oval-definitions-5#unix"
    xmlns:linux="http://oval.mitre.org/XMLSchema/oval-definitions-5#linux"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://oval.mitre.org/XMLSchema/oval-common-5 oval-common-schema.xsd
        http://oval.mitre.org/XMLSchema/oval-definitions-5 oval-definitions-schema.xsd
        http://oval.mitre.org/XMLSchema/oval-definitions-5#independent independent-definitions-schema.xsd
        http://oval.mitre.org/XMLSchema/oval-definitions-5#unix unix-definitions-schema.xsd
        http://oval.mitre.org/XMLSchema/oval-definitions-5#linux linux-definitions-schema.xsd">"""

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


timestamp = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%S")


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
