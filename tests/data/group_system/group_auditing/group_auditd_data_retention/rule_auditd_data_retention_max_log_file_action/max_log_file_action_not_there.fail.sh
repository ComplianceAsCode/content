#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_common

yum install -y audit

sed -i "/^max_log_file_action[[:space:]]*=/d" /etc/audit/auditd.conf
