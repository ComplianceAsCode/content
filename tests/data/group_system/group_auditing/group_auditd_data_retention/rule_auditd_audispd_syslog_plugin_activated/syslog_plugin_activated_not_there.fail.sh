#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_common
# remediation = bash

yum install -y audit audispd-plugins

sed -i "/^active[[:space:]]*=/d" /etc/audisp/plugins.d/syslog.conf
