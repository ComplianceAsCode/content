#!/bin/bash
# profiles = profile_not_found

yum install -y audit audispd-plugins

sed -i "/^remote_server[[:space:]]*=/d" /etc/audisp/audisp-remote.conf
