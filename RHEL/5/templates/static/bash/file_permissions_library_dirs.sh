# platform = Red Hat Enterprise Linux 5
find /lib /usr/lib -follow -perm -20 -o -perm -2 2>/dev/null | xargs chmod go-w
