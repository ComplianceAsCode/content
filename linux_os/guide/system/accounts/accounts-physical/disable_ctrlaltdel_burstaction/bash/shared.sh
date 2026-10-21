# platform = multi_platform_all


{{% if product == "rhel8" or product == "rhel9" %}}
mkdir -p /etc/systemd/system.conf.d
printf '%s\n' '[Manager]' 'CtrlAltDelBurstAction=none' > /etc/systemd/system.conf.d/55-CtrlAltDel-BurstAction.conf
systemctl daemon-reload
{{% elif product == "rhel10" %}}
{{{ bash_replace_or_append('/etc/systemd/system.conf', '^CtrlAltDelBurstAction=', 'none', '%s=%s', cce_identifiers=cce_identifiers) }}}
{{% else %}}
{{{ bash_replace_or_append('/etc/systemd/system.conf', '^CtrlAltDelBurstAction=', 'none', '%s=%s', cce_identifiers=cce_identifiers) }}}
{{% endif %}}
