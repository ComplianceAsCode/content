#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_ospp
# remediation = none

sed '3,4d' ../audit_openat_o_trunc_write.rules > /etc/audit/rules.d/openat-o_trunc_write.rules
