#!/bin/bash
# platform = Red Hat Enterprise Linux 9

rm -rf /etc/yum.repos.d/
mkdir -p /etc/yum.repos.d/

cat > /etc/yum.repos.d/rhel9.repo <<EOF
[rhel9]
name=RHEL 9
gpgcheck=TRUE
EOF
