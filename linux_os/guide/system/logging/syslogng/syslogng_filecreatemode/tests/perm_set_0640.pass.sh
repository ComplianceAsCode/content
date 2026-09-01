#!/bin/bash
# platform = multi_platform_all

mkdir -p /etc/syslog-ng/conf.d

cat << 'EOF' > /etc/syslog-ng/syslog-ng.conf
@version: 4.2

options {
    perm(0640);
};

source s_local { systemd-journal(); internal(); };
EOF
