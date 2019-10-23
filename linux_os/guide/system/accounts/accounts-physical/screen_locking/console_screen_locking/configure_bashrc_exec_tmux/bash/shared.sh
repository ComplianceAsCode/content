# platform = multi_platform_fedora,Red Hat Enterprise Linux 8,Oracle Linux 8

if ! grep -x '  case "$name" in sshd|login) exec tmux ;; esac' /etc/bashrc; then
    cat >> /etc/bashrc <<'EOF'
if [ "$PS1" ]; then
  parent=$(ps -o ppid= -p $$)
  name=$(ps -o comm= -p $parent)
  case "$name" in sshd|login) exec tmux ;; esac
fi
EOF
fi
