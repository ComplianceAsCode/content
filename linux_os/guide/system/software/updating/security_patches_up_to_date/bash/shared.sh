# platform = multi_platform_ol,multi_platform_sle,multi_platform_slmicro
# reboot = true
# strategy = patch
# complexity = low
# disruption = high

{{% if pkg_manager == "zypper" %}}
zypper patch -g security -y
{{% else %}}
yum -y update
{{% endif %}}
