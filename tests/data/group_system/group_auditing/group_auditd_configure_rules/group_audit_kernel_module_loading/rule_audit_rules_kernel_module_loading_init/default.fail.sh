#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp-rhel7
# remediation = bash

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules
true
