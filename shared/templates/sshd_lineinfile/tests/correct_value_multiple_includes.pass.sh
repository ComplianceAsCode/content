#!/bin/bash

# platform = Oracle Linux 8,Oracle Linux 9

mkdir -p /etc/ssh/sshd_config.d
touch /etc/ssh/sshd_config.d/nothing

{{{ bash_replace_or_append("/etc/ssh/sshd_config", "Include", "sshd_config.d/*.conf", "%s %s") }}}
echo "Include /etc/dummy" >> "/etc/ssh/sshd_config"

echo "{{{ PARAMETER }}} {{{ VALUE }}}" >> /etc/dummy
echo "{{{ PARAMETER }}} {{{ VALUE }}}" >> /etc/ssh/sshd_config.d/other.conf
