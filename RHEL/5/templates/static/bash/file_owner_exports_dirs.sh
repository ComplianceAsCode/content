# platform = Red Hat Enterprise Linux 5
cat /etc/exports | awk '{ print $1 }' | xargs chown root