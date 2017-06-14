# platform = Red Hat Enterprise Linux 5
grep path /etc/kdump.conf | grep -v "#" | awk '{ print $2 }' | xargs setfacl --remove-all