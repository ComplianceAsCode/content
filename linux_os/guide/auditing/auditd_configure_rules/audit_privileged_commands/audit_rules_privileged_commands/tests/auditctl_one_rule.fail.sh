#!/bin/bash
# packages = audit
# platform = multi_platform_fedora,multi_platform_rhel,Oracle Linux 7,Oracle Linux 8

{{{ setup_auditctl_environment() }}}

echo "-a always,exit -F path=/usr/bin/sudo -F perm=x -F auid>={{{ uid_min }}} -F auid!=unset -k privileged" >> /etc/audit/audit.rules
