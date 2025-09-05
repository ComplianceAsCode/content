# packages = tmux

tmux_conf="/etc/tmux.conf"
echo "set -g lock-after-time 901" > "$tmux_conf"
