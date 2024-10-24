# platform = multi_platform_all

{{% if product in ["fedora", "ol8", "ol9", "sle12", "sle15",] or 'rhel' in product -%}}
{{% set sulogin="-/usr/lib/systemd/systemd-sulogin-shell rescue" %}}
{{%- else -%}}
{{% set sulogin='-/bin/sh -c "/sbin/sulogin; /usr/bin/systemctl --fail --no-block default"'  %}}
{{%- endif %}}

{{{ bash_ensure_ini_config("/etc/systemd/system/rescue.service.d/10-oscap.conf", "Service", "ExecStart", sulogin) }}}
