#!/bin/bash
# profiles = profile_not_found
# remediation = bash

yum install -y audit audispd-plugins

ENABLE_KRB5_REGEX="^enable_krb5[[:space:]]*=.*$"
if grep -q "$ENABLE_KRB5_REGEX" /etc/audisp/audisp-remote.conf; then
        sed -i "s/$ENABLE_KRB5_REGEX/enable_krb5 = no/" /etc/audisp/audisp-remote.conf
else
        echo "enable_krb5 = no" >> /etc/audisp/audisp-remote.conf
fi
