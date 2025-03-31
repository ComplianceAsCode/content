#!/bin/bash
# packages = chrony

# make sure the test passes also for locked groups
sed -ir 's/^chrony\:.*\:(.*)\:/chrony:!:\1/g' /etc/group
if [ ! -f /etc/chrony.keys ]; then
    touch /etc/chrony.keys
fi
chgrp chrony /etc/chrony.keys
