#!/bin/bash

cp $SHARED/fstab /etc/
{{{ bash_systemctl_daemon_reload() }}}
