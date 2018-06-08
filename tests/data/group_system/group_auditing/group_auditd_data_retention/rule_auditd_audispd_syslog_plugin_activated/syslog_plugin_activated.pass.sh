#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_common

yum install -y audispd-plugins

. ../set_parameters_value.sh
set_parameters_value /etc/audisp/plugins.d/syslog.conf "active" "yes"
