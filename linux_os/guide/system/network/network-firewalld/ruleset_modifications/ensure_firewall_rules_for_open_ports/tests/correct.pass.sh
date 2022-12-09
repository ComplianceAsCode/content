#!/bin/bash
# packages = firewalld
source common.sh

# check if ssh started
is_sshd_active=$(systemctl status sshd|grep Active|awk '{print $2}')
if [ "${is_sshd_active}" != "active" ]; then
# start ssh if not - to have for sure at least one network service running
    systemctl start sshd
fi

listening_tcp_ports=($(listening_ports "t"))
listening_udp_ports=($(listening_ports "u"))
# add all listening ports to firewalld
zone_cfg_template=$(zone_cfg_begin)
for port in "${listening_tcp_ports[@]}"; do
    if [ "${port}" == "22" ];then
        zone_cfg_template+="
        <service name=\"ssh\"/>"
    else
        zone_cfg_template+="
        <port port=\"${port}\" protocol=\"tcp\"/>"
    fi
done

for port in "${listening_udp_ports[@]}"; do
    zone_cfg_template+="
    <port port=\"${port}\" protocol=\"udp\"/>" 
done
zone_cfg_template+=$(zone_cfg_end)
echo "${zone_cfg_template}" > $(get_default_firewalld_zone_cfg)
