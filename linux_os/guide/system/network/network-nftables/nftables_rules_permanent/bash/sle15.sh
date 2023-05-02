# platform = SUSE Linux Enterprise 15
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

{{% set nftables_family_names = ['bridge', 'arp', 'inet'] %}}

{{{ bash_instantiate_variables("var_nftables_master_config_file") }}}

if [ ! -f "${var_nftables_master_config_file}" ]; then
    touch "${var_nftables_master_config_file}"
fi

{{% for family in nftables_family_names %}}
grep -qxF 'include "/etc/nftables/{{{ family }}}-filter"' "${var_nftables_master_config_file}" \
    || echo 'include "/etc/nftables/{{{ family }}}-filter"' >> "${var_nftables_master_config_file}"
{{% endfor %}}
