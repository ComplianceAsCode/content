#!/bin/bash

# platform = Oracle Linux 8,Oracle Linux 9

source common.sh

{{{ bash_replace_or_append("/etc/ssh/sshd_config", "Include", "sshd_config.d/*.conf", "%s %s", key_starts_with=false) }}}

echo "{{{ PARAMETER }}} {{{ VALUE }}}" >> /etc/ssh/sshd_config.d/other.conf
