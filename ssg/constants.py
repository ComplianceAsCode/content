from __future__ import absolute_import
from __future__ import print_function

import os.path
import os
import time

product_directories = [
    'chromium',
    'debian9', 'debian10',
    'example',
    'fedora',
    'firefox',
    'fuse6',
    'jre',
    'macos1015',
    'ocp4',
    'rhcos4',
    'ol7', 'ol8',
    'opensuse',
    'rhel7', 'rhel8', 'rhel9',
    'rhosp10', 'rhosp13',
    'rhv4',
    'sle12', 'sle15',
    'ubuntu1604', 'ubuntu1804', 'ubuntu2004',
    'vsel',
    'wrlinux8', 'wrlinux1019'
]

JINJA_MACROS_BASE_DEFINITIONS = os.path.join(os.path.dirname(os.path.dirname(
    __file__)), "shared", "macros.jinja")
JINJA_MACROS_HIGHLEVEL_DEFINITIONS = os.path.join(os.path.dirname(os.path.dirname(
    __file__)), "shared", "macros-highlevel.jinja")
JINJA_MACROS_ANSIBLE_DEFINITIONS = os.path.join(os.path.dirname(os.path.dirname(
    __file__)), "shared", "macros-ansible.jinja")
JINJA_MACROS_IGNITION_DEFINITIONS = os.path.join(os.path.dirname(os.path.dirname(
    __file__)), "shared", "macros-ignition.jinja")
JINJA_MACROS_KUBERNETES_DEFINITIONS = os.path.join(os.path.dirname(os.path.dirname(
    __file__)), "shared", "macros-kubernetes.jinja")
JINJA_MACROS_OVAL_DEFINITIONS = os.path.join(os.path.dirname(os.path.dirname(
    __file__)), "shared", "macros-oval.jinja")
JINJA_MACROS_BASH_DEFINITIONS = os.path.join(os.path.dirname(os.path.dirname(
    __file__)), "shared", "macros-bash.jinja")

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
ignition_system = "urn:xccdf:fix:script:ignition"
kubernetes_system = "urn:xccdf:fix:script:kubernetes"
blueprint_system = "urn:redhat:osbuild:blueprint"
puppet_system = "urn:xccdf:fix:script:puppet"
anaconda_system = "urn:redhat:anaconda:pre"
cce_uri = "https://nvd.nist.gov/cce/index.cfm"
stig_ns = "https://public.cyber.mil/stigs/srg-stig-tools/"
cis_ns = "https://www.cisecurity.org/benchmark/red_hat_linux/"
hipaa_ns = "https://www.gpo.gov/fdsys/pkg/CFR-2007-title45-vol1/pdf/CFR-2007-title45-vol1-chapA-subchapC.pdf"
anssi_ns = "http://www.ssi.gouv.fr/administration/bonnes-pratiques/"
ospp_ns = "https://www.niap-ccevs.org/Profile/PP.cfm"
cui_ns = 'http://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-171.pdf'
stig_refs = 'https://public.cyber.mil/stigs/'
disa_cciuri = "https://public.cyber.mil/stigs/cci/"
ssg_version_uri = \
    "https://github.com/ComplianceAsCode/content/releases/latest"
OSCAP_VENDOR = "org.ssgproject"
OSCAP_DS_STRING = "xccdf_%s.content_benchmark_" % OSCAP_VENDOR
OSCAP_PROFILE = "xccdf_%s.content_profile_" % OSCAP_VENDOR
OSCAP_GROUP = "xccdf_%s.content_group_" % OSCAP_VENDOR
OSCAP_RULE = "xccdf_%s.content_rule_" % OSCAP_VENDOR
OSCAP_GROUP_PCIDSS = "xccdf_%s.content_group_pcidss-req" % OSCAP_VENDOR
OSCAP_GROUP_VAL = "xccdf_%s.content_group_values" % OSCAP_VENDOR
OSCAP_GROUP_NON_PCI = "xccdf_%s.content_group_non-pci-dss" % OSCAP_VENDOR
OSCAP_PATH = "oscap"
OSCAP_PROFILE_ALL_ID = "(all)"
XCCDF11_NS = "http://checklists.nist.gov/xccdf/1.1"
XCCDF12_NS = "http://checklists.nist.gov/xccdf/1.2"
min_ansible_version = "2.5"
ansible_version_requirement_pre_task_name = \
    "Verify Ansible meets SCAP-Security-Guide version requirements."
standard_profiles = ['standard', 'pci-dss', 'desktop', 'server']
xslt_ns = "http://www.w3.org/1999/XSL/Transform"
generic_stig_ns = "https://public.cyber.mil/stigs/downloads/" + \
                  "?_dl_facet_stigs=operating-systems%2Cunix-linux"
SCE_SYSTEM = "http://open-scap.org/page/SCE"


OVAL_SUB_NS = dict(
    ind="independent",
    unix="unix",
    linux="linux",
)


PREFIX_TO_NS = {
    "oval-def": oval_namespace,
    "oval": "http://oval.mitre.org/XMLSchema/oval-common-5",
    "ds": datastream_namespace,
    "ocil": ocil_namespace,
    "xccdf-1.1": XCCDF11_NS,
    "xccdf-1.2": XCCDF12_NS,
    "xlink": xlink_namespace,
    "cpe-dict": "http://cpe.mitre.org/dictionary/2.0",
    "cat": cat_namespace,
}


for prefix, url_part in OVAL_SUB_NS.items():
    assert prefix not in PREFIX_TO_NS, \
        "Conflict between a namespace and OVAL sub-namespace '{prefix}'".format(prefix=prefix)
    PREFIX_TO_NS[prefix] = "{oval_ns}#{suffix}".format(oval_ns=PREFIX_TO_NS["oval-def"], suffix=url_part)


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

timestamp = time.strftime(
    "%Y-%m-%dT%H:%M:%S",
    time.gmtime(int(os.environ.get('SOURCE_DATE_EPOCH', time.time())))
)

PKG_MANAGER_TO_SYSTEM = {
    "yum": "rpm",
    "zypper": "rpm",
    "dnf": "rpm",
    "apt_get": "dpkg",
}

PKG_MANAGER_TO_CONFIG_FILE = {
    "yum": "/etc/yum.conf",
    "dnf": "/etc/dnf/dnf.conf",
    "zypper": "/etc/zypp/zypper.conf",
}

FULL_NAME_TO_PRODUCT_MAPPING = {
    "Chromium": "chromium",
    "Debian 9": "debian9",
    "Debian 10": "debian10",
    "Example": "example",
    "Fedora": "fedora",
    "Firefox": "firefox",
    "JBoss Fuse 6": "fuse6",
    "Java Runtime Environment": "jre",
    "Apple macOS 10.15": "macos1015",
    "Red Hat OpenShift Container Platform 4": "ocp4",
    "McAfee VirusScan Enterprise for Linux": "vsel",
    "Red Hat Enterprise Linux CoreOS 4": "rhcos4",
    "Oracle Linux 7": "ol7",
    "Oracle Linux 8": "ol8",
    "openSUSE": "opensuse",
    "Red Hat Enterprise Linux 7": "rhel7",
    "Red Hat Enterprise Linux 8": "rhel8",
    "Red Hat Enterprise Linux 9": "rhel9",
    "Red Hat OpenStack Platform 10": "rhosp10",
    "Red Hat OpenStack Platform 13": "rhosp13",
    "Red Hat Virtualization 4": "rhv4",
    "SUSE Linux Enterprise 12": "sle12",
    "SUSE Linux Enterprise 15": "sle15",
    "Ubuntu 16.04": "ubuntu1604",
    "Ubuntu 18.04": "ubuntu1804",
    "Ubuntu 20.04": "ubuntu2004",
    "WRLinux 8": "wrlinux8",
    "WRLinux 1019": "wrlinux1019",
}


# see xccdf-addremediations.xslt <- shared_constants.xslt <- shared_shorthand2xccdf.xslt
# if you want to know how the map was constructed
REF_PREFIX_MAP = {
    "nist": "NIST-800-53",
    "cui": "NIST-800-171",
    "pcidss": "PCI-DSS",
    "cjis": "CJIS",
    "stigid": "DISA-STIG",
}

MULTI_PLATFORM_LIST = ["rhel", "fedora", "rhosp", "rhv", "debian", "ubuntu",
                       "wrlinux", "opensuse", "sle", "ol", "ocp", "rhcos", "example"]

MULTI_PLATFORM_MAPPING = {
    "multi_platform_debian": ["debian9", "debian10"],
    "multi_platform_example": ["example"],
    "multi_platform_fedora": ["fedora"],
    "multi_platform_opensuse": ["opensuse"],
    "multi_platform_ol": ["ol7", "ol8"],
    "multi_platform_ocp": ["ocp4"],
    "multi_platform_rhcos": ["rhcos4"],
    "multi_platform_rhel": ["rhel7", "rhel8", "rhel9"],
    "multi_platform_rhosp": ["rhosp10", "rhosp13"],
    "multi_platform_rhv": ["rhv4"],
    "multi_platform_sle": ["sle12", "sle15"],
    "multi_platform_ubuntu": ["ubuntu1604", "ubuntu1804", "ubuntu2004"],
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
    "<a href=\"https://github.com/ComplianceAsCode/content\">" \
    "SCAP Security Guide</a> development. Bug reports and patches " \
    "can be sent to GitHub: " \
    "<a href=\"https://github.com/ComplianceAsCode/content\">" \
    "https://github.com/ComplianceAsCode/content</a>. " \
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
    "<a href=\"https://github.com/ComplianceAsCode/content\">" \
    "SCAP Security Guide</a> development. Bug reports and patches " \
    "can be sent to GitHub: " \
    "<a href=\"https://github.com/ComplianceAsCode/content\">" \
    "https://github.com/ComplianceAsCode/content</a>. " \
    "The mailing list is at " \
    "<a href=\"https://fedorahosted.org/mailman/listinfo/scap-security-guide\">" \
    "https://fedorahosted.org/mailman/listinfo/scap-security-guide</a>" \
    ".</p>" \
    "</div>"

XCCDF_REFINABLE_PROPERTIES = ["weight", "severity", "role", "selector"]

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

# Default platform to package mapping
XCCDF_PLATFORM_TO_PACKAGE = {
  "grub2": "grub2-common",
  "login_defs": "login",
  "sssd": "sssd-common",
  "zipl": "s390utils-base",
  "sssd-ldap": None,  # Force package check wrapping skip
  "uefi": None,
  "non-uefi": None,
  "not_s390x_arch": None,
}

# _version_name_map = {
MAKEFILE_ID_TO_PRODUCT_MAP = {
    'chromium': 'Google Chromium Browser',
    'fedora': 'Fedora',
    'firefox': 'Mozilla Firefox',
    'jre': 'Java Runtime Environment',
    'macos': 'Apple macOS',
    'rhosp': 'Red Hat OpenStack Platform',
    'rhel': 'Red Hat Enterprise Linux',
    'rhv': 'Red Hat Virtualization',
    'debian': 'Debian',
    'ubuntu': 'Ubuntu',
    'eap': 'JBoss Enterprise Application Platform',
    'fuse': 'JBoss Fuse',
    'opensuse': 'openSUSE',
    'sle': 'SUSE Linux Enterprise',
    'vsel': 'McAfee VirusScan Enterprise for Linux',
    'wrlinux': 'WRLinux',
    'example': 'Example',
    'ol': 'Oracle Linux',
    'ocp': 'Red Hat OpenShift Container Platform',
    'rhcos': 'Red Hat Enterprise Linux CoreOS',
}


# Application constants
DEFAULT_UID_MIN = 1000
DEFAULT_GRUB2_BOOT_PATH = '/boot/grub2'
DEFAULT_DCONF_GDM_DIR = 'gdm.d'
