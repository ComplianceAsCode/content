# platform = Red Hat Enterprise Linux 5
grep cron /etc/syslog.conf | grep -v "#" | awk '{ print $2 }' | xargs setfacl --remove-all