#!/bin/bash
# packages = audit
# platform = multi_platform_fedora,multi_platform_rhel,Oracle Linux 7,Oracle Linux 8,multi_platform_ubuntu

{{{ setup_auditctl_environment() }}}

./generate_privileged_commands_rule.sh {{{ uid_min }}} privileged /etc/audit/audit.rules
sed -i -E 's/^(.*path=[[:graph:]]+) -F perm=x(.*$)/\1\2/' /etc/audit/audit.rules
