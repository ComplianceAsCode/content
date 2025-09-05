#!/bin/bash
# variables = var_pam_wheel_group_for_su=sugroup

GRP_NAME=sugroup

groupadd ${GRP_NAME}


useradd -m -U testuser1
useradd -m -U testuser2

usermod -G ${GRP_NAME} -a testuser1
usermod -G ${GRP_NAME} -a testuser2
