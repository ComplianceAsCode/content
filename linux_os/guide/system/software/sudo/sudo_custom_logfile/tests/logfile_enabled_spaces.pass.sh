#!/bin/bash
# platform = multi_platform_all
# packages = sudo

# Test that OVAL check allows spaces around the equal sign
# This test scenario is a regression test of https://issues.redhat.com/browse/RHEL-1904

echo "Defaults logfile = /var/log/sudo.log" >> /etc/sudoers
