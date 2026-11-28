# platform = multi_platform_all

{{% if 'debian' in product %}}
{{% set gdm_conf_path = '/etc/gdm3/daemon.conf' %}}
{{% elif 'ubuntu' in product %}}
{{% set gdm_conf_path = '/etc/gdm3/custom.conf' %}}
{{% else %}}
{{% set gdm_conf_path = '/etc/gdm/custom.conf' %}}
{{% endif %}}

{{{ bash_ensure_ini_config(gdm_conf_path, "daemon", "WaylandEnable", "false") }}}
