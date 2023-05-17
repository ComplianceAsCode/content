#!/bin/bash
# variables = var_nftables_master_config_file=/etc/sysconfig/nftables.conf
# platform = multi_platform_sle

{{% set nftables_family_names = ['bridge', 'arp', 'inet'] %}}

# make sure file starts from empty
rm "/etc/sysconfig/nftables.conf"

# fill in required config
{{% for family in nftables_family_names %}}
echo 'include /etc/nftables/{{{ family }}}-filter' >> "/etc/sysconfig/nftables.conf"
{{% endfor %}}

