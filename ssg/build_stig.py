from __future__ import absolute_import
from __future__ import print_function

import os
import sys

from .xml import ElementTree as ET
from .constants import XCCDF11_NS
from ssg.constants import PREFIX_TO_NS as NS


def map_versions_to_rule_ids(reference_file_name):
    try:
        reference_root = ET.parse(reference_file_name)
    except IOError:
        print(
            "INFO: DISA STIG Reference file not found for this platform: %s" %
            reference_file_name)
        sys.exit(0)

    reference_rules = reference_root.findall('.//{%s}Rule' % XCCDF11_NS)

    dictionary = {}

    for rule in reference_rules:
        version = rule.find('.//{%s}version' % XCCDF11_NS)
        if version is not None and version.text:
            dictionary[version.text] = rule.get('id')
    return dictionary


SEVERITY = {'low': 'CAT III', 'medium': 'CAT II', 'high': 'CAT I'}


def get_severity(input_severity):
    if input_severity not in [
            'CAT I', 'CAT II', 'CAT III', 'low', 'medium', 'high']:
        raise ValueError("Severity of {}".format(input_severity))
    elif input_severity in ['CAT I', 'CAT II', 'CAT III']:
        return input_severity
    else:
        return SEVERITY[input_severity]


def get_description_root(srg):
    # DISA adds escaped XML to the description field
    # This method unescapes that XML and parses it
    description_xml = "<root>"
    text = srg.find('xccdf-1.1:description', NS).text
    text = text.replace('&lt;', '<').replace('&gt;', '>').replace(' & ', '')
    description_xml += text
    description_xml += "</root>"
    description_root = ET.ElementTree(ET.fromstring(description_xml)).getroot()
    return description_root


def parse_srgs(xml_path):
    if not os.path.exists(xml_path):
        sys.stderr.write("XML {} for SRG was not found\n".format(xml_path))
        exit(1)
    root = ET.parse(xml_path).getroot()
    srgs = dict()
    for rule in root.findall('.//xccdf-1.1:Rule', NS):
        srg_id = rule.find('xccdf-1.1:version', NS).text
        srg = dict()
        srg['severity'] = get_severity(rule.get('severity'))
        srg['title'] = rule.find('xccdf-1.1:title', NS).text
        description_root = get_description_root(rule)
        srg['vuln_discussion'] = description_root.find('VulnDiscussion').text
        srg['cci'] = rule.find(
            "xccdf-1.1:ident[@system='http://cyber.mil/cci']", NS).text
        srg['first_ident'] = rule.find("xccdf-1.1:ident", NS).text
        srg['fix'] = rule.find('xccdf-1.1:fix', NS).text
        srg['fixtext'] = rule.find('xccdf-1.1:fixtext', NS).text
        srg['check'] = rule.find(
            'xccdf-1.1:check/xccdf-1.1:check-content', NS).text
        srg['ia_controls'] = description_root.find('IAControls').text
        srgs[srg_id] = srg
    return srgs
