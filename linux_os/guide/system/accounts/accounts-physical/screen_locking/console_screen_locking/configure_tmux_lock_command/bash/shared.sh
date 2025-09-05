# platform = Oracle Linux 8,Red Hat Enterprise Linux 8,Red Hat Virtualization 4,multi_platform_fedora

tmux_conf="/etc/tmux.conf"

if grep -qP '^\s*set\s+-g\s+lock-command' "$tmux_conf" ; then
    sed -i 's/^\s*set\s\+-g\s\+lock-command.*$/set -g lock-command vlock/' "$tmux_conf"
else
    echo "set -g lock-command vlock" >> "$tmux_conf"
fi

