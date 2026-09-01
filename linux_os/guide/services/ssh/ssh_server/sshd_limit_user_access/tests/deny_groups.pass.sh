#!/bin/bash

source common.sh
echo "DenyGroups testgroup1 testgroup2 testgroup3" >> "{{{ sshd_main_config_file }}}"
