# platform = multi_platform_fedora,Red Hat Enterprise Linux 8,Oracle Linux 8

tmux_conf="/etc/tmux.conf"

if grep -qP '^\s*set\s+-g\s+lock-after-time' "$tmux_conf" ; then
    sed -i 's/^\s*set\s\+-g\s\+lock-after-time.*$/set -g lock-after-time 900/' "$tmux_conf"
else
    echo "set -g lock-after-time 900" >> "$tmux_conf"
fi

