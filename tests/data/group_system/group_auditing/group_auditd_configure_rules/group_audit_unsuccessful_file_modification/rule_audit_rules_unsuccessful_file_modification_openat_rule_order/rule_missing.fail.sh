#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_ospp
# remediation = none

cat ../audit_openat_o_creat.rules ../audit_openat_o_trunc_write.rules ../audit_open.rules > /etc/audit/rules.d/ordered_by_filter.rules
sed -i '2d' /etc/audit/rules.d/ordered_by_filter.rules
