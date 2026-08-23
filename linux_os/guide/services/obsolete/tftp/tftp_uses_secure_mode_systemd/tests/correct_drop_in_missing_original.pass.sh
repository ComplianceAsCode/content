#!/bin/bash
# packages = tftp-server

DROPIN_DIR="/etc/systemd/system/tftp.service.d"
DROPIN_FILE="$DROPIN_DIR/correct_drop_in.conf"

TFTP_SERVICE_FILE="/usr/lib/systemd/system/tftp.service"

if grep -q 'ExecStart' "$TFTP_SERVICE_FILE"; then
    sed -i '/^[[:blank:]]*ExecStart[[:blank:]]*=.*/d' "$TFTP_SERVICE_FILE"
fi

mkdir -p "$DROPIN_DIR"

cat > "$DROPIN_FILE" << EOF
[Service]
# clear any existing ExecStart in the original unit
ExecStart=
# correct config
ExecStart=/usr/sbin/in.tftpd -s /var/lib/tftpboot
EOF

systemctl daemon-reload
