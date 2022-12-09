#!/bin/bash
# packages = firewalld
source common.sh

# check if ssh started
is_sshd_active=$(systemctl status sshd|grep Active|awk '{print $2}')
if [ "${is_sshd_active}" != "active" ]; then
# start ssh if not - to have for sure at least one network service running
    systemctl start sshd
fi

# add no listening ports to firewalld
zone_cfg_template=$(zone_cfg_begin)
zone_cfg_template+=$(zone_cfg_end)
echo "${zone_cfg_template}" > $(get_default_firewalld_zone_cfg)
