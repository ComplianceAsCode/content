#!/bin/bash

sed -i "/^\s*PubkeyAuthentication.*/Id" /etc/ssh/sshd_config.d/*

echo 'PubkeyAuthentication no' > /etc/ssh/sshd_config
