#!/bin/bash
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel


yum -y install aide
aide --init

declare -a bins
bins=('/usr/sbin/auditctl' '/usr/sbin/auditd' '/usr/sbin/augenrules' '/usr/sbin/aureport' '/usr/sbin/ausearch' '/usr/sbin/autrace' '/usr/sbin/rsyslogd')

for theFile in "${bins[@]}"
do
    echo sed -i "s#^.*${theFile}.*##g" /etc/aide.conf
done
