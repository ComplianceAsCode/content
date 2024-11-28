#!/bin/bash
# packages = systemd
# variables = var_multiple_time_servers=0.suse.pool.ntp.org,1.suse.pool.ntp.org,2.suse.pool.ntp.org,3.suse.pool.ntp.org

source common.sh

cat <<EOF >/etc/systemd/timesyncd.d/oscap-remedy.conf
NTP=0.suse.pool.ntp.org,1.suse.pool.ntp.org
FallbackNTP=2.suse.pool.ntp.org,3.suse.pool.ntp.org
EOF
