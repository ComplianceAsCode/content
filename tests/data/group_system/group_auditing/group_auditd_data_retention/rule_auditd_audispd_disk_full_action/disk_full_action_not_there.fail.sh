#!/bin/bash
# profiles = profile_not_found
# remediation = bash

yum install -y audit audispd-plugins

sed -i "/^disk_full_action[[:space:]]*=.*$/d" /etc/audisp/audisp-remote.conf
