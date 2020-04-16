#!/bin/bash
#

sed -i "/^AllowTcpForwarding.*/d" /etc/ssh/sshd_config
