#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_C2S

rm -f /etc/audit/rules.d/*

# cut out irrelevant rules for this test
sed -e '11,18d' -e '/.*init.*/d' test_audit.rules > /etc/audit/rules.d/test.rules
