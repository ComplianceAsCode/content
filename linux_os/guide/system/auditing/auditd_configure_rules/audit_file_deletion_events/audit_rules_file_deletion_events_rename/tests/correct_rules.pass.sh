#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_pci-dss

echo "-a always,exit -F arch=b32 -S rename -F auid>=1000 -F auid!=4294967295 -F key=delete" >> /etc/audit/rules.d/delete.rules
echo "-a always,exit -F arch=b64 -S rename -F auid>=1000 -F auid!=4294967295 -F key=delete" >> /etc/audit/rules.d/delete.rules
