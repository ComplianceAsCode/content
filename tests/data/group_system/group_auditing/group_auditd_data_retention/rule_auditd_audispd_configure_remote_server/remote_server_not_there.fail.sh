#!/bin/bash
# profiles = profile_not_found

yum install -y audispd-plugins

. ../delete_parameter.sh
delete_parameter /etc/audisp/audisp-remote.conf "remote_server"
