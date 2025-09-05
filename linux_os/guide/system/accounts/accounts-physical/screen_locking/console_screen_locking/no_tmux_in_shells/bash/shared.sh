# platform = multi_platform_all

if grep -q 'tmux$' /etc/shells ; then
	sed -i '/tmux$/d' /etc/shells
fi
