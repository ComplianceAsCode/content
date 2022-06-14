# platform = multi_platform_all

AUDISP_REMOTE_CONFIG="{{{ audisp_conf_path }}}/audisp-remote.conf"
{{% if product in ["rhel8", "fedora", "ol8", "rhv4"] %}}
option="^transport"
value="KRB5"
{{% else %}}
option="^enable_krb5"
value="yes"
{{% endif %}}

{{{ bash_replace_or_append("$AUDISP_REMOTE_CONFIG", "$option", "$value") }}}
