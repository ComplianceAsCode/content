#!/bin/bash
# platform = multi_platform_all
# packages = linux-base,syslog-ng-core

mkdir -p /etc/syslog-ng/conf.d

cat << 'EOF2' > /etc/syslog-ng/syslog-ng.conf
@version: 4.2

source s_net {
    network(
        ip("0.0.0.0")
        transport("tcp")
        port(601)
    );
};

destination d_auth { file("/var/log/auth.log"); };

log { source(s_net); destination(d_auth); };
EOF2
