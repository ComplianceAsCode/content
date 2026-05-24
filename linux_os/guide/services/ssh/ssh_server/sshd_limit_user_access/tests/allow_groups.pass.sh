#!/bin/bash

source common.sh
echo "AllowGroups testgroup1 testgroup2 testgroup3" >> "{{{ sshd_main_config_file }}}"
