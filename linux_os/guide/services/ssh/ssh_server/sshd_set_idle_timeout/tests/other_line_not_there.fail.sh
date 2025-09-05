#!/bin/bash
# platform = Red Hat Enterprise Linux 7
# remediation = none

# The rule doesn't remediate the ClientAliveCountMax setting, we have another rule for that.

sed -i "/^ClientAliveCountMax.*/d" /etc/ssh/sshd_config

