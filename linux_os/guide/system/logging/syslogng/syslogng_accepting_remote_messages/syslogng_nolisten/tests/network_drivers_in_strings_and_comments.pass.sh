#!/bin/bash
# platform = multi_platform_all
# packages = linux-base

mkdir -p /etc/syslog-ng/conf.d

cat << 'EOF2' > /etc/syslog-ng/syslog-ng.conf
@version: 4.2

source s_local {
    # udp(ip("0.0.0.0") port(514));
    file("/var/log/app.log" program_override("tcp(app)"));
};

destination d_auth { file("/var/log/auth.log"); };

log { source(s_local); destination(d_auth); };
EOF2
