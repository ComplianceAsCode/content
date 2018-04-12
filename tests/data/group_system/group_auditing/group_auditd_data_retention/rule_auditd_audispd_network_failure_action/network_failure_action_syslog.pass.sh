#!/bin/bash
# profiles = profile_not_found
# remediation = bash

yum install -y audit audispd-plugins

NETWORK_FAILURE_ACTION_REGEX="^network_failure_action[[:space:]]*=.*$"
if grep -q "$NETWORK_FAILURE_ACTION_REGEX" /etc/audisp/audisp-remote.conf; then
        sed -i "s/$NETWORK_FAILURE_ACTION_REGEX/network_failure_action = syslog/" /etc/audisp/audisp-remote.conf
else
        echo "network_failure_action = syslog" >> /etc/audisp/audisp-remote.conf
fi
