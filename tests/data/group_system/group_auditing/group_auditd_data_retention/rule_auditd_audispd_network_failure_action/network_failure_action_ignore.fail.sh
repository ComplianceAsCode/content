#!/bin/bash
# profiles = profile_not_found
# remediation = bash

yum install -y audispd-plugins

. ../set_parameters_value.sh
set_parameters_value /etc/audisp/audisp-remote.conf "network_failure_action" "ignore"
