#!/bin/bash
# platform = multi_platform_all
# packages = syslog-ng,linux-base
# remediation = none

mkdir -p /etc/syslog-ng/conf.d
cat > /etc/syslog-ng/conf.d/cac-test.conf <<'CONF'
# udp() is used in a source, and the destination writes to a local file.
source s_cac_net { udp(ip("0.0.0.0") port(514)); };
destination d_cac_file { file("/var/log/cac-remote.log"); };
log { source(s_cac_net); destination(d_cac_file); };
CONF
