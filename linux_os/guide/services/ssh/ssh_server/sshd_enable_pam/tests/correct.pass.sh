#!/bin/bash

sed -i "/^\s*UsePAM.*/Id" /etc/ssh/sshd_config.d/*

echo 'UsePAM yes' > /etc/ssh/sshd_config
