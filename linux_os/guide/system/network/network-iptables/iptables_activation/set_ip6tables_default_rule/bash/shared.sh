{{% if 'ubuntu' in product %}}
# platform = Not Applicable
{{% else %}}
# platform = multi_platform_all
{{% endif %}}
sed -i 's/^:INPUT ACCEPT.*/:INPUT DROP [0:0]/g' /etc/sysconfig/ip6tables
