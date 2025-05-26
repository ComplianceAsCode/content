#!/bin/bash

{{%- if product == 'ubuntu2404' %}}
sshd_approved_ciphers="aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes128-ctr"
sshd_scrambled_ciphers="aes128-gcm@openssh.com,aes256-gcm@openssh.com,aes256-ctr,aes128-ctr"
{{%- elif product == "ubuntu2204" %}}
sshd_approved_ciphers="aes256-ctr,aes256-gcm@openssh.com,aes192-ctr,aes128-ctr,aes128-gcm@openssh.com"
sshd_scrambled_ciphers="aes128-gcm@openssh.com,aes256-ctr,aes256-gcm@openssh.com,aes192-ctr,aes128-ctr"
{{%- else %}}
sshd_approved_ciphers="aes256-ctr,aes192-ctr,aes128-ctr"
sshd_scrambled_ciphers="aes128-ctr,aes192-ctr,aes256-ctr"
{{%- endif %}}

for config_file in /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*
do 
    [[ -f "$config_file" ]] || continue
    sed -i "/^Ciphers.*/Id" "$config_file"
done
