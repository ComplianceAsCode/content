find / /home /var /var/log /var/log/audit -xdev -perm -2 ! -perm -1000 -type d 2>/dev/null | xargs chmod o-w
