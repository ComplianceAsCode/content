#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp
echo "local_events = yes" > "/etc/audit/auditd.conf"
echo "local_events = no" >> "/etc/audit/auditd.conf"
