#!/bin/bash
# packages = audit
# remediation = bash
# platform = Fedora,Red Hat Enterprise Linux 7,Red Hat Enterprise Linux 8

./generate_privileged_commands_rule.sh 1000 privileged /etc/audit/rules.d/privileged.rules
 sed -i '/newgrp/d' /etc/audit/rules.d/privileged.rules
