#!/bin/bash
# platform = multi_platform_ol

if  ! grep "pam_succeed_if" /etc/pam.d/sudo ; then 
    echo "auth required pam_succeed_if.so quiet user ingroup wheel" >> /etc/pam.d/sudo
fi 
