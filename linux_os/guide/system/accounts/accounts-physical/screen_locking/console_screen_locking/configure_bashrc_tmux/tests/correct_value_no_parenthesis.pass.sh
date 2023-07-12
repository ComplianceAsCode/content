#!/bin/bash
# packages = tmux

cat >> /etc/bashrc <<'EOF'
if [ "$PS1" ]; then
  parent=$(ps -o ppid= -p $$)
  name=$(ps -o comm= -p $parent)
  case "$name" in sshd|login) tmux ;; esac
fi
EOF
