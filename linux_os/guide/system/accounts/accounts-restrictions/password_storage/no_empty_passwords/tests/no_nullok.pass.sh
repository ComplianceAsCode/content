#!/bin/bash
# platform = Oracle Linux 7,Red Hat Enterprise Linux 7,Red Hat Virtualization 4,multi_platform_fedora

sed -i --follow-symlinks '/nullok/d' /etc/pam.d/system-auth
sed -i --follow-symlinks '/nullok/d' /etc/pam.d/password-auth
