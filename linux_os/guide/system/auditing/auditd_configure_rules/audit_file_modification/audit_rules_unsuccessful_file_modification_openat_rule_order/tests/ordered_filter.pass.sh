#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_ospp
# remediation = none

cat $SHARED/audit_openat_o_creat.rules $SHARED/audit_openat_o_trunc_write.rules $SHARED/audit_open.rules > /etc/audit/rules.d/ordered_by_filter.rules
