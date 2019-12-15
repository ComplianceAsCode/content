#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_pci-dss

echo "-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=unset -k mount" >> /etc/audit/rules.d/mount.rules
echo "-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=unset -k mount" >> /etc/audit/rules.d/mount.rules
