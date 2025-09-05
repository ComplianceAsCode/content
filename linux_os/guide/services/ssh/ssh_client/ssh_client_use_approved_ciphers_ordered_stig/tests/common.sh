#!/bin/bash

{{%- if product == 'ubuntu2404' %}}
ssh_approved_ciphers="aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes128-ctr"
ssh_scrambled_ciphers="aes128-gcm@openssh.com,aes256-gcm@openssh.com,aes256-ctr,aes128-ctr"
{{%- endif %}}

for config_file in /etc/ssh/ssh_config /etc/ssh/ssh_config.d/*
do 
    [[ -f "$config_file" ]] || continue
    sed -i "/^Ciphers.*/Id" "$config_file"
done
