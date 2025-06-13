#!/bin/bash

ssh_approved_macs="hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256"
ssh_scrambled_macs="hmac-sha2-256,hmac-sha2-512,hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com"

for config_file in /etc/ssh/ssh_config /etc/ssh/ssh_config.d/*
do 
    [[ -f "$config_file" ]] || continue
    sed -i "/^MACs.*/Id" "$config_file"
done
