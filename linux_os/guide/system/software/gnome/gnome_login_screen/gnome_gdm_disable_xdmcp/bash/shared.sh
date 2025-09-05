# platform = multi_platform_all

{{% if 'ubuntu' in product %}}
{{% set gdm_conf_path = "/etc/gdm3/custom.conf" %}}
{{% else %}}
{{% set gdm_conf_path = "/etc/gdm/custom.conf" %}}
{{% endif %}}

{{{ bash_ini_file_set(gdm_conf_path, "xdmcp", "Enable", "false") }}}
