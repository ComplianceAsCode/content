# platform = multi_platform_sle

for SYSCMDDIRS in /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin
do
   find -L $SYSCMDDIRS \! -user root -type d -exec chown root {} \; 
done
