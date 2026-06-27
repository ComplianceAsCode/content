#!/bin/bash

source common.sh
echo "AllowUsers testuser1 testuser2 testuser3" >> "{{{ sshd_main_config_file }}}"
echo "AllowGroups testgroup1 testgroup2 testgroup3" >> "{{{ sshd_main_config_file }}}"
