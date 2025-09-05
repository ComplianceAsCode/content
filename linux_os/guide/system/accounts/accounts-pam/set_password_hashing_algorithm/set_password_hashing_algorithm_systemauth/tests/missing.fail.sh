#!/bin/bash
# platform = Red Hat Enterprise Linux 7,Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol

sed -i --follow-symlinks '/^password.*sufficient.*pam_unix\.so/ s/sha512//g' "/etc/pam.d/system-auth"
