#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_common
# remediation = bash

yum install -y audispd-plugins

. ../delete_parameter.sh
delete_parameter /etc/audisp/plugins.d/syslog.conf "active"
