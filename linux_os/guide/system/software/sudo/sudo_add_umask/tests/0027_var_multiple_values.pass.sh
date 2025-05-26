#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel,multi_platform_almalinux
# variables = var_sudo_umask=0027

echo "Defaults use_pty,umask=0027,noexec" >> /etc/sudoers

