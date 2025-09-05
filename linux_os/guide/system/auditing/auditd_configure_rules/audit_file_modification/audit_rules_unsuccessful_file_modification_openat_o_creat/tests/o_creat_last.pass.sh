#!/bin/bash

# remediation = none

sed 's/_by_handle_at/at/' $SHARED/audit_openat_o_creat.rules > /etc/audit/rules.d/openat_o_creat.rules
sed -i 's/openat,/open_by_handle_at,/' /etc/audit/rules.d/openat_o_creat.rules
