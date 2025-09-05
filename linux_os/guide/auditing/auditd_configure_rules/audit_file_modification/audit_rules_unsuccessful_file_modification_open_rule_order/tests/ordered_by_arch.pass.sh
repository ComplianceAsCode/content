#!/bin/bash
# packages = audit

# remediation = none

grep -h 'arch=b32.*EACCES' $SHARED/audit_open_o_creat.rules $SHARED/audit_open_o_trunc_write.rules $SHARED/audit_open.rules > /etc/audit/rules.d/ordered_by_arch_error.rules
grep -h 'arch=b32.*EPERM' $SHARED/audit_open_o_creat.rules $SHARED/audit_open_o_trunc_write.rules $SHARED/audit_open.rules >> /etc/audit/rules.d/ordered_by_arch_error.rules
grep -h 'arch=b64.*EACCES' $SHARED/audit_open_o_creat.rules $SHARED/audit_open_o_trunc_write.rules $SHARED/audit_open.rules >> /etc/audit/rules.d/ordered_by_arch_error.rules
grep -h 'arch=b64.*EPERM' $SHARED/audit_open_o_creat.rules $SHARED/audit_open_o_trunc_write.rules $SHARED/audit_open.rules >> /etc/audit/rules.d/ordered_by_arch_error.rules
