#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_C2S
# remediation = bash

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules
true
