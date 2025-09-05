#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp
# remediation = bash
# platform = Red Hat Enterprise Linux 7,Fedora

mkdir -p /etc/audit/rules.d
rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules
