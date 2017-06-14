# platform = Red Hat Enterprise Linux 5
find /home -type f 2>/dev/null | xargs setfacl --remove-all