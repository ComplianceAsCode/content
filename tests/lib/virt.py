#!/usr/bin/env python2
from __future__ import print_function

import libvirt
import time

import xml.etree.ElementTree as ET

from lib.log import log

# filled in by connectDomain function
snapshots = None


class SnapshotStack(object):
    SNAPSHOT_BASE = ("<domainsnapshot>"
                     "  <name>{name}</name>"
                     "  <description>"
                     "     Full snapshot by SSG Test Suite"
                     "  </description>"
                     "</domainsnapshot>")

    def __init__(self, domain):
        self.stack = []
        self.domain = domain
        super(SnapshotStack, self).__init__()

    def create(self, snapshot_name):
        log.debug('Creating snapshot {0}'.format(snapshot_name))
        snapshot_xml = self.SNAPSHOT_BASE.format(name=snapshot_name)
        snapshot = self.domain.snapshotCreateXML(snapshot_xml,
                                    libvirt.VIR_DOMAIN_SNAPSHOT_CREATE_ATOMIC)

        self.stack.append(snapshot)
        return snapshot

    def revert_forced(self, snapshot):
        snapshot_name = snapshot.getName()
        log.debug('Forced reverting of snapshot {0}'.format(snapshot_name))
        self.domain.revertToSnapshot(snapshot)
        snapshot.delete()
        self.stack.remove(snapshot)
        log.debug('Revert successful')

    def revert(self):
        try:
            snapshot = self.stack.pop()
        except IndexError:
            log.error("No snapshot in stack anymore")
        else:
            log.debug("Reverting snapshot {0}".format(snapshot.getName()))
            self.domain.revertToSnapshot(snapshot)
            snapshot.delete()

    def clear(self):
        log.debug('Reverting all created snapshots in reverse order')
        while self.stack:
            snapshot = self.stack.pop()
            snapshot_name = snapshot.getName()
            log.debug('Reverting of snapshot {0}'.format(snapshot_name))
            self.domain.revertToSnapshot(snapshot)
            snapshot.delete()
            log.debug('Revert successful')
        log.info('All snapshots reverted successfully')


def determine_ip(domain):
    GUEST_AGENT_XML = ("<channel type='unix'>"
                       "  <source mode='bind'/>"
                       "  <target type='virtio'"
                                 "name='org.qemu.guest_agent.0'"
                                 "state='connected'/>"
                       "</channel>")

    domain_xml = ET.fromstring(domain.XMLDesc())
    for mac_node in domain_xml.iter('mac'):
        domain_mac = mac_node.attrib['address']
        break

    log.debug('Fetching IP address of the domain')
    try:
        ifaces = domain.interfaceAddresses(
                            libvirt.VIR_DOMAIN_INTERFACE_ADDRESSES_SRC_AGENT,
                            0)
    except libvirt.libvirtError:
        # guest agent is not connected properly
        # let's try to reattach the guest-agent device
        guest_agent_xml_string = None
        domain_xml = ET.fromstring(dom.XMLDesc())
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
                    log.debug('IP address is {0}'.format(ipaddr['addr']))
                    return ipaddr['addr']


def connect_domain(hypervisor, domain_name):
    global snapshots

    conn = libvirt.open(hypervisor)
    if conn is None:
        log.error('Failed to open connection to the hypervisor')
        return None

    try:
        dom = conn.lookupByName(domain_name)
    except:
        log.error('Failed to find domain "{0}"'.format(domain_name))
        return None
    snapshots = SnapshotStack(dom)
    return dom


def start_domain(domain):
    if not domain.isActive():
        log.debug('Starting domain {0}'.format(domain.name()))
        domain.create()
        log.debug('Waiting 30s for domain to start')
        time.sleep(30)
