#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_ospp

cp /usr/share/doc/audit*/rules/10-base-config.rules /etc/audit/rules.d
cp /usr/share/doc/audit*/rules/11-loginuid.rules /etc/audit/rules.d
cp /usr/share/doc/audit*/rules/30-ospp-v42.rules /etc/audit/rules.d
echo "test fail" >> /etc/audit/rules.d/30-ospp-v42.rules
cp /usr/share/doc/audit*/rules/43-module-load.rules /etc/audit/rules.d
