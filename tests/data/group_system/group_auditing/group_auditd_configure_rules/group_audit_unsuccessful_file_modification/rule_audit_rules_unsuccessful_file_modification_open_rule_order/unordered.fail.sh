#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_ospp
# remediation = none

# Puts rule without filter first
grep -h 'arch=b32.*EACCES' ../audit_open.rules ../audit_open_o_creat.rules ../audit_open_o_trunc_write.rules > /etc/audit/rules.d/unordered.rules
grep -h 'arch=b32.*EPERM' ../audit_open.rules ../audit_open_o_creat.rules ../audit_open_o_trunc_write.rules >> /etc/audit/rules.d/unordered.rules
grep -h 'arch=b64.*EACCES' ../audit_open.rules ../audit_open_o_creat.rules ../audit_open_o_trunc_write.rules >> /etc/audit/rules.d/unordered.rules
grep -h 'arch=b64.*EPERM' ../audit_open.rules ../audit_open_o_creat.rules ../audit_open_o_trunc_write.rules >> /etc/audit/rules.d/unordered.rules
