#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel
# variables = var_sudo_umask=0027

echo "Defaults use_pty,umask=0022,noexec" >> /etc/sudoers

