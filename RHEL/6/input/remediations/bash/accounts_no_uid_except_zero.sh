# platform = Red Hat Enterprise Linux 6
awk -F: '$3 == 0 && $1 != "root" { print $1 }' /etc/passwd | xargs passwd -l
