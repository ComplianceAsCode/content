# platform = Red Hat Enterprise Linux 5
find / -name *.mib 2>/dev/null | xargs setfacl --remove-all