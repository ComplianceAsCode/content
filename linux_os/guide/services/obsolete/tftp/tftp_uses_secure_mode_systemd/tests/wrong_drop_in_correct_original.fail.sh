#!/bin/bash
# packages = tftp-server

DROPIN_DIR="/etc/systemd/system/tftp.service.d"
DROPIN_FILE="$DROPIN_DIR/wrong_drop_in.conf"

TFTP_SERVICE_FILE="/usr/lib/systemd/system/tftp.service"

if grep -q 'ExecStart' "$TFTP_SERVICE_FILE"; then
    sed -i -E 's;^([[:blank:]]*ExecStart[[:blank:]]*=[[:blank:]]*/[^\s]+).*;\1 -s /var/lib/tftpboot;' "$TFTP_SERVICE_FILE"
else
    sed -i "/^\[Service\]/a ExecStart=/usr/sbin/in.tftpd -s /var/lib/tftpboot" >> "$TFTP_SERVICE_FILE"
fi

mkdir -p "$DROPIN_DIR"

cat > "$DROPIN_FILE" << EOF
[Service]
# clear any existing ExecStart in the original unit
ExecStart=
# bad config
ExecStart=/usr/sbin/in.tftpd --something
EOF

systemctl daemon-reload
