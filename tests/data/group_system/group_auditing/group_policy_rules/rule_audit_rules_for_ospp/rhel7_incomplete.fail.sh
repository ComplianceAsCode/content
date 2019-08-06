#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp
# platform = Red Hat Enterprise Linux 7

cp /usr/share/doc/audit-*/rules/10-base-config.rules /etc/audit/rules.d
cp /usr/share/doc/audit-*/rules/11-loginuid.rules /etc/audit/rules.d
cp /usr/share/doc/audit-*/rules/43-module-load.rules /etc/audit/rules.d
