# platform = Red Hat Enterprise Linux 5
sed -i 's/^.*:ctrlaltdel:.*\(shutdown\|reboot\).*/ca:nil:ctrlaltdel:\/usr\/bin\/logger -p security.info "Ctrl-Alt-Del was pressed"/' /etc/inittab
	