#!/bin/bash
# variables = var_sshd_set_maxstartups=10:30:60

sed -i "/^MaxStartups.*/d" /etc/ssh/sshd_config
