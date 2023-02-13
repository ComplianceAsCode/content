# platform = sle15
{{% set nftables_family_names = ['bridge', 'arp', 'inet'] %}}

# make sure file starts from empty
rm {{{ var_nftable_master_config_file }}}

# fill in required config
{{% for family in nftables_family_names %}}
echo 'include /etc/nftables/{{{ family }}}-filter' >> {{{ var_nftable_master_config_file }}}
{{% endfor %}}
