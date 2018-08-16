# platform = multi_platform_rhel
find /bin/ \
/usr/bin/ \
/usr/local/bin/ \
/sbin/ \
/usr/sbin/ \
/usr/local/sbin/ \
/usr/libexec \
\! -user root -execdir chown root {} \;
