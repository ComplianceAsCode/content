#!/bin/bash
# platform = multi_platform_all
# packages = linux-base

mkdir -p /etc/syslog-ng/conf.d

cat << 'EOF2' > /etc/syslog-ng/syslog-ng.conf
@version: 4.2

source s_local {
    systemd-journal();
    internal();
};

destination d_remote {
    udp("loghost.example.com" port(514));
};

log { source(s_local); destination(d_remote); };
EOF2
