#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp
touch "/etc/audit/auditd.conf"
sed -i "/local_events/d" "/etc/audit/auditd.conf"
