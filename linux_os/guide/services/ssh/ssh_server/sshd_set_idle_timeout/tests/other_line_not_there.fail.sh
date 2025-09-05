#!/bin/bash
# platform = Oracle Linux 7,Red Hat Enterprise Linux 7
# remediation = none

# The rule doesn't remediate the ClientAliveCountMax setting, we have another rule for that.

sed -i "/^ClientAliveCountMax.*/d" /etc/ssh/sshd_config

