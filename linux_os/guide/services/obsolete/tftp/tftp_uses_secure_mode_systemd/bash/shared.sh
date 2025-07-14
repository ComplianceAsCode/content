# platform = multi_platform_all

{{{ bash_instantiate_variables ("var_tftpd_secure_directory") }}}

DROPIN_DIR="/etc/systemd/system/tftp.service.d"
DROPIN_FILE="$DROPIN_DIR/override.conf"

mkdir -p "$DROPIN_DIR"

cat > "$DROPIN_FILE" << EOF
[Service]
# clear any existing ExecStart in the original unit
ExecStart=
ExecStart=/usr/sbin/in.tftpd -s $var_tftpd_secure_directory
EOF

systemctl daemon-reload
systemctl restart tftp.service
