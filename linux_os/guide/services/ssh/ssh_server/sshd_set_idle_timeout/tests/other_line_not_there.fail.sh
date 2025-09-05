#!/bin/bash
# remediation = none

# The rule doesn't remediate the ClientAliveCountMax setting, we have another rule for that.

sed -i "/^ClientAliveInterval.*/d" /etc/ssh/sshd_config

