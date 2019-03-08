#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_ospp
# remediation = none

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules
true
