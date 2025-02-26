# platform = multi_platform_all
{{% if 'ubuntu' in product or 'debian' in product  %}}
{{{ bash_package_install("iptables-persistent") }}}
sed -i 's/^:INPUT ACCEPT.*/:INPUT DROP [0:0]/g' /etc/iptables/rules.v6
sed -i 's/^:OUTPUT ACCEPT.*/:OUTPUT DROP [0:0]/g' /etc/iptables/rules.v6
sed -i 's/^:FORWARD ACCEPT.*/:FORWARD DROP [0:0]/g' /etc/iptables/rules.v6
{{% else %}}
sed -i 's/^:INPUT ACCEPT.*/:INPUT DROP [0:0]/g' /etc/sysconfig/ip6tables
sed -i 's/^:OUTPUT ACCEPT.*/:OUTPUT DROP [0:0]/g' /etc/sysconfig/ip6tables
sed -i 's/^:FORWARD ACCEPT.*/:FORWARD DROP [0:0]/g' /etc/sysconfig/ip6tables
{{% endif %}}

