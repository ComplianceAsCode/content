# platform = multi_platform_all

{{% if product in ["fedora", "sle12", "sle15", "slmicro5"] or 'ol' in families or 'rhel' in product -%}}
{{% set sulogin="\\nExecStart=-/usr/lib/systemd/systemd-sulogin-shell rescue" %}}
{{%- else -%}}
{{% set sulogin='-/bin/sh -c "/sbin/sulogin; /usr/bin/systemctl --fail --no-block default"'  %}}
{{%- endif %}}

{{{ bash_ensure_ini_config("/etc/systemd/system/rescue.service.d/10-oscap.conf /etc/systemd/system/rescue.service.d/*.conf", "Service", "ExecStart", sulogin) }}}
