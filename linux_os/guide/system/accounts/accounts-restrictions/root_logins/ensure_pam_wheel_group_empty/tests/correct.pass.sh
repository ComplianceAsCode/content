#!/bin/bash
# variables = var_pam_wheel_group_for_su=sugroup

GRP_NAME=sugroup

groupadd ${GRP_NAME}

# group must be empty
grp_memb=$(groupmems -g ${GRP_NAME} -l)
if [ -n "${grp_memb}" ]; then
    for memb in ${grp_memb}; do
        deluser ${memb} ${GRP_NAME}
    done
fi
