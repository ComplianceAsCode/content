#!/bin/bash

cp $SHARED/fstab /etc/
sed -i '/nfs/d' /etc/fstab
{{{ bash_systemctl_daemon_reload() }}}
