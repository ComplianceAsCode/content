#!/bin/bash
# platform = multi_platform_ubuntu

useradd -m -s /bin/bash test_user_with_shell

chown root:root -R /var/log/*

touch /var/log/test_log_file
chown test_user_with_shell /var/log/test_log_file
