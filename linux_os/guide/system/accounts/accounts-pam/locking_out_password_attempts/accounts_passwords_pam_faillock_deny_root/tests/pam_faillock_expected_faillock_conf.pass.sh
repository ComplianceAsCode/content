#!/bin/bash
# packages = authselect
# platform = multi_platform_fedora,Oracle Linux 9,multi_platform_rhel,multi_platform_fedora,Oracle Linux 8

authselect select sssd --force
authselect enable-feature with-faillock
> /etc/security/faillock.conf
echo "even_deny_root" >> /etc/security/faillock.conf
echo "silent" >> /etc/security/faillock.conf
