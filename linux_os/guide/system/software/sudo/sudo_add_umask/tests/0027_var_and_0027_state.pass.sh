#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel
# variables = var_sudo_umask=0027

# Default umask is not explicitly set and has value 0022
echo "Defaults umask=0027" >> /etc/sudoers
