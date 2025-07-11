# platform = multi_platform_ubuntu

{{% if product in ["ubuntu2404"] %}}
find -P /bin/ /sbin/ /usr/bin/ /usr/sbin/ /usr/local/bin/ /usr/local/sbin/ -maxdepth 1 -type f  \! -gid -{{{ gid_min }}} -regextype posix-extended -regex '.*' -exec chgrp --no-dereference root {} \; || true
{{% else %}}
find -P /bin/ /sbin/ /usr/bin/ /usr/sbin/ /usr/local/bin/ /usr/local/sbin/ \! -gid -{{{ gid_min }}} -type f ! -perm /2000 -exec chgrp root '{}' \; || true
{{% endif %}}
