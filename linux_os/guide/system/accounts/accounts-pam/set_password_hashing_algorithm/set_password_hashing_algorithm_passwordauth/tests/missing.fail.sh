#!/bin/bash
# platform = Oracle Linux 7,Red Hat Virtualization 4,multi_platform_fedora

sed -i --follow-symlinks '/^password.*sufficient.*pam_unix\.so/ s/sha512//g' "/etc/pam.d/password-auth"
