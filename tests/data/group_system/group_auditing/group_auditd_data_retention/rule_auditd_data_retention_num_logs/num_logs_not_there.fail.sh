#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_common

. ../delete_parameter.sh

delete_parameter /etc/audit/auditd.conf "num_logs"
