# platform = multi_platform_all
{{% if 'ubuntu' in product %}}
{{{ bash_package_install("iptables-persistent") }}}
sed -i 's/^:INPUT ACCEPT.*/:INPUT DROP [0:0]/g' /etc/iptables/rules.v6
{{% else %}}
sed -i 's/^:INPUT ACCEPT.*/:INPUT DROP [0:0]/g' /etc/sysconfig/ip6tables
{{% endif %}}

