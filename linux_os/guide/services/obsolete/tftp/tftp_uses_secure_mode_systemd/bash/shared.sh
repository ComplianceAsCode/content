# platform = multi_platform_all

{{{ bash_instantiate_variables ("var_tftpd_secure_directory") }}}

TFTP_SERVICE_FILE="/usr/lib/systemd/system/tftp.service"

if grep -q 'ExecStart' "$TFTP_SERVICE_FILE"; then
    sed -i "s;^[[:blank:]]*ExecStart[[:blank:]]*=.*$;ExecStart=/usr/sbin/in.tftpd -s $var_tftpd_secure_directory;" "$TFTP_SERVICE_FILE"
else
    sed -i "/^\[Service\]/a ExecStart=/usr/sbin/in.tftpd -s $var_tftpd_secure_directory" "$TFTP_SERVICE_FILE"
fi

systemctl daemon-reload
systemctl restart tftp.service
