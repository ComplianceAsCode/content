#!/bin/bash
# platform = debian 10,debian 9,multi_platform_fedora,Oracle Linux 7,Oracle Linux 8,Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,WRLinux 1019

. /usr/share/scap-security-guide/remediation_functions

{{{ bash_instantiate_variables("var_snmpd_ro_string", "var_snmpd_rw_string") }}}

# remediate read-only community string
if grep -q 'public' /etc/snmp/snmpd.conf; then
    sed -i "s/public/$var_snmpd_ro_string/" /etc/snmp/snmpd.conf
fi

# remediate read-write community string
if grep -q 'private' /etc/snmp/snmpd.conf; then
    sed -i "s/private/$var_snmpd_rw_string/" /etc/snmp/snmpd.conf
fi
