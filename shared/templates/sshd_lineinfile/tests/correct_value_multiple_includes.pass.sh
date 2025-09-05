#!/bin/bash

# platform = Oracle Linux 8,Oracle Linux 9

source common.sh

{{{ bash_replace_or_append("/etc/ssh/sshd_config", "   InCLude", "sshd_config.d/*.conf", "%s %s") }}}
echo "   INclUde /etc/dummy" >> "/etc/ssh/sshd_config"

echo "{{{ PARAMETER }}} {{{ VALUE }}}" >> /etc/dummy
echo "{{{ PARAMETER }}} {{{ VALUE }}}" >> /etc/ssh/sshd_config.d/other.conf
