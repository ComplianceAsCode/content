#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_ospp
# remediation = none

cat ../audit_openat_o_creat.rules ../audit_openat_o_trunc_write.rules ../audit_open.rules > ./ordered_by_filter.rules
sort ./ordered_by_filter.rules > /etc/audit/rules.d/unsuccessful_open.rules
