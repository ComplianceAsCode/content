#!/bin/bash
# platform = Oracle Linux 8,multi_platform_rhel,multi_platform_fedora
# packages = tmux

echo 'bind X lock-session' >> '/etc/tmux.conf'
chmod 0644 "/etc/tmux.conf"
