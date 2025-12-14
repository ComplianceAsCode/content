#!/bin/bash
# platform = multi_platform_ubuntu
# packages = rsyslog

chown root -R /var/log/*

groupadd testgroup
useradd testUser
usermod -g testgroup testUser

touch /var/log/test.log
chgrp testgroup /var/log/test.log
