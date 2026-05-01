#!/bin/bash
# platform = SUSE Linux Enterprise 16

if [ -e "/etc/logrotate.conf" ] ; then
    rm "/etc/logrotate.conf"
fi
