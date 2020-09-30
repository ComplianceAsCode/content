#!/bin/bash
# remediation = bash
# platform = Red Hat Enterprise Linux 6

sed -i "s/USE_AUGENRULES=.*/USE_AUGENRULES=\"yes\"/" /etc/sysconfig/auditd
