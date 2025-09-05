#!/bin/bash
# platform = Oracle Linux 7,Red Hat Enterprise Linux 7,Red Hat Virtualization 4,multi_platform_fedora

for pam_file in /etc/pam.d/system-auth /etc/pam.d/password-auth; do
    sed -i --follow-symlinks '/nullok/d' $pam_file
    echo "# auth  sufficient  pam_unix.so try_first_pass nullok" >> $pam_file
done
