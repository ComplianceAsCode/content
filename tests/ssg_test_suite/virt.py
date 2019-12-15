#!/usr/bin/env python2
from __future__ import print_function

import libvirt
import logging
import time

import xml.etree.ElementTree as ET

logging.getLogger(__name__).addHandler(logging.NullHandler())


class SnapshotStack(object):
    SNAPSHOT_BASE = ("<domainsnapshot>"
                     "  <name>{name}</name>"
                     "  <description>"
                     "     Full snapshot by SSG Test Suite"
                     "  </description>"
                     "</domainsnapshot>")
    CREATE_FLAGS = libvirt.VIR_DOMAIN_SNAPSHOT_CREATE_ATOMIC
    REVERT_FLAGS = libvirt.VIR_DOMAIN_SNAPSHOT_REVERT_FORCE

    def __init__(self, domain):
        self.snapshot_stack = []
        self.domain = domain

    def create(self, snapshot_name):
        logging.debug("Creating snapshot '{0}'".format(snapshot_name))
        snapshot_xml = self.SNAPSHOT_BASE.format(name=snapshot_name)
        snapshot = self.domain.snapshotCreateXML(snapshot_xml,
                                                 self.CREATE_FLAGS)

        self.snapshot_stack.append(snapshot)
        return snapshot

    def revert_forced(self, snapshot):
        snapshot_name = snapshot.getName()
        logging.debug("Forced revert of snapshot '{0}'".format(snapshot_name))
        self.domain.revertToSnapshot(snapshot,
                                     self.REVERT_FLAGS)
        snapshot.delete()
        self.snapshot_stack.remove(snapshot)
        logging.debug('Revert successful')

    def revert(self, delete=True):
        try:
            snapshot = self.snapshot_stack.pop()
        except IndexError:
            logging.error("No snapshot in stack anymore")
        else:
            self.domain.revertToSnapshot(snapshot,
                                         self.REVERT_FLAGS)
            if delete:
                logging.debug(("Hard revert of snapshot "
                               "'{0}' successful").format(snapshot.getName()))
                snapshot.delete()
            else:
                # this is soft revert - we are keeping the snapshot for
                # another use
                logging.debug(("Soft revert of snapshot "
                               "'{0}' successful").format(snapshot.getName()))
                self.snapshot_stack.append(snapshot)

    def delete(self, snapshot=None):
        # removing snapshot from the stack without doing a revert - use
        # coupled with revert without delete
        if snapshot:
            self.snapshot_stack.remove(snapshot)
        else:
            snapshot = self.snapshot_stack.pop()
        snapshot.delete()
        logging.debug(("Snapshot '{0}' deleted "
                       "successfully").format(snapshot.getName()))

    def clear(self):
        logging.debug('Reverting all created snapshots in reverse order')
        while self.snapshot_stack:
            snapshot = self.snapshot_stack.pop()
            snapshot_name = snapshot.getName()
            logging.debug("Reverting of snapshot '{0}'".format(snapshot_name))
            self.domain.revertToSnapshot(snapshot,
                                         self.REVERT_FLAGS)
            snapshot.delete()
            logging.debug('Revert successful')
        logging.info('All snapshots reverted successfully')


def connect_domain(hypervisor, domain_name):
    conn = libvirt.open(hypervisor)
    if conn is None:
        logging.error('Failed to open connection to the hypervisor')
        return None

    try:
        dom = conn.lookupByName(domain_name)
    except libvirt.libvirtError:
        logging.error("Failed to find domain '{0}'".format(domain_name))
        return None
    return dom


def determine_ip(domain):
    GUEST_AGENT_XML = ("<channel type='unix'>"
                       "  <source mode='bind'/>"
                       "  <target type='virtio'"
                       "          name='org.qemu.guest_agent.0'"
                       "          state='connected'/>"
                       "</channel>")

    # wait for machine until it gets to RUNNING state,
    # because it isn't possible to determine IP in e.g. PAUSED state
    must_end = time.time() + 120  # wait max. 2 minutes
    while time.time() < must_end:
        if domain.state()[0] == libvirt.VIR_DOMAIN_RUNNING:
            break
        time.sleep(1)

    domain_xml = ET.fromstring(domain.XMLDesc())
    for mac_node in domain_xml.iter('mac'):
        domain_mac = mac_node.attrib['address']
        break

    logging.debug('Fetching IP address of the domain')
    try:
        ifaces = domain.interfaceAddresses(
                            libvirt.VIR_DOMAIN_INTERFACE_ADDRESSES_SRC_AGENT,
                            0)
    except libvirt.libvirtError:
        # guest agent is not connected properly
        # let's try to reattach the guest-agent device
        guest_agent_xml_string = None
        domain_xml = ET.fromstring(domain.XMLDesc())
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
    for (name, val) in ifaces.items():
        if val['hwaddr'] == domain_mac and val['addrs']:
            for ipaddr in val['addrs']:
                if ipaddr['type'] == libvirt.VIR_IP_ADDR_TYPE_IPV4:
                    logging.debug('IP address is {0}'.format(ipaddr['addr']))
                    return ipaddr['addr']


def start_domain(domain):
    if not domain.isActive():
        logging.debug("Starting domain '{0}'".format(domain.name()))
        domain.create()
        logging.debug('Waiting 30s for domain to start')
        time.sleep(30)
