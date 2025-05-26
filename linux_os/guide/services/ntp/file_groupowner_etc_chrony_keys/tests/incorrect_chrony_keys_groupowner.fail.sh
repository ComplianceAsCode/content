#!/bin/bash
# packages = chrony
groupadd group_test
if [ ! -f /etc/chrony.keys ]; then
    touch /etc/chrony.keys
fi
chgrp group_test /etc/chrony.keys
