# platform = Red Hat Enterprise Linux 5
grep / /etc/aliases | grep -v "#" | sed s/^[^\/]*// | xargs setfacl --remove-all