#!/bin/bash

source common.sh
echo "AllowUsers testuser1 testuser2 testuser3" >> /etc/ssh/sshd_config
echo "AllowGroups testgroup1 testgroup2 testgroup3" >> /etc/ssh/sshd_config
