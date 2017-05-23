#!/usr/bin/env python2

from __future__ import print_function
import libvirt
import sys
import string

import xml.etree.ElementTree as ET

def determineIP(domain):
    domain_xml = ET.fromstring(domain.XMLDesc())
    for mac_node in domain_xml.iter('mac'):
        domain_mac = mac_node.attrib['address']
        break

    ifaces = domain.interfaceAddresses(libvirt.VIR_DOMAIN_INTERFACE_ADDRESSES_SRC_AGENT, 0)

    for (name, val) in ifaces.iteritems():
        if val['hwaddr'] == domain_mac and val['addrs']:
            for ipaddr in val['addrs']:
                if ipaddr['type'] == libvirt.VIR_IP_ADDR_TYPE_IPV4:
                    return ipaddr['addr']


conn = libvirt.open('qemu:///session')
if conn == None:
    print('Failed to open connection to the hypervisor')
    sys.exit(1)

try:
    dom0 = conn.lookupByName("REM_RHEL7")
except:
    print('Failed to find the main domain')
    sys.exit(1)

print(determineIP(dom0))
