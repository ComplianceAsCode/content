#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_ospp
# remediation = none

sed 's/openat,open_by_handle_at/open,open_by_handle_at/' ../audit_open.rules > /etc/audit/rules.d/open_o_creat.rules
sed -i 's/ open,/ openat,/' /etc/audit/rules.d/open_o_creat.rules
