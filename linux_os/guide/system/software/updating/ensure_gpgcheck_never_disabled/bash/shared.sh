# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_rhv,multi_platform_sle,multi_platform_slmicro
{{% if product in ["sle12", "sle15", "slmicro5"] %}}
sed -i 's/gpgcheck\s*=.*/gpgcheck=1/g' /etc/zypp/repos.d/*
{{% else %}}
sed -i 's/gpgcheck\s*=.*/gpgcheck=1/g' /etc/yum.repos.d/*
{{% endif %}}
