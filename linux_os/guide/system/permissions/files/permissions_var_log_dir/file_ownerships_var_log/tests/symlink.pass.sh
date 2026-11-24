#!/bin/bash
# platform = multi_platform_debian,multi_platform_ubuntu

useradd -m -s /bin/bash test_user_with_shell

chown root -R /var/log/*

ln -s /etc/issue /var/log/test.log.symlink
chown -h test_user_with_shell /var/log/test.log.symlink
