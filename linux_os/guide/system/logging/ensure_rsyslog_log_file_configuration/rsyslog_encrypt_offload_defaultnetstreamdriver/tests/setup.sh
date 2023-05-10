#!/bin/bash

# Use this script to ensure the rsyslog directory structure and rsyslog conf file
# exist in the test env.
config_file=/etc/rsyslog.conf

# Ensure directory structure exists (useful for container based testing)
test -f $config_file || touch $config_file

mkdir -p /etc/rsyslog.d
