#!/bin/bash
# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_ubuntu,multi_platform_almalinux
# packages = aide

declare -a bins
bins=('/sbin/auditctl' '/sbin/auditd' '/sbin/augenrules' '/sbin/aureport' '/sbin/ausearch' '/sbin/autrace' '/sbin/rsyslogd' '/sbin/audispd')

for theFile in "${bins[@]}"
do
    echo "$theFile p+i+n+u+g+s+b+acl+xattrs+sha512"  >> {{{ aide_conf_path }}}
done
