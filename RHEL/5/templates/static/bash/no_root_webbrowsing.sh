# platform = Red Hat Enterprise Linux 5
rm -rf `grep ^root: /etc/passwd | awk -F: '{ print $6 }'`/.mozilla