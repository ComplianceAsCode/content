# platform = Red Hat Enterprise Linux 5
grep "/" /etc/aliases /etc/aliases.db | grep -v "#" | grep ^/ | sed 's/.*[\s|\t]\//\//' | xargs chown root