#!/bin/bash
# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv

# uncomment the option if commented
  sed '/^[[:space:]]*#[[:space:]]*auth[[:space:]]\+required[[:space:]]\+pam_wheel\.so[[:space:]]\+use_uid$/s/^#//' -i /etc/pam.d/su

if ! grep -q '^[\s]*auth[\s]+required[\s]+pam_wheel\.so\[s]+use_uid$' /etc/pam.d/su; then
  echo "auth             required        pam_wheel.so use_uid" >> /etc/pam.d/su
fi
