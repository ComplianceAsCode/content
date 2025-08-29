#!/bin/bash
# platform = multi_platform_ubuntu
# packages = rsyslog

chown root -R /var/log/*

touch /var/log/test.log
chown nobody /var/log/test.log
