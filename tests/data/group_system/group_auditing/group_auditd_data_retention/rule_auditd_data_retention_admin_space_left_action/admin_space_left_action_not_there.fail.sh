#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_C2S
# remediation = bash

yum install -y audit

sed -i "/^admin_space_left_action[[:space:]]*=/d" /etc/audit/auditd.conf
