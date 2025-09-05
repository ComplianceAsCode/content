# platform = multi_platform_all

tmux_conf="/etc/tmux.conf"

if grep -qP '^\s*bind\s+\w\s+lock-session' "$tmux_conf" ; then
    sed -i 's/\s*bind\s\+\w\s\+lock-session.*$/bind X lock-session/' "$tmux_conf"
else
    echo "bind X lock-session" >> "$tmux_conf"
fi
chmod 0644 "$tmux_conf"
