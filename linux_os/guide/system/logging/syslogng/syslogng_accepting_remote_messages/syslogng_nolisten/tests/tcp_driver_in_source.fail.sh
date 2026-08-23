#!/bin/bash
# platform = multi_platform_all

mkdir -p /etc/syslog-ng/conf.d

cat << 'EOF' > /etc/syslog-ng/syslog-ng.conf
@version: 4.2

source s_net {
    tcp(ip("0.0.0.0") port(514));
};

destination d_auth { file("/var/log/auth.log"); };

log { source(s_net); destination(d_auth); };
EOF
