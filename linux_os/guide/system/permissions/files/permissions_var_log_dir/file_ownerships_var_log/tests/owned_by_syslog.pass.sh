#!/bin/bash
# platform = multi_platform_ubuntu

useradd -r syslog || true

chown root -R /var/log/*

touch /var/log/test.log
chown syslog /var/log/test.log
