# platform = Red Hat Enterprise Linux 5
find /etc/rc* /etc/init.d -type f 2>/dev/null | xargs setfacl --remove-all