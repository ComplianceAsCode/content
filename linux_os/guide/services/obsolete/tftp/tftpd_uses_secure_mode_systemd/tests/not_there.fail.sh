#!/bin/bash
# packages = tftp-server

cat <<EOF > /etc/systemd/system/tftp.service
[Service]
ExecStart=/usr/sbin/in.tftpd
EOF
