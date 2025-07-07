# platform = multi_platform_ubuntu

{{% if product in ["ubuntu2404"] %}}
find -P /bin/ /sbin/ /usr/bin/ /usr/sbin/ /usr/local/bin/ /usr/local/sbin/ -maxdepth 1 -type f  \! -gid -{{{ gid_min }}} -regextype posix-extended -regex '.*' -exec chgrp -P root {} \;

{{% else %}}
for SYSCMDFILES in /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin
do
   find -P $SYSCMDFILES \! -gid -{{{ gid_min }}} -type f ! -perm /2000 -exec chgrp root '{}' \;
done
{{% endif %}}
