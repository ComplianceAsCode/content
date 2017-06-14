# platform = Red Hat Enterprise Linux 5
find / /home /var /var/log /var/log/audit -xdev -nouser 2>/dev/null | xargs chown root
