#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_pci-dss
# remediation = bash

rm -f /etc/audit/rules.d/*
> /etc/audit/audit.rules
true
