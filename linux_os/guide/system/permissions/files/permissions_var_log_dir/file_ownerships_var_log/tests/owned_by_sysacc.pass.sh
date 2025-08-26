#!/bin/bash
# platform = Ubuntu 22.04
# packages = rsyslog

chown root -R /var/log/*

useradd -r testUser

touch /var/log/test.log
chown testUser /var/log/test.log
