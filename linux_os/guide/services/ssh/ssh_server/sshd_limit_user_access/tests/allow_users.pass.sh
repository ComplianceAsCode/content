#!/bin/bash

source common.sh
echo "AllowUsers testuser1 testuser2 testuser3" >> "{{{ sshd_main_config_file }}}"
