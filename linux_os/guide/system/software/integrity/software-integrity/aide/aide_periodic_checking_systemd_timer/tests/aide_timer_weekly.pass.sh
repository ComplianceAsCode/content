#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_slmicro,multi_platform_almalinux
# packages = aide

{{% if 'suse' in families %}}
{{% set aide_service = 'aide.service' %}}
{{% set aide_timer = 'aide.timer' %}}
{{% else %}}
{{% set aide_service = 'aidecheck.service' %}}
{{% set aide_timer = 'aidecheck.timer' %}}
{{% endif %}}

{{% if product in ["sle16"] %}}
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

# create unit file for the aide check timer
cat > /etc/systemd/system/{{{ aide_timer }}} <<EOF
[Unit]
Description=Aide check every Monday
[Timer]
OnCalendar=Mon *-*-* 05:00:00
Unit={{{ aide_service }}}
[Install]
WantedBy=multi-user.target
EOF

#  setup service unit files attributes
chown root:root /etc/systemd/system/aide.*
chmod 0644 /etc/systemd/system/aide.*
{{% endif %}}

# enable the aide related services
systemctl daemon-reload
systemctl enable {{{ aide_service }}}
systemctl --now enable {{{ aide_timer }}}
