#!/bin/bash
# packages = audit
# platform = multi_platform_fedora,multi_platform_rhel,Oracle Linux 7,Oracle Linux 8,multi_platform_ubuntu

# This creates a situation from https://redhat.atlassian.net/browse/RHEL-171005
# OpenSCAP produced an error in previous version of OVAL
touch /etc/$(printf "evil_filename_\334_non_utf8_character")

./generate_privileged_commands_rule.sh {{{ uid_min }}} privileged /etc/audit/rules.d/privileged.rules
