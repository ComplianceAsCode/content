# platform = Red Hat Enterprise Linux 5
find / /home /var /var/log /var/log/audit -xdev -perm -2 ! -perm -1000 -type d 2>/dev/null | xargs chmod o-w
