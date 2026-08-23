# platform = multi_platform_all

tmux_conf="/etc/tmux.conf"

if ! grep -qP '^\s*bind\s+\w\s+lock-session' "$tmux_conf" ; then
    echo "bind X lock-session" >> "$tmux_conf"
fi
chmod 0644 "$tmux_conf"
