# platform = multi_platform_all
# reboot = true
# strategy = enable
# complexity = low
# disruption = low

if ! grep -x '  case "$name" in sshd|login) tmux ;; esac' /etc/bashrc /etc/profile.d/*.sh; then
    cat >> /etc/profile.d/tmux.sh <<'EOF'
if [ "$PS1" ]; then
  parent=$(ps -o ppid= -p $$)
  name=$(ps -o comm= -p $parent)
  case "$name" in sshd|login) tmux ;; esac
fi
EOF
    chmod 0644 /etc/profile.d/tmux.sh
fi
