#!/bin/bash

# remediation = none

sed '3,4d' $SHARED/audit_openat_o_trunc_write.rules > /etc/audit/rules.d/openat-o_trunc_write.rules
