#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel
# variables = var_sudo_umask=0027

# Default umask is not explicitly set and has value 0022
# Make sure umask is not set in /etc/sudoers
sed -i /umask/d /etc/sudoers
