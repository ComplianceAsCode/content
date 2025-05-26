#!/bin/bash
# packages = chrony
if [ ! -f /etc/chrony.keys ]; then
    touch /etc/chrony.keys
fi
chgrp chrony /etc/chrony.keys
