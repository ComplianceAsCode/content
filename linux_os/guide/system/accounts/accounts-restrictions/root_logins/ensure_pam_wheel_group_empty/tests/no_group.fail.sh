#!/bin/bash
# variables = var_pam_wheel_group_for_su=sugroup

GRP_NAME=sugroup
if grep -q ${GRP_NAME} /etc/group; then
    groupdel -f ${GRP_NAME}
fi
