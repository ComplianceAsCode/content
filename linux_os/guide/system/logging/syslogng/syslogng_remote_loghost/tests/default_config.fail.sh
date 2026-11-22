#!/bin/bash
# platform = multi_platform_all
# packages = syslog-ng,linux-base
# remediation = none

mkdir -p /etc/syslog-ng/conf.d
# Only the distribution configuration is present. On Debian it contains
# a commented example of a tcp() destination.
rm -f /etc/syslog-ng/conf.d/cac-test.conf
