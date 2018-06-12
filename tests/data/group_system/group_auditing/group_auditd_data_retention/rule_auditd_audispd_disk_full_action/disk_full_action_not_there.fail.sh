#!/bin/bash
# profiles = profile_not_found
# remediation = bash

yum install -y audispd-plugins

. ../delete_parameter.sh
delete_parameter /etc/audisp/audisp-remote.conf "disk_full_action"
