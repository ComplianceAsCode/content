#!/bin/bash
# variables = var_pam_wheel_group_for_su=sugroup

if grep -q sugroup /etc/group; then
    groupdel -f sugroup
fi
