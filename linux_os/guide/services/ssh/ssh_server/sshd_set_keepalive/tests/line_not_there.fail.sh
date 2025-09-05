#!/bin/bash
# variables = var_sshd_set_keepalive=1

sed -i "/^ClientAliveCountMax.*/d" /etc/ssh/sshd_config
