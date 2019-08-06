#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp
# platform = Red Hat Enterprise Linux 7

cp /usr/share/doc/audit-*/rules/10-base-config.rules /etc/audit/rules.d
cp /usr/share/doc/audit-*/rules/11-loginuid.rules /etc/audit/rules.d
# This file is not shipped, so we put it there ourselves
cp ./rhel7-30-ospp-v42.rules /etc/audit/rules.d/30-ospp-v42.rules
cp /usr/share/doc/audit-*/rules/43-module-load.rules /etc/audit/rules.d
