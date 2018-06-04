#!/bin/bash
# profiles = profile_not_found
# remediation = bash

yum install -y audit audispd-plugins

sed -i "/^network_failure_action[[:space:]]*=.*$/d" /etc/audisp/audisp-remote.conf
