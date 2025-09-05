#!/bin/bash

mkdir -p /etc/usbguard
cat << EOF > /etc/usbguard/usbguard-daemon.conf
# AuditBackend=LinuxAudit
EOF
