# platform = Red Hat Enterprise Linux 5
grep ^root: /etc/passwd | awk -F: ' { print $6 }' | xargs -I entry chmod g-rwx,o-rwx "entry"
