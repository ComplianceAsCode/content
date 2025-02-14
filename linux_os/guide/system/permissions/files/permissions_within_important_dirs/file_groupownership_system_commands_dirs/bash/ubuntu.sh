# platform = multi_platform_ubuntu

for SYSCMDFILES in /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin
do
   find -L $SYSCMDFILES ! -group root -type f ! -perm /2000 -exec chgrp root '{}' \;
done
