#!/bin/bash
# platform = multi_platform_all

mkdir -p /etc/syslog-ng/conf.d

cat << 'EOF' > /etc/syslog-ng/syslog-ng.conf
@version: 4.2

options {
    flush_lines(0);
};

source s_local { systemd-journal(); internal(); };
EOF

find /etc/syslog-ng -name "*.conf" -exec sed -i '/^\s*perm(/d' {} \;
