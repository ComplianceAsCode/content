#!/bin/bash
# platform = multi_platform_ubuntu

useradd -m -s /usr/sbin/nologin test_user_no_shell

chown root:root -R /var/log/*

touch /var/log/test_log_file
chgrp test_user_no_shell /var/log/test_log_file
