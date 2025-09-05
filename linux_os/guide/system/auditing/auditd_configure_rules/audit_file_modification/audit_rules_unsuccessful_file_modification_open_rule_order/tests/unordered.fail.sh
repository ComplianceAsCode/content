#!/bin/bash

# remediation = none

# The rule without filter is less specific, and thus, catches more events than the more specific rules (with O_CREAT and O_TRUNC filters)
# If they rule withou filter is first, it will catch everything and rules below it will never trigger
grep -h 'arch=b32.*EACCES' $SHARED/audit_open.rules $SHARED/audit_open_o_creat.rules $SHARED/audit_open_o_trunc_write.rules > /etc/audit/rules.d/unordered.rules
grep -h 'arch=b32.*EPERM' $SHARED/audit_open.rules $SHARED/audit_open_o_creat.rules $SHARED/audit_open_o_trunc_write.rules >> /etc/audit/rules.d/unordered.rules
grep -h 'arch=b64.*EACCES' $SHARED/audit_open.rules $SHARED/audit_open_o_creat.rules $SHARED/audit_open_o_trunc_write.rules >> /etc/audit/rules.d/unordered.rules
grep -h 'arch=b64.*EPERM' $SHARED/audit_open.rules $SHARED/audit_open_o_creat.rules $SHARED/audit_open_o_trunc_write.rules >> /etc/audit/rules.d/unordered.rules
