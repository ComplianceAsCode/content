# platform = Red Hat Enterprise Linux 5
egrep "(\*.crit|mail\.[^n][^/]*)" /etc/syslog.conf | sed 's/^[^/]*//' | xargs setfacl --remove-all