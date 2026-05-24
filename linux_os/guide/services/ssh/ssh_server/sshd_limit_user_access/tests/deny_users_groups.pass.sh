#!/bin/bash

source common.sh
echo "DenyUsers testuser1 testuser2 testuser3" >> "{{{ sshd_main_config_file }}}"
echo "DenyGroups testgroup1 testgroup2 testgroup3" >> "{{{ sshd_main_config_file }}}"
