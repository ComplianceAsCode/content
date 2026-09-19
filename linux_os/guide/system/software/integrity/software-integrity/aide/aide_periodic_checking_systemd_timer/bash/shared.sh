# platform = multi_platform_all

{{{ bash_package_install("aide") }}}

{{% set aide_service = 'aide.service' %}}
{{% set aide_timer = 'aide.timer' %}}

{{% if product in ["sle16"] %}}
cat > /etc/aide_service.conf <<EOF
@@include /etc/aide.conf
EOF
ln -s /usr/lib/systemd/system/{{{ aide_service }}} /etc/systemd/system/multi-user.target.wants/{{{ aide_service }}}
{{% else %}}
# create unit file for periodic aide database check
cat > /etc/systemd/system/{{{ aide_service }}} <<EOF
[Unit]
Description=Aide Check
[Service]
Type=simple
ExecStart={{{ aide_bin_path }}} --check
[Install]
WantedBy=multi-user.target
EOF

# create unit file for the aide timer
cat > /etc/systemd/system/{{{ aide_timer }}} <<EOF
[Unit]
Description=Aide check every day at 5AM
[Timer]
OnCalendar=*-*-* 05:00:00
Unit={{{ aide_service }}}
[Install]
WantedBy=multi-user.target
EOF

#  setup service unit files attributes
chown root:root /etc/systemd/system/{{{ aide_timer }}}
chmod 0644 /etc/systemd/system/{{{ aide_timer }}}
chown root:root /etc/systemd/system/{{{ aide_service }}}
chmod 0644 /etc/systemd/system/{{{ aide_service }}}
{{% endif %}}
# enable the aide related services
systemctl daemon-reload

systemctl unmask {{{ aide_service }}}
systemctl enable {{{ aide_service }}}
systemctl unmask {{{ aide_timer }}}
systemctl enable {{{ aide_timer }}}

if [[ $(systemctl is-system-running) != "offline" ]]; then
  systemctl start {{{ aide_timer }}}
fi
