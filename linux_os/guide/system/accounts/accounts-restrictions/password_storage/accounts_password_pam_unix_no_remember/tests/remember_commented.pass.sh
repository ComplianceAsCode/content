#!/bin/bash
# platform = multi_platform_ubuntu

for pam_file in /etc/pam.d/common-*; do
    sed -i --follow-symlinks '/\bremember=\d+\b/d' $pam_file
    echo "# auth  sufficient  pam_unix.so try_first_pass bremember=1" >> $pam_file
done
