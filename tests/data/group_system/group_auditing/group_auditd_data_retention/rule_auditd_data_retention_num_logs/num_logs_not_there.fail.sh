#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_common

yum install -y audit

sed -i "/^num_logs[[:space:]]*=/d" /etc/audit/auditd.conf
