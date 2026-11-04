# platform = multi_platform_all


{{% if "rhel" in families %}}
mkdir -p /etc/systemd/system.conf.d
cat << EOF > /etc/systemd/system.conf.d/55-CtrlAltDel-BurstAction.conf
[Manager]
CtrlAltDelBurstAction=none
EOF
systemctl daemon-reload
{{% else %}}
{{{ bash_replace_or_append('/etc/systemd/system.conf', '^CtrlAltDelBurstAction=', 'none', '%s=%s', cce_identifiers=cce_identifiers) }}}
{{% endif %}}
