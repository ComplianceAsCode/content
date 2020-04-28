#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_C2S


rm -f /etc/audit/rules.d/*

# cut out irrelevant rules for this test
sed '1,10d' test_audit.rules > /etc/audit/rules.d/test.rules
sed -i '5,8d' /etc/audit/rules.d/test.rules
