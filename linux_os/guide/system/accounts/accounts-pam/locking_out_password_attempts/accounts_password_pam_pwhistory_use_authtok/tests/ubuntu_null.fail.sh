#!/bin/bash
# platform = multi_platform_ubuntu
# packages = pam

if [[ -f /usr/share/pam-configs/pwhistory ]]; then
    pam-auth-update --disable pwhistory
fi
