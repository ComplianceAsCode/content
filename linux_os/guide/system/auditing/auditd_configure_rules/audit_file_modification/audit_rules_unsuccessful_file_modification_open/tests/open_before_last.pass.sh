#!/bin/bash

# remediation = none

sed 's/openat,open_by_handle_at/open,open_by_handle_at/' $SHARED/audit_open.rules > /etc/audit/rules.d/open_o_creat.rules
sed -i 's/ open,/ openat,/' /etc/audit/rules.d/open_o_creat.rules
