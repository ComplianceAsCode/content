#!/bin/bash

cp $SHARED/fstab /etc/
sed -i 's|\(.*nfs4.*\),noexec\(.*\)|\1\2|' /etc/fstab
{{{ bash_systemctl_daemon_reload() }}}
