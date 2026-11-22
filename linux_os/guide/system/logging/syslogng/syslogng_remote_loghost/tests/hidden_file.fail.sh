#!/bin/bash
# platform = multi_platform_all
# packages = syslog-ng,linux-base
# remediation = none

mkdir -p /etc/syslog-ng/conf.d
# syslog-ng does not read files in conf.d whose names start with a dot.
rm -f /etc/syslog-ng/conf.d/cac-test.conf
cat > /etc/syslog-ng/conf.d/.cac-test.conf <<'CONF'
destination d_cac_remote { network("loghost.example.com" transport("tcp") port(514)); };
log { source(s_src); destination(d_cac_remote); };
CONF
