# platform = multi_platform_ubuntu

{{% if product in ["ubuntu2404"] %}}
find -L /bin/ /sbin/ /usr/bin/ /usr/sbin/ /usr/local/bin/ /usr/local/sbin/ -maxdepth 1 -type f  ! -group root ! -group daemon ! -group adm ! -group shadow ! -group mail ! -group crontab ! -group _ssh -regextype posix-extended -regex '.*' -exec chgrp -L root {} \;

{{% else %}}
for SYSCMDFILES in /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin
do
   find -L $SYSCMDFILES ! -group root -type f ! -perm /2000 -exec chgrp root '{}' \;
done
{{% endif %}}
