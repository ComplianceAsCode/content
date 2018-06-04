#!/bin/bash
# profiles = profile_not_found
# remediation = bash

yum install -y audit audispd-plugins

DISK_FULL_ACTION_REGEX="^disk_full_action[[:space:]]*=.*$"
if grep -q "$DISK_FULL_ACTION_REGEX" /etc/audisp/audisp-remote.conf; then
        sed -i "s/$DISK_FULL_ACTION_REGEX/disk_full_action = stop/" /etc/audisp/audisp-remote.conf
else
        echo "disk_full_action = stop" >> /etc/audisp/audisp-remote.conf
fi
