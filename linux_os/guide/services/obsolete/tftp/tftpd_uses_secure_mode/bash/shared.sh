#!/bin/bash
# platform = Oracle Linux 7,Oracle Linux 8,Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8,Red Hat Virtualization 4,WRLinux 1019

. /usr/share/scap-security-guide/remediation_functions

{{{ bash_instantiate_variables ("var_tftpd_secure_directory") }}}

if grep -q 'server_args' /etc/xinetd.d/tftp; then
    sed -i -E "s;^([[:blank:]]*server_args[[:blank:]]+=[[:blank:]]+.*?)(-s[[:blank:]]+[[:graph:]]+)*(.*)$;\1 -s $var_tftpd_secure_directory \3;" /etc/xinetd.d/tftp
else
    echo "server_args = -s $var_tftpd_secure_directory" >> /etc/xinetd.d/tftp
fi


