#!/bin/bash

source common.sh
echo "DenyUsers testuser1 testuser2 testuser3" >> /etc/ssh/sshd_config
echo "DenyGroups testgroup1 testgroup2 testgroup3" >> /etc/ssh/sshd_config
