#!/bin/bash
# packages = tftp-server

TFTP_SERVICE_FILE="/usr/lib/systemd/system/tftp.service"

if grep -q 'ExecStart' "$TFTP_SERVICE_FILE"; then
    sed -i '/^[[:blank:]]*ExecStart[[:blank:]]*=.*/d' "$TFTP_SERVICE_FILE"
fi

systemctl daemon-reload
