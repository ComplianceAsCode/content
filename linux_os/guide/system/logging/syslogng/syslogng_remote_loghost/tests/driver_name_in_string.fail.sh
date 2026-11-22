#!/bin/bash
# platform = multi_platform_all
# packages = syslog-ng,linux-base
# remediation = none

mkdir -p /etc/syslog-ng/conf.d
cat > /etc/syslog-ng/conf.d/cac-test.conf <<'CONF'
# The driver name only appears inside a string.
destination d_cac_file { file("/var/log/network(\"loghost.example.com\").log"); };
log { source(s_src); destination(d_cac_file); };
CONF
