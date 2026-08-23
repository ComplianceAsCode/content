#!/bin/bash
# packages = authselect
# platform = multi_platform_fedora,Oracle Linux 9,multi_platform_rhel,multi_platform_fedora,Oracle Linux 8

authselect select sssd --force
authselect enable-feature with-faillock
> "{{{ pam_faillock_conf_path }}}"
echo "even_deny_root" >> "{{{ pam_faillock_conf_path }}}"
echo "silent" >> "{{{ pam_faillock_conf_path }}}"
