find /bin/ \
/usr/bin/ \
/usr/local/bin/ \
/sbin/ \
/usr/sbin/ \
/usr/local/sbin/ \
\! -user root -execdir chown root {} \;
