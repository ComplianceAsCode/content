#!/bin/bash
# platform = Red Hat Enterprise Linux 7,Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_wrlinux

sed -i --follow-symlinks '/nullok/d' /etc/pam.d/system-auth
