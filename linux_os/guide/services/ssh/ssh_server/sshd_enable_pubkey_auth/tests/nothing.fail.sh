#!/bin/bash

sed -i "/^\s*PubkeyAuthentication.*/Id" /etc/ssh/sshd_config.d/*

echo > /etc/ssh/sshd_config
