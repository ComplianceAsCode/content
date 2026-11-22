#!/bin/bash
# platform = multi_platform_all
# packages = syslog-ng,linux-base

mkdir -p /etc/syslog-ng/conf.d
cat > /etc/syslog-ng/conf.d/cac-test.conf <<'CONF'
destination d_cac_remote { network("loghost.example.com" transport("tcp") port(514)); };
log { source(s_src); destination(d_cac_remote); };
CONF
