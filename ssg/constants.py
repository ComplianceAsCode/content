from __future__ import absolute_import
from __future__ import print_function

import datetime
import os.path

product_directories = ['debian8', 'fedora', 'ol7', 'ol8', 'opensuse', 'rhel6',
                       'rhel7', 'rhel8', 'sle11', 'sle12', 'ubuntu1404',
                       'ubuntu1604', 'ubuntu1804', 'wrlinux8', 'wrlinux1019', 'rhosp13',
                       'chromium', 'eap6', 'firefox', 'fuse6', 'jre', 'ocp3',
                       'example']

JINJA_MACROS_BASE_DEFINITIONS = os.path.join(os.path.dirname(os.path.dirname(
    __file__)), "shared", "macros.jinja")
JINJA_MACROS_HIGHLEVEL_DEFINITIONS = os.path.join(os.path.dirname(os.path.dirname(
    __file__)), "shared", "macros-highlevel.jinja")
JINJA_MACROS_ANSIBLE_DEFINITIONS = os.path.join(os.path.dirname(os.path.dirname(
    __file__)), "shared", "macros-ansible.jinja")
JINJA_MACROS_OVAL_DEFINITIONS = os.path.join(os.path.dirname(os.path.dirname(
    __file__)), "shared", "macros-oval.jinja")

xml_version = """<?xml version="1.0" encoding="UTF-8"?>"""

datastream_namespace = "http://scap.nist.gov/schema/scap/source/1.2"
ocil_namespace = "http://scap.nist.gov/schema/ocil/2.0"
oval_footer = "</oval_definitions>"
oval_namespace = "http://oval.mitre.org/XMLSchema/oval-definitions-5"
xlink_namespace = "http://www.w3.org/1999/xlink"
cat_namespace = "urn:oasis:names:tc:entity:xmlns:xml:catalog"
ocil_cs = "http://scap.nist.gov/schema/ocil/2"
xccdf_header = xml_version + "<xccdf>"
xccdf_footer = "</xccdf>"
bash_system = "urn:xccdf:fix:script:sh"
ansible_system = "urn:xccdf:fix:script:ansible"
puppet_system = "urn:xccdf:fix:script:puppet"
anaconda_system = "urn:redhat:anaconda:pre"
cce_uri = "https://nvd.nist.gov/cce/index.cfm"
stig_ns = "https://public.cyber.mil/stigs/srg-stig-tools/"
stig_refs = 'https://public.cyber.mil/stigs/'
disa_cciuri = "https://public.cyber.mil/stigs/cci/"
ssg_version_uri = \
    "https://github.com/OpenSCAP/scap-security-guide/releases/latest"
OSCAP_VENDOR = "org.ssgproject"
OSCAP_DS_STRING = "xccdf_%s.content_benchmark_" % OSCAP_VENDOR
OSCAP_PROFILE = "xccdf_%s.content_profile_" % OSCAP_VENDOR
OSCAP_GROUP = "xccdf_%s.content_group_" % OSCAP_VENDOR
OSCAP_RULE = "xccdf_%s.content_rule_" % OSCAP_VENDOR
OSCAP_GROUP_PCIDSS = "xccdf_%s.content_group_pcidss-req" % OSCAP_VENDOR
OSCAP_GROUP_VAL = "xccdf_%s.content_group_values" % OSCAP_VENDOR
OSCAP_GROUP_NON_PCI = "xccdf_%s.content_group_non-pci-dss" % OSCAP_VENDOR
OSCAP_PATH = "oscap"
XCCDF11_NS = "http://checklists.nist.gov/xccdf/1.1"
XCCDF12_NS = "http://checklists.nist.gov/xccdf/1.2"
min_ansible_version = "2.5"
ansible_version_requirement_pre_task_name = \
    "Verify Ansible meets SCAP-Security-Guide version requirements."
standard_profiles = ['standard', 'pci-dss', 'desktop', 'server']

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

PKG_MANAGER_TO_SYSTEM = {
    "yum": "rpm",
    "zypper": "rpm",
    "dnf": "rpm",
    "apt_get": "dpkg",
}

PKG_MANAGER_TO_CONFIG_FILE = {
    "yum": "/etc/yum.conf",
    "dnf": "/etc/dnf/dnf.conf",
}

FULL_NAME_TO_PRODUCT_MAPPING = {
    "Chromium": "chromium",
    "Debian 8": "debian8",
    "JBoss EAP 6": "eap6",
    "Example": "example",
    "Fedora": "fedora",
    "Firefox": "firefox",
    "JBoss Fuse 6": "fuse6",
    "Java Runtime Environment": "jre",
    "Red Hat OpenShift Container Platform 3": "ocp3",
    "Oracle Linux 7": "ol7",
    "Oracle Linux 8": "ol8",
    "openSUSE": "opensuse",
    "Red Hat Enterprise Linux 6": "rhel6",
    "Red Hat Enterprise Linux 7": "rhel7",
    "Red Hat Enterprise Linux 8": "rhel8",
    "Red Hat OpenStack Platform 13": "rhosp13",
    "Red Hat Virtualization 4": "rhv4",
    "SUSE Linux Enterprise 11": "sle11",
    "SUSE Linux Enterprise 12": "sle12",
    "Ubuntu 14.04": "ubuntu1404",
    "Ubuntu 16.04": "ubuntu1604",
    "Ubuntu 18.04": "ubuntu1804",
    "WRLinux 8": "wrlinux8",
    "WRLinux 1019": "wrlinux1019",
}

PRODUCT_TO_CPE_MAPPING = {
    "chromium": [
        "cpe:/a:google:chromium-browser",
    ],
    "debian8": [
        "cpe:/o:debianproject:debian:8",
    ],
    "eap6": [
        "cpe:/a:redhat:jboss_enterprise_application_platform:6.0.0",
        "cpe:/a:redhat:jboss_enterprise_application_platform:6.0.1",
        "cpe:/a:redhat:jboss_enterprise_application_platform:6.1.0",
        "cpe:/a:redhat:jboss_enterprise_application_platform:6.1.1",
        "cpe:/a:redhat:jboss_enterprise_application_platform:6.2.0",
        "cpe:/a:redhat:jboss_enterprise_application_platform:6.2.1",
        "cpe:/a:redhat:jboss_enterprise_application_platform:6.2.2",
        "cpe:/a:redhat:jboss_enterprise_application_platform:6.2.3",
        "cpe:/a:redhat:jboss_enterprise_application_platform:6.2.4",
        "cpe:/a:redhat:jboss_enterprise_application_platform:6.3.0",
        "cpe:/a:redhat:jboss_enterprise_application_platform:6.3.1",
        "cpe:/a:redhat:jboss_enterprise_application_platform:6.3.2",
        "cpe:/a:redhat:jboss_enterprise_application_platform:6.3.3",
        "cpe:/a:redhat:jboss_enterprise_application_platform:6.4.0",
        "cpe:/a:redhat:jboss_enterprise_application_platform:6.4.1",
        "cpe:/a:redhat:jboss_enterprise_application_platform:6.4.2",
        "cpe:/a:redhat:jboss_enterprise_application_platform:6.4.3",
        "cpe:/a:redhat:jboss_enterprise_application_platform:6.4.4",
        "cpe:/a:redhat:jboss_enterprise_application_platform:6.4.5",
        "cpe:/a:redhat:jboss_enterprise_application_platform:6.4.6",
        "cpe:/a:redhat:jboss_enterprise_application_platform:6.4.7",
        "cpe:/a:redhat:jboss_enterprise_application_platform:6.4.8",
        "cpe:/a:redhat:jboss_enterprise_application_platform:6.4.9",
        "cpe:/a:redhat:jboss_enterprise_application_platform:6.4.10",
        "cpe:/a:redhat:jboss_enterprise_application_platform:6.4.11",
        "cpe:/a:redhat:jboss_enterprise_application_platform:6.4.12",
        "cpe:/a:redhat:jboss_enterprise_application_platform:6.4.13",
        "cpe:/a:redhat:jboss_enterprise_application_platform:6.4.14",
        "cpe:/a:redhat:jboss_enterprise_application_platform:6.4.15",
        "cpe:/a:redhat:jboss_enterprise_application_platform:6.4.16",
        "cpe:/a:redhat:jboss_enterprise_application_platform:6.4.17",
        "cpe:/a:redhat:jboss_enterprise_application_platform:6.4.18",
        "cpe:/a:redhat:jboss_enterprise_application_platform:6.4.19",
    ],
    "example": [
    ],
    "fedora": [
        "cpe:/o:fedoraproject:fedora:30",
        "cpe:/o:fedoraproject:fedora:29",
        "cpe:/o:fedoraproject:fedora:28",
        "cpe:/o:fedoraproject:fedora:27",
        "cpe:/o:fedoraproject:fedora:26",
        "cpe:/o:fedoraproject:fedora:25",
    ],
    "firefox": [
        "cpe:/a:mozilla:firefox",
    ],
    "fuse6": [
        "cpe:/a:redhat:jboss_fuse:6.0",
    ],
    "jre": [
        "cpe:/a:oracle:jre:",
        "cpe:/a:sun:jre:",
        "cpe:/a:redhat:openjdk:",
        "cpe:/a:ibm:jre:",
    ],
    "ocp3": [
        "cpe:/a:redhat:openshift_container_platform:3.10",
        "cpe:/a:redhat:openshift_container_platform:3.11",
    ],
    "ol7": [
        "cpe:/o:oracle:linux:7",
    ],
    "ol8": [
        "cpe:/o:oracle:linux:8",
    ],
    "opensuse": [
        "cpe:/o:opensuse:leap:42.1",
        "cpe:/o:opensuse:leap:42.2",
        "cpe:/o:opensuse:leap:42.3",
        "cpe:/o:opensuse:leap:15.0",
    ],
    "rhel6": [
        "cpe:/o:redhat:enterprise_linux:6",
        "cpe:/o:redhat:enterprise_linux:6::client",
        "cpe:/o:redhat:enterprise_linux:6::computenode",
    ],
    "rhel7": [
        "cpe:/o:redhat:enterprise_linux:7",
        "cpe:/o:redhat:enterprise_linux:7::client",
        "cpe:/o:redhat:enterprise_linux:7::computenode",
    ],
    "rhel8": [
        "cpe:/o:redhat:enterprise_linux:8",
    ],
    "rhosp13": [
        "cpe:/a:redhat:openstack:13",
    ],
    "rhv4": [
        "cpe:/a:redhat:enterprise_virtualization_manager:4",
        "cpe:/o:redhat:enterprise_linux:7::hypervisor",
    ],
    "sle11": [
        "cpe:/o:suse:linux_enterprise_server:11",
    ],
    "sle12": [
        "cpe:/o:suse:linux_enterprise_server:12",
    ],
    "ubuntu1404": [
        "cpe:/o:canonical:ubuntu_linux:14.04",
    ],
    "ubuntu1604": [
        "cpe:/o:canonical:ubuntu_linux:16.04",
    ],
    "ubuntu1804": [
        "cpe:/o:canonical:ubuntu_linux:18.04",
    ],
    "wrlinux8": [
        "cpe:/o:windriver:wrlinux:8",
    ],
    "wrlinux1019": [
        "cpe:/o:windriver:wrlinux:1019",
    ],
}

MULTI_PLATFORM_LIST = ["rhel", "fedora", "rhosp", "rhv", "debian", "ubuntu",
                       "wrlinux", "opensuse", "sle", "ol", "ocp", "example"]

MULTI_PLATFORM_MAPPING = {
    "multi_platform_debian": ["debian8"],
    "multi_platform_example": ["example"],
    "multi_platform_fedora": ["fedora"],
    "multi_platform_opensuse": ["opensuse"],
    "multi_platform_ol": ["ol7","ol8"],
    "multi_platform_ocp": ["ocp3"],
    "multi_platform_rhel": ["rhel6", "rhel7", "rhel8"],
    "multi_platform_rhosp": ["rhosp13"],
    "multi_platform_rhv": ["rhv4"],
    "multi_platform_sle": ["sle11", "sle12"],
    "multi_platform_ubuntu": ["ubuntu1404", "ubuntu1604", "ubuntu1804"],
    "multi_platform_wrlinux": ["wrlinux8", "wrlinux1019"],
}

RHEL_CENTOS_CPE_MAPPING = {
    "cpe:/o:redhat:enterprise_linux:6": "cpe:/o:centos:centos:6",
    "cpe:/o:redhat:enterprise_linux:7": "cpe:/o:centos:centos:7",
    "cpe:/o:redhat:enterprise_linux:8": "cpe:/o:centos:centos:8",
}

RHEL_SL_CPE_MAPPING = {
    "cpe:/o:redhat:enterprise_linux:6": "cpe:/o:scientificlinux:scientificlinux:6",
    "cpe:/o:redhat:enterprise_linux:7": "cpe:/o:scientificlinux:scientificlinux:7",
}

CENTOS_NOTICE = \
    "<div xmlns=\"http://www.w3.org/1999/xhtml\">\n" \
    "<p>This benchmark is a direct port of a <i>SCAP Security Guide </i> " \
    "benchmark developed for <i>Red Hat Enterprise Linux</i>. It has been " \
    "modified through an automated process to remove specific dependencies " \
    "on <i>Red Hat Enterprise Linux</i> and to function with <i>CentOS</i>. " \
    "The result is a generally useful <i>SCAP Security Guide</i> benchmark " \
    "with the following caveats:</p>\n" \
    "<ul>\n" \
    "<li><i>CentOS</i> is not an exact copy of " \
    "<i>Red Hat Enterprise Linux</i>. There may be configuration differences " \
    "that produce false positives and/or false negatives. If this occurs " \
    "please file a bug report.</li>\n" \
    "\n" \
    "<li><i>CentOS</i> has its own build system, compiler options, patchsets, " \
    "and is a community supported, non-commercial operating system. " \
    "<i>CentOS</i> does not inherit " \
    "certifications or evaluations from <i>Red Hat Enterprise Linux</i>. As " \
    "such, some configuration rules (such as those requiring " \
    "<i>FIPS 140-2</i> encryption) will continue to fail on <i>CentOS</i>.</li>\n" \
    "</ul>\n" \
    "\n" \
    "<p>Members of the <i>CentOS</i> community are invited to participate in " \
    "<a href=\"http://open-scap.org\">OpenSCAP</a> and " \
    "<a href=\"https://github.com/OpenSCAP/scap-security-guide\">" \
    "SCAP Security Guide</a> development. Bug reports and patches " \
    "can be sent to GitHub: " \
    "<a href=\"https://github.com/OpenSCAP/scap-security-guide\">" \
    "https://github.com/OpenSCAP/scap-security-guide</a>. " \
    "The mailing list is at " \
    "<a href=\"https://fedorahosted.org/mailman/listinfo/scap-security-guide\">" \
    "https://fedorahosted.org/mailman/listinfo/scap-security-guide</a>" \
    ".</p>" \
    "</div>"

SL_NOTICE = \
    "<div xmlns=\"http://www.w3.org/1999/xhtml\">\n" \
    "<p>This benchmark is a direct port of a <i>SCAP Security Guide </i> " \
    "benchmark developed for <i>Red Hat Enterprise Linux</i>. It has been " \
    "modified through an automated process to remove specific dependencies " \
    "on <i>Red Hat Enterprise Linux</i> and to function with <i>Scientifc Linux</i>. " \
    "The result is a generally useful <i>SCAP Security Guide</i> benchmark " \
    "with the following caveats:</p>\n" \
    "<ul>\n" \
    "<li><i>Scientifc Linux</i> is not an exact copy of " \
    "<i>Red Hat Enterprise Linux</i>. Scientific Linux is a Linux distribution " \
    "produced by <i>Fermi National Accelerator Laboratory</i>. It is a free and " \
    "open source operating system based on <i>Red Hat Enterprise Linux</i> and aims " \
    "to be \"as close to the commercial enterprise distribution as we can get it.\" " \
    "There may be configuration differences that produce false positives and/or " \
    "false negatives. If this occurs please file a bug report.</li>\n" \
    "\n" \
    "<li><i>Scientifc Linux</i> is derived from the free and open source software " \
    "made available by Red Hat, but it is not produced, maintained or supported by <i>Red Hat</i>. " \
    "<i>Scientifc Linux</i> has its own build system, compiler options, patchsets, " \
    "and is a community supported, non-commercial operating system. " \
    "<i>Scientifc Linux</i> does not inherit " \
    "certifications or evaluations from <i>Red Hat Enterprise Linux</i>. As " \
    "such, some configuration rules (such as those requiring " \
    "<i>FIPS 140-2</i> encryption) will continue to fail on <i>Scientifc Linux</i>.</li>\n" \
    "</ul>\n" \
    "\n" \
    "<p>Members of the <i>Scientifc Linux</i> community are invited to participate in " \
    "<a href=\"http://open-scap.org\">OpenSCAP</a> and " \
    "<a href=\"https://github.com/OpenSCAP/scap-security-guide\">" \
    "SCAP Security Guide</a> development. Bug reports and patches " \
    "can be sent to GitHub: " \
    "<a href=\"https://github.com/OpenSCAP/scap-security-guide\">" \
    "https://github.com/OpenSCAP/scap-security-guide</a>. " \
    "The mailing list is at " \
    "<a href=\"https://fedorahosted.org/mailman/listinfo/scap-security-guide\">" \
    "https://fedorahosted.org/mailman/listinfo/scap-security-guide</a>" \
    ".</p>" \
    "</div>"

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

OVALTAG_TO_ABBREV = {
    'definition': 'def',
    'criteria': 'crit',
    'test': 'tst',
    'object': 'obj',
    'state': 'ste',
    'variable': 'var',
}

OCILTAG_TO_ABBREV = {
    'questionnaire': 'questionnaire',
    'action': 'testaction',
    'question': 'question',
    'artifact': 'artifact',
    'variable': 'variable',
}

OVALREFATTR_TO_TAG = {
    "definition_ref": "definition",
    "test_ref": "test",
    "object_ref": "object",
    "state_ref": "state",
    "var_ref": "variable",
}

OCILREFATTR_TO_TAG = {
    "question_ref": "question",
}

XCCDF_PLATFORM_TO_CPE = {
    "machine": "cpe:/a:machine",
    "container": "cpe:/a:container",
    "gdm": "cpe:/a:gdm",
    "libuser": "cpe:/a:libuser",
    "nss-pam-ldapd": "cpe:/a:nss-pam-ldapd",
    "pam": "cpe:/a:pam",
    "shadow-utils": "cpe:/a:shadow-utils",
    "sssd": "cpe:/a:sssd",
    "systemd": "cpe:/a:systemd",
    "yum": "cpe:/a:yum",
}

# _version_name_map = {
MAKEFILE_ID_TO_PRODUCT_MAP = {
    'chromium': 'Google Chromium Browser',
    'fedora': 'Fedora',
    'firefox': 'Mozilla Firefox',
    'jre': 'Java Runtime Environment',
    'rhosp': 'Red Hat OpenStack Platform',
    'rhel': 'Red Hat Enterprise Linux',
    'rhv': 'Red Hat Virtualization',
    'debian': 'Debian',
    'ubuntu': 'Ubuntu',
    'eap': 'JBoss Enterprise Application Platform',
    'fuse': 'JBoss Fuse',
    'opensuse': 'openSUSE',
    'sle': 'SUSE Linux Enterprise',
    'wrlinux': 'Wind River Linux',
    'example': 'Example Linux Content',
    'ol': 'Oracle Linux',
    'ocp': 'Red Hat OpenShift Container Platform',
}


# Application constants
DEFAULT_UID_MIN = 1000
