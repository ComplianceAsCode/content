#!/usr/bin/env python2

from __future__ import print_function
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

def runOSCAP(domain_ip, profile, stage, datastream):
    command = shlex.split('oscap-ssh root@{0} 22 xccdf eval --profile {1} --progress --oval-results --report {1}_{2}.html {3}'.format(domain_ip, profile, stage, datastream))
    subprocess.call(command)




conn = libvirt.open('qemu:///session')
if conn == None:
    print('Failed to open connection to the hypervisor')
    sys.exit(1)

try:
    dom0 = conn.lookupByName("REM_RHEL7")
except:
    print('Failed to find the main domain')
    sys.exit(1)

dom0_ip = determineIP(dom0)
profile = 'xccdf_org.ssgproject.content_profile_common'
datastream = '/usr/share/xml/scap/ssg/content/ssg-rhel7-ds.xml'
#snap = snapshotCreate(dom0, 'origin')
runOSCAP(dom0_ip, profile, 'initial', datastream)

#snapshotRevert(dom0, snap)
