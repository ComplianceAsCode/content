#!/bin/bash

cp $SHARED/fstab /etc/
sed -i 's/,noexec//' /etc/fstab
{{{ bash_systemctl_daemon_reload() }}}
