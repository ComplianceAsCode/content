# platform = multi_platform_sle

for SYSCMDFILES in /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin
do
   find -L $SYSCMDFILES \! -group root -type f -exec chgrp root '{}' \; 
done
