#!/bin/bash
# platform = Red Hat Enterprise Linux 10

rm -rf /etc/yum.repos.d/
mkdir -p /etc/yum.repos.d/

cat > /etc/yum.repos.d/rhel10.repo <<EOF
[rhel10]
name=RHEL 10
gpgcheck=yEs
EOF
