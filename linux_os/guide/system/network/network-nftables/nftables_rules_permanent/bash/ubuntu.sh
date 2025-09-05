# platform = multi_platform_ubuntu
# reboot = false
# strategy = restrict
# complexity = low
# disruption = high

{{{ bash_instantiate_variables("var_nftables_master_config_file") }}}

{{{ bash_instantiate_variables("var_nftables_family") }}}

if [ ! -f "${var_nftables_master_config_file}" ]; then
    touch "${var_nftables_master_config_file}"
fi

nft list ruleset > "/etc/${var_nftables_family}-filter.rules"

grep -qxF 'include "/etc/'"${var_nftables_family}"'-filter.rules"' "${var_nftables_master_config_file}" \
    || echo 'include "/etc/'"${var_nftables_family}"'-filter.rules"' >> "${var_nftables_master_config_file}"
