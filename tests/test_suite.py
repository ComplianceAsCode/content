#!/usr/bin/env python2
from __future__ import print_function

import argparse
import libvirt
import shlex
import string
import subprocess
import sys
import time

import xml.etree.ElementTree as ET

SNAPSHOT_BASE='''
<domainsnapshot>
    <name>{0}</name>
    <description>Full snapshot by SSG Test Suite</description>
</domainsnapshot>'''

GUEST_AGENT_XML='''
<channel type='unix'>
    <source mode='bind'/>
    <target type='virtio' name='org.qemu.guest_agent.0' state='connected'/>
</channel>
'''

def determineIP(domain):
    domain_xml = ET.fromstring(domain.XMLDesc())
    for mac_node in domain_xml.iter('mac'):
        domain_mac = mac_node.attrib['address']
        break

    try:
        ifaces = domain.interfaceAddresses(
                            libvirt.VIR_DOMAIN_INTERFACE_ADDRESSES_SRC_AGENT,
                            0)
    except libvirt.libvirtError:
        # guest agent is not connected properly - happens regularly
        # solution is to reattach its device
        guest_agent_xml_string = None
        domain_xml = ET.fromstring(dom0.XMLDesc())
        for guest_agent_node in domain_xml.iter('channel'):
            if guest_agent_node.attrib['type'] == 'unix':
                guest_agent_xml_string = ET.tostring(guest_agent_node)
                break
        if guest_agent_xml_string:
            domain.detachDevice(guest_agent_xml_string)
        domain.attachDevice(GUEST_AGENT_XML)
        time.sleep(1)
        # now it should be ok
        ifaces = domain.interfaceAddresses(
                            libvirt.VIR_DOMAIN_INTERFACE_ADDRESSES_SRC_AGENT,
                            0)

    # get IPv4 address of the guest
    for (name, val) in ifaces.iteritems():
        if val['hwaddr'] == domain_mac and val['addrs']:
            for ipaddr in val['addrs']:
                if ipaddr['type'] == libvirt.VIR_IP_ADDR_TYPE_IPV4:
                    return ipaddr['addr']

def snapshotCreate(domain, snapshot_name):
    snapshot_xml = SNAPSHOT_BASE.format(snapshot_name)
    snapshot = domain.snapshotCreateXML(snapshot_xml,
                                        libvirt.VIR_DOMAIN_SNAPSHOT_CREATE_ATOMIC)
    with open('domainxml', 'w') as dom:
        dom.write(domain.XMLDesc())
    with open('snapxml', 'w') as snap:
        snap.write(snapshot.getXMLDesc())
    return snapshot

def snapshotRevert(domain, snapshot):
    domain.revertToSnapshot(snapshot)
    snapshot.delete()

def runOSCAP(domain_ip, profile, stage, datastream, remediation=False):
    if remediation:
        rem = "--remediate"
    else:
        rem = ""
    command = shlex.split('oscap-ssh root@{0} 22 xccdf eval --profile {1} --progress --oval-results --report {1}_{2}.html {3} {4}'.format(domain_ip, profile, stage, rem, datastream))
    subprocess.call(command)


########## argument parsing
parser = argparse.ArgumentParser()

common_parser = argparse.ArgumentParser(add_help=False)
common_parser.add_argument("--hypervisor", dest = "hypervisor",
    metavar = "qemu:///HYPERVISOR",
    default = "qemu:///session",
    help = "libvirt hypervisor",
)
common_parser.add_argument("--domain", dest = "domain",
    metavar = "DOMAIN",
    default = None,
    help = "libvirt domain used as test bed",
)
common_parser.add_argument("--datastream", dest = "datastream",
    metavar = "DATASTREAM",
    default = "/usr/share/xml/scap/ssg/content/ssg-rhel7-ds.xml",
    help = "Source DataStream to be tested"
)
subparsers = parser.add_subparsers(help='Subcommands: profile, rule')

parser_profile = subparsers.add_parser('profile', help='Testing profile-based remediation applied on already installed machine', parents=[common_parser])
parser_rule = subparsers.add_parser('rule', help='Testing remediations of particular rule for various situations - currently not supported by openscap!', parents=[common_parser])

parser_profile.add_argument("--profile", dest = "profile",
    metavar = "DSPROFILE",
    default = "xccdf_org.ssgproject.content_profile_common",
    help = "Profile to be tested"
)

parser_rule.add_argument("--rule", dest = "rule",
    metavar = "RULE",
    default = None,
    help = "Rule to be tested"
)

options = parser.parse_args()
############## / argument parsing

conn = libvirt.open(options.hypervisor)
if conn == None:
    print('Failed to open connection to the hypervisor')
    sys.exit(1)

try:
    dom = conn.lookupByName(options.domain)
except:
    print('Failed to find the main domain')
    sys.exit(1)


domain_ip = determineIP(dom)

snap = snapshotCreate(dom, 'origin')
runOSCAP(domain_ip, options.profile, 'initial', options.datastream)
runOSCAP(domain_ip, options.profile, 'remediation', options.datastream, remediation=True)
runOSCAP(domain_ip, options.profile, 'final', options.datastream)

snapshotRevert(dom, snap)
