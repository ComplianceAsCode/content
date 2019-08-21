#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp

mkdir -p /etc/usbguard
cat << EOF > /etc/usbguard/usbguard-daemon.conf
# No AuditBackend
# in usbguard-daemon.conf
EOF
