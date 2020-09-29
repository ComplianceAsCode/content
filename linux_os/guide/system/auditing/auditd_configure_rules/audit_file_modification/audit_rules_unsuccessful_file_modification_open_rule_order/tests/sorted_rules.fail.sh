#!/bin/bash

# remediation = none

cat $SHARED/audit_open_o_creat.rules $SHARED/audit_open_o_trunc_write.rules $SHARED/audit_open.rules > ./ordered_by_filter.rules
sort ./ordered_by_filter.rules > /etc/audit/rules.d/unsuccessful_open.rules
