#!/bin/bash
# platform = multi_platform_all
# packages = syslog-ng,linux-base
# remediation = none

mkdir -p /etc/syslog-ng/conf.d
cat > /etc/syslog-ng/conf.d/cac-test.conf <<'CONF'
# The destination is defined, but no log statement uses it.
destination d_cac_remote { network("loghost.example.com" transport("tcp") port(514)); };
CONF
