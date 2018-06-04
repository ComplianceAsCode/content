#!/bin/bash
# profiles = profile_not_found

yum install -y audispd-plugins

. ../set_parameters_value.sh
set_parameters_value /etc/audisp/audisp-remote.conf "remote_server" "10.10.10.10"
