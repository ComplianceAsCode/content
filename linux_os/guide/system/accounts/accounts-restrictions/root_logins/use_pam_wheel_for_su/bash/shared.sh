#!/bin/bash
# platform = multi_platform_rhel,multi_platform_fedora,multi_platform_ol,multi_platform_rhv

if ! grep -q pam_wheel /etc/pam.d/su; then
  sed '/^[\s]*#[\s]*auth[\s]+required[\s]+pam_wheel\.so use_uid$/s/^#//' -i /etc/pam.d/su
else
  echo "auth             required        pam_wheel.so use_uid" >> /etc/pam.d/su
fi
