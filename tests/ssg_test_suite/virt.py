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
    SNAPSHOT_STACK = []
    DOMAIN = None

    @classmethod
    def create(cls, snapshot_name):
        logging.debug("Creating snapshot '{0}'".format(snapshot_name))
        snapshot_xml = cls.SNAPSHOT_BASE.format(name=snapshot_name)
        snapshot = cls.DOMAIN.snapshotCreateXML(snapshot_xml,
                                    libvirt.VIR_DOMAIN_SNAPSHOT_CREATE_ATOMIC)

        cls.SNAPSHOT_STACK.append(snapshot)
        return snapshot

    @classmethod
    def revert_forced(cls, snapshot):
        snapshot_name = snapshot.getName()
        logging.debug("Forced reverting of snapshot '{0}'".format(snapshot_name))
        cls.DOMAIN.revertToSnapshot(snapshot)
        snapshot.delete()
        cls.SNAPSHOT_STACK.remove(snapshot)
        logging.debug('Revert successful')

    @classmethod
    def revert(cls, delete=True):
        try:
            snapshot = cls.SNAPSHOT_STACK.pop()
        except IndexError:
            logging.error("No snapshot in stack anymore")
        else:
            cls.DOMAIN.revertToSnapshot(snapshot)
            if delete:
                logging.debug(("Hard revert of snapshot "
                           "'{0}' successful").format(snapshot.getName()))
                snapshot.delete()
            else:
                # this is soft revert - we are keeping the snapshot for
                # another use
                logging.debug(("Soft revert of snapshot "
                           "'{0}' successful").format(snapshot.getName()))
                cls.SNAPSHOT_STACK.append(snapshot)

    @classmethod
    def delete(cls, snapshot=None):
        # removing snapshot from the stack without doing a revert - use
        # coupled with revert without delete
        if snapshot:
            cls.SNAPSHOT_STACK.remove(snapshot)
        else:
            snapshot = cls.SNAPSHOT_STACK.pop()
        snapshot.delete()
        logging.debug(("Snapshot '{0}' deleted "
                   "successfully").format(snapshot.getName()))

    @classmethod
    def clear(cls):
        logging.debug('Reverting all created snapshots in reverse order')
        while cls.SNAPSHOT_STACK:
            snapshot = cls.SNAPSHOT_STACK.pop()
            snapshot_name = snapshot.getName()
            logging.debug("Reverting of snapshot '{0}'".format(snapshot_name))
            cls.DOMAIN.revertToSnapshot(snapshot)
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
    except:
        logging.error("Failed to find domain '{0}'".format(domain_name))
        return None
    return dom


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

    logging.debug('Fetching IP address of the domain')
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
                    logging.debug('IP address is {0}'.format(ipaddr['addr']))
                    return ipaddr['addr']


def start_domain(domain):
    if not domain.isActive():
        logging.debug("Starting domain '{0}'".format(domain.name()))
        domain.create()
        logging.debug('Waiting 30s for domain to start')
        time.sleep(30)
