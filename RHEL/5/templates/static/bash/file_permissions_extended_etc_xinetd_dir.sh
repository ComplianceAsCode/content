# platform = Red Hat Enterprise Linux 5
find /etc/xinetd.d -type f 2>/dev/null | xargs setfacl --remove-all