# platform = Red Hat Virtualization 4,multi_platform_rhel,multi_platform_ol,multi_platform_sle,multi_platform_slmicro
find /bin/ \
/usr/bin/ \
/usr/local/bin/ \
/sbin/ \
/usr/sbin/ \
/usr/local/sbin/ \
/usr/libexec \
\! -user root -execdir chown root {} \;
