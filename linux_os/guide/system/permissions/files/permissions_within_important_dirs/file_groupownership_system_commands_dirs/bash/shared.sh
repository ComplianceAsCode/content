# platform = multi_platform_fedora,multi_platform_ol,multi_platform_rhel,multi_platform_sle,multi_platform_slmicro,multi_platform_almalinux
{{% if 'ol9' in product %}}
find -P /bin /sbin /usr/bin /usr/sbin /usr/libexec /usr/local/bin /usr/local/sbin \! -group root -type f -exec chgrp root '{}' \; || true
{{% else %}}
find -P /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin \! -group root -type f -exec chgrp root '{}' \; || true
{{% endif %}}
