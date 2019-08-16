# platform = multi_platform_fedora,Red Hat Enterprise Linux 8,Oracle Linux 8

LINE='[ -n "$PS1" -a -z "$TMUX" ] && exec tmux'
if ! tail -1 /etc/bashrc | grep -x "$LINE" ; then
    echo "$LINE" >> /etc/bashrc
fi

