#!/bin/bash
# packages = tftp-server

dnf install -y tftp-server


cat <<EOF > /etc/systemd/system/tftp.service
[Service]
ExecStart=/usr/sbin/in.tftpd -s /var/lib/tftpboot
EOF
