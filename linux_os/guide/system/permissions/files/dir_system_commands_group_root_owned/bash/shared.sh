# platform = multi_platform_sle,multi_platform_slmicro
for SYSCMDDIRS in /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin
do
     find -L $SYSCMDDIRS ! -group root -type d -exec chgrp root '{}' \; 
done
