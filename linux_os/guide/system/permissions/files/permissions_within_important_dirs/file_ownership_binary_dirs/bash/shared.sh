# platform = Red Hat Virtualization 4,multi_platform_rhel,multi_platform_ol,multi_platform_sle,multi_platform_slmicro,multi_platform_almalinux,multi_platform_ubuntu
{{% if 'ubuntu' in product %}}
find /bin/ /usr/bin/ /usr/local/bin/ /sbin/ /usr/sbin/ /usr/local/sbin/ \! -uid -100 -execdir chown root {} \;
{{% else %}}
find /bin/ /usr/bin/ /usr/local/bin/ /sbin/ /usr/sbin/ /usr/local/sbin/ /usr/libexec \! -user root -execdir chown root {} \;
{{% endif %}}
