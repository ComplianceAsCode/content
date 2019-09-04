#!/bin/bash

# profiles = xccdf_org.ssgproject.content_profile_ospp
# remediation = none

sed 's/_by_handle_at//' $SHARED/audit_open.rules > /etc/audit/rules.d/open_o_creat.rules
sed -i 's/open,/open_by_handle_at,/' /etc/audit/rules.d/open_o_creat.rules
