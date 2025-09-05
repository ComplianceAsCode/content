# platform = multi_platform_all

if grep -q 'tmux\s*$' /etc/shells ; then
	sed -i '/tmux\s*$/d' /etc/shells
fi
