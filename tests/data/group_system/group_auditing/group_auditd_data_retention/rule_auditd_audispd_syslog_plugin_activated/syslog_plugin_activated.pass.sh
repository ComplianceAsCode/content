#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_common

yum install -y audit audispd-plugins

ACTIVE_REGEX="^active[[:space:]]*=.*$"
if grep -q "$ACTIVE_REGEX" /etc/audisp/plugins.d/syslog.conf; then
        sed -i "s/$ACTIVE_REGEX/active = yes/" /etc/audisp/plugins.d/syslog.conf
else
        echo "active = yes" >> /etc/audisp/plugins.d/syslog.conf
fi
