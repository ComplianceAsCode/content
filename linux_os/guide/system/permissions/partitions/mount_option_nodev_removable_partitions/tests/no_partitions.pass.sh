#!/bin/bash

touch /dev/cdrom
echo "" > /etc/fstab
{{{ bash_systemctl_daemon_reload() }}}
