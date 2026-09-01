#!/bin/bash
# platform = multi_platform_all

mkdir -p /etc/syslog-ng/conf.d

cat << 'EOF' > /etc/syslog-ng/syslog-ng.conf
@version: 4.2

options {
    flush_lines(0);
    keep_hostname(yes);
};

source s_local {
    systemd-journal();
    internal();
};

destination d_auth { file("/var/log/auth.log"); };

log { source(s_local); destination(d_auth); };
EOF
