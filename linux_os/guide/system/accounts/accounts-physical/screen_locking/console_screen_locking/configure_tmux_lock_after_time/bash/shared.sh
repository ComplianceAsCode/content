# platform = multi_platform_all

tmux_conf="/etc/tmux.conf"

if grep -qP '^\s*set\s+-g\s+lock-after-time' "$tmux_conf" ; then
    sed -i 's/^\s*set\s\+-g\s\+lock-after-time.*$/set -g lock-after-time 900/' "$tmux_conf"
else
    echo "set -g lock-after-time 900" >> "$tmux_conf"
fi
chmod 0644 "$tmux_conf"
