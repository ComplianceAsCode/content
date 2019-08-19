# platform = multi_platform_fedora,Red Hat Enterprise Linux 8,Oracle Linux 8

if grep -q 'tmux$' /etc/shells ; then
	sed -i '/tmux$/d' /etc/shells
fi
