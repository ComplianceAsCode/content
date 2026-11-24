#!/bin/bash
# platform = multi_platform_all
# packages = linux-base,syslog-ng-core

mkdir -p /etc/syslog-ng/conf.d

cat << 'EOF2' > /etc/syslog-ng/conf.d/net.conf
source s_net { syslog(port(601)); };

destination d_net { file("/var/log/net.log"); };

log { source(s_net); destination(d_net); };
EOF2
