#!/bin/bash
# platform = multi_platform_fedora,multi_platform_rhel

rm -rf /etc/systemd/system/rescue.service.d
mkdir -p /etc/systemd/system/rescue.service.d
cat << EOF > /etc/systemd/system/rescue.service.d/10-automatus.conf
[Service]
ExecStart=
ExecStart=/bin/bash
EOF

