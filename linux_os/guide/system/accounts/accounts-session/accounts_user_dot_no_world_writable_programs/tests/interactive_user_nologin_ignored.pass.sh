#!/bin/bash

source common.sh

NO_SHELL_USER="cac_user_no_shell"
useradd -m -s /sbin/nologin $NO_SHELL_USER
user_init_dot_file="/home/$NO_SHELL_USER/.profile"
echo "sudo bash $world_writable_file" >> $user_init_dot_file
