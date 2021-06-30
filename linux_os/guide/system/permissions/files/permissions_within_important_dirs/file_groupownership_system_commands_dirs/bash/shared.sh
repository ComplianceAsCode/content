# platform = multi_platform_sle, Red Hat Enterprise Linux 8,multi_platform_fedora

for SYSCMDFILES in /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin
do
   find -L $SYSCMDFILES \! -group root -type f -exec chgrp root '{}' \;
done
