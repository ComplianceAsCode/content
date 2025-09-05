# platform = multi_platform_all

{{{ bash_instantiate_variables ("var_tftpd_secure_directory") }}}

DROPIN_DIR="/etc/systemd/system/tftp.service.d"
DROPIN_FILE="$DROPIN_DIR/10-ssg-hardening.conf"
TFTP_SERVICE_FILE="/usr/lib/systemd/system/tftp.service"
REGEX_TFTP_SERVICE_FILE="^\s*ExecStart\s*=\s*/\S+\s+-s\s+(/\S+).*$"
REGEX_DROP_IN="(?s)\s*ExecStart=\s*.*(\s*ExecStart=\s*/\S+\s+-s\s+/\S+.*)"

# Remove bad configuration in drop-ins
if [ -d "$DROPIN_DIR" ]; then
    for override in "$DROPIN_DIR"/*.conf; do
        if [ -f "$override" ] && ! grep -qPzo "$REGEX_DROP_IN" "$override"; then
            sed -i '/^[[:space:]]*ExecStart=/ s/^/#/' "$override"
        fi
    done
fi

if [ -d "$DROPIN_DIR" ] && grep -qPzor "$REGEX_DROP_IN" "$DROPIN_DIR"; then
    exit 0
elif [ ! -d "$DROPIN_DIR" ] && grep -qE "$REGEX_TFTP_SERVICE_FILE" "$TFTP_SERVICE_FILE"; then
    exit 0
else
    mkdir -p "$DROPIN_DIR"

    cat > "$DROPIN_FILE" << EOF
[Service]
# clear any existing ExecStart in the original unit
ExecStart=
ExecStart=/usr/sbin/in.tftpd -s $var_tftpd_secure_directory
EOF
    systemctl daemon-reload
    systemctl restart tftp.service
fi
