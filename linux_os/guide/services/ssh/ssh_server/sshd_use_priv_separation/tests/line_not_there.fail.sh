#!/bin/bash
#
# variables = var_sshd_priv_separation=sandbox

sed -i "/^UsePrivilegeSeparation.*/d" /etc/ssh/sshd_config
