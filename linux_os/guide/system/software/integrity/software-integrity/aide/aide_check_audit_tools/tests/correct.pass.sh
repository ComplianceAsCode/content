#!/bin/bash
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel


yum -y install aide
aide --init


declare -a bins
bins=('/usr/sbin/auditctl' '/usr/sbin/auditd' '/usr/sbin/augenrules' '/usr/sbin/aureport' '/usr/sbin/ausearch' '/usr/sbin/autrace' '/usr/sbin/rsyslogd')

for theFile in "${bins[@]}"
do
    echo "$theFile p+i+n+u+g+s+b+acl+xattrs+sha512"  >> /etc/aide.conf
done
