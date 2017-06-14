# platform = Red Hat Enterprise Linux 5
grep path.*/ /etc/kdump.conf | awk '{ print $2 }' | chown root