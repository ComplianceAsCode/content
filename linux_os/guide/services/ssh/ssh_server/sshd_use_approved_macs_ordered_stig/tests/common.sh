#!/bin/bash

{{%- if product == "ubuntu2404" %}}
sshd_approved_macs="hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256"
sshd_scrambled_macs="hmac-sha2-256,hmac-sha2-512,hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com"
{{%- elif product == "ubuntu2204" %}}
sshd_approved_macs="hmac-sha2-512,hmac-sha2-512-etm@openssh.com,hmac-sha2-256,hmac-sha2-256-etm@openssh.com"
sshd_scrambled_macs="hmac-sha2-256,hmac-sha2-512,hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com"
{{%- else %}}
sshd_approved_macs="hmac-sha2-512,hmac-sha2-256"
sshd_scrambled_macs="hmac-sha2-256,hmac-sha2-512"
{{%- endif %}}

for config_file in /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*
do 
    [[ -f "$config_file" ]] || continue
    sed -i "/^MACs.*/Id" "$config_file"
done
