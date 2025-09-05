#!/bin/bash
# variables = var_pam_wheel_group_for_su=sugroup

GRP_NAME=sugroup
groupadd ${GRP_NAME}
for user in testuser1 testuser2; do
    useradd -m -U -G ${GRP_NAME} $user
done
