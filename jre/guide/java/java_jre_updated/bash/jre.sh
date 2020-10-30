# platform = Java Runtime Environment

{{% if pkg_manager == "zypper" %}}
zypper patch -g security -y
{{% else %}}
yum -y update
{{% endif %}}
