# platform = Red Hat Enterprise Linux 5
find /etc/skel 2>/dev/null | xargs setfacl --remove-all