#!/bin/bash
# packages = tftp-server

TFTP_SERVICE_FILE="/usr/lib/systemd/system/tftp.service"

if grep -q 'ExecStart' "$TFTP_SERVICE_FILE"; then
    sed -i -E 's;^([[:blank:]]*ExecStart[[:blank:]]*=).*;\1 /usr/sbin/in.tftpd --something;' "$TFTP_SERVICE_FILE"
else
    sed -i "/^\[Service\]/a ExecStart=/usr/sbin/in.tftpd --something" "$TFTP_SERVICE_FILE"
fi

systemctl daemon-reload
