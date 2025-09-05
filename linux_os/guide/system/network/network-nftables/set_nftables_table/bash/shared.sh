# platform = multi_platform_all
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

{{{ bash_instantiate_variables("var_nftables_family") }}}
{{{ bash_instantiate_variables("var_nftables_table") }}}

if ! nft list table $var_nftables_family $var_nftables_table; then
  nft create table "$var_nftables_family" "$var_nftables_table"
fi
