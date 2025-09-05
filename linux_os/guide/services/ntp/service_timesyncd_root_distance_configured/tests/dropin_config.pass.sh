#!/bin/bash
# packages = systemd

source common.sh

cat <<EOF >/etc/systemd/timesyncd.d/oscap-remedy.conf
NTP=0.suse.pool.ntp.org,1.suse.pool.ntp.org
FallbackNTP=2.suse.pool.ntp.org,3.suse.pool.ntp.org
RootDistanceMax=1
EOF
