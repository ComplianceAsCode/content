# platform = Red Hat Virtualization 4,multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_slmicro,multi_platform_almalinux

{{% if 'sle' in product or 'slmicro' in produc %}}
zypper -q --no-remote ref
{{% endif %}}

{{{ bash_package_install("aide") }}}
{{% if 'sle' in product or 'slmicro' in product %}}
/usr/bin/aide --init
/bin/cp -p /var/lib/aide/aide.db.new /var/lib/aide/aide.db
{{% else %}}
/usr/sbin/aide --init
/bin/cp -p /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
{{% endif %}}
