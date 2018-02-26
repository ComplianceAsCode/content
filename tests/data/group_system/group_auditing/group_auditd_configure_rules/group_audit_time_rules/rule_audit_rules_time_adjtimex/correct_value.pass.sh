#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_ospp-rhel7

if grep -qv "^[\s]*-a[\s]+always,exit[\s]+-F[\s]+arch=b32.*(-S[\s]+adjtimex[\s]+|([\s]+|[,])adjtimex([\s]+|[,])).*(-k[\s]+|-F[\s]+key=)[\S]+[\s]*$" /etc/audit/rules.d/*.rules; then
	echo "-a always,exit -F arch=b32 -S adjtimex -k audit_time_rules" >> /etc/audit/rules.d/time.rules
	echo "-a always,exit -F arch=b64 -S adjtimex -k audit_time_rules" >> /etc/audit/rules.d/time.rules
fi
