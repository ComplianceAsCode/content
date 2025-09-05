# platform = multi_platform_all

{{{ bash_package_install("aide") }}}

# create unit file for periodic aide database check
cat > /etc/systemd/system/aidecheck.service <<EOF
[Unit]
Description=Aide Check
[Service]
Type=simple
ExecStart={{{ aide_bin_path }}} --check
[Install]
WantedBy=multi-user.target
EOF

# create unit file for the aide check timer
cat > /etc/systemd/system/aidecheck.timer <<EOF
[Unit]
Description=Aide check every day at 5AM
[Timer]
OnCalendar=*-*-* 05:00:00
Unit=aidecheck.service
[Install]
WantedBy=multi-user.target
EOF

#  setup service unit files attributes
chown root:root /etc/systemd/system/aidecheck.*
chmod 0644 /etc/systemd/system/aidecheck.*

# enable the aide related services
systemctl daemon-reload
systemctl enable aidecheck.service
systemctl --now enable aidecheck.timer
