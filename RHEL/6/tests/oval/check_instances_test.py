#!/usr/bin/python2

import sys
import os
import lxml.etree as ET

# This script requires one argument: path to OVAL file to be reviewed
#
# The purpose of this script is to review existing (and newly added)
# <ind:instance> elements of corresponding <ind:textfilecontent54_object>
# OVAL objects for their correctness and enforce uniformity on the way
# <ind:instance> elements are used for particular service / filepath location.
#
# Different UNIX services treat their input files they use differently.
# Some accept just the first value of a concrete option and ignore the
# rest (for example 'sshd' or 'iptables' service). While others (for
# example 'auditd' service wrt to processing /etc/audit/auditd.conf file)
# process the input file sequentially and in case there's different value
# provided for previously used option, the last setting is which will get
# actually used. Yet there also exists executables processing input text
# files containing multiple similar / alternative rows (where at some point
# any of these entries could be used) - for example list of available kernel
# entries to boot in /etc/grub.conf.
#
# The point of this testing script is to enforce that each (existing but
# also in the future added) textfilecontent54_object for that particular
# service would follow the expectations / behavioral pattern typical for
# that service (IOW that each textfilecontent54_object for the 'sshd'
# service will check just the first instance, while each textfilecontent54_object
# for e.g. logrotate service will check all instances).


oval_ns = "http://oval.mitre.org/XMLSchema/oval-definitions-5"

def verify_record_sanity(oval_id, filepath, operation, instance):

    # This list contains manually verified textfilecontent54_objects that are safe
    # based on the way they are defined. Use this list to define exceptions from
    # the following service behavioral patterns.
    MANUALLY_VERIFIED_SAFE_IDS = ['oval:ssg:obj:1312', # check_existence='none_exist'
                                  'oval:ssg:obj:2142', # check_existence='none_exist'
                                  'oval:ssg:obj:2165'  # only one 'password' kw in /etc/grub.conf
                                 ]

    # First check if particular OVAL id is in the list of the manually verified ones
    # If so return PASS
    if oval_id in MANUALLY_VERIFIED_SAFE_IDS:
        return 'PASS'

    # This OVAL id isn't in the list of manually blessed ones => check record sanity
    # based on filepath + instance combination

    # /etc/audit/audit.rules case - first entry wins the system:
    # https://www.redhat.com/archives/linux-audit/2015-January/msg00070.html
    if filepath == '/etc/audit/audit.rules' and operation is None and instance == '1':
        return 'PASS'

    # /etc/audit/auditd.conf case - last option setting wins. To verify use '-f' in
    # EXTRAOPTIONS of /etc/sysconfig/auditd, use two different values for the same auditd.conf
    # option & restart auditd service to see at stderr which setting would be applied
    if filepath == '/etc/audit/auditd.conf' and operation == 'greater than or equal' and instance == '1':
        return 'PASS'

    # /etc/sysctl.conf case - last option setting wins. To verify use two different values
    # for e.g. 'kernel.msgmax' option, reboot the system and verify the new value via:
    # 		# cat /proc/sys/kernel/msgmax
    # command
    if filepath == '/etc/sysctl.conf' and operation == 'greater than or equal' and instance == '1':
        return 'PASS'

    # /etc/ssh/sshd_conf case - first option setting wins. To verify supply 'OPTIONS="-T"' to
    # /etc/sysconfig/sshd, provide two different values for some sshd_config directive, restart sshd
    # and verify the sshd config dump output
    if filepath == '/etc/ssh/sshd_config' and operation is None and instance == '1':
        return 'PASS'

    # /etc/init.d/functions case - last option wins (it's a shell script)
    if filepath == '/etc/init.d/functions' and operation == 'greater than or equal' and instance == '1':
        return 'PASS'

    # /etc/inittab case - first option setting wins. To verify use multiple 'id:[0-5]:initdefault:'
    # with different runlevel, reboot the system & obtain current runlevel value via 'runlevel' command
    # after reboot
    if filepath == '/etc/inittab' and operation is None and instance == '1':
        return 'PASS'

    # /etc/modprobe.conf and /etc/modprobe.d cases - to check first instance is sufficient since OVAL is
    # checking if particular kernel module is set disabled
    if filepath == '/etc/modprobe.conf' or filepath.startswith('/etc/modprobe.d'):
        if operation is None and instance == '1':
            return 'PASS'

    # /etc/pam.d/system-auth, /etc/pam.d/password-auth case - first option setting wins
    # (any following settings for the same option are ignored) => operation doesn't matter
    # if it's 'None' / 'equals' / 'greater than or equal' under assumption instance == '1'
    if filepath == '/etc/pam.d/system-auth' or filepath == '/etc/pam.d/password-auth' and instance == '1':
        return 'PASS'

    # /etc/sysconfig/iptables, /etc/sysconfig/ip6tables case - first option setting wins
    # (any following setting for the same option is ignored)
    # From http://fedoraproject.org/wiki/How_to_edit_iptables_rules#Listing_Rules
    # "Note that Rules are applied in order of appearance, and the inspection ends
    #  immediately when there is a match. Therefore, for example, if a Rule rejecting
    #  ssh connections is created, and afterward another Rule is specified allowing ssh,
    #  the Rule to reject is applied and the later Rule to accept the ssh connection is not."
    if filepath == '/etc/sysconfig/iptables' or filepath == '/etc/sysconfig/ip6tables' and instance == '1':
        return 'PASS'

    # Return failure by default
    return 'FAIL'

def main():

    if len(sys.argv) < 2:
        print "Provide path to OVAL xml file to be checked."
        sys.exit(1)

    PASS_COUNT = 0
    oval_file = sys.argv[1]

    tree = ET.parse(oval_file)
    # Get OVAL XML root element
    root = tree.getroot()
    # Get OVAL XML <objects> element
    objects_root = root.findall('{' + oval_ns + '}objects')
    # Get the list of all <ind:textfilecontent54_object> elements
    tfc54_objects = objects_root[0].findall('{' + oval_ns + '#independent}textfilecontent54_object')
    print "Found %d objects to review:\n" % len(tfc54_objects)

    for obj in tfc54_objects:

        # Get 'id' attribute for object
        obj_id_attr = obj.get('id')
        # Get <ind:filepath> and <ind:path> + <ind:filename> subelements for object
        # If <ind:filepath> elem is None, object has <ind:path> + <ind:filename> combination
        # and vice versa
        obj_fp_elem = obj.find('{' + oval_ns + '#independent}filepath')
        obj_path_elem = obj.find('{' + oval_ns + '#independent}path')
        obj_filename_elem = obj.find('{' + oval_ns + '#independent}filename')
        # Get <ind:instance> subelement for obj
        obj_ins_elem = obj.find('{' + oval_ns + '#independent}instance')
        # Get 'operation' attribute from the <ind:instance> subelement yet
        obj_op_attr = obj_ins_elem.get('operation')

        # Construct the filepath value for object (either from <ind:filepath> value
        # or by concatenating <ind:path> + <ind:filename> values)
        if obj_fp_elem is not None:
            obj_filepath = obj_fp_elem.text
        else:
            obj_filepath = obj_path_elem.text + '/' + obj_filename_elem.text

        # Verify record correctness based on 'id', 'filepath / path + filename',
        # 'operation', and 'instance' values
        result = verify_record_sanity(obj_id_attr, obj_filepath, obj_op_attr, obj_ins_elem.text)

        if result == 'PASS':
            PASS_COUNT += 1

        # Print out the review result for this object
        print "* Identifier\t= %-*s" % (40, obj_id_attr)
        if obj_fp_elem is not None:
            print "  Filepath\t= %-*s" % (40, obj_fp_elem.text)
        else:
            print "  Path\t\t= %-*s" % (40, obj_path_elem.text)
            print "  Filename\t= %-*s" % (40, obj_filename_elem.text)
        if obj_op_attr is not None:
            print "  Operation\t= %-*s" % (40, obj_op_attr)
        else:
            print "  Operation\t= None"
        print "  Instance\t= %-*s" % (40, obj_ins_elem.text)
        print "  Result\t= %-*s" % (40, result)
        print

    print "Ratio of passing objects to all objects: %d / %d" % (PASS_COUNT, len(tfc54_objects))

if __name__ == "__main__":
    main()
