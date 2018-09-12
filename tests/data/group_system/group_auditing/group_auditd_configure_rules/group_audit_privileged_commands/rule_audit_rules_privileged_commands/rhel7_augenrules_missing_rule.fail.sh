#!/bin/bash
# profiles = xccdf_org.ssgproject.content_profile_pci-dss
# remediation = bash

./generate_privileged_commands_rule.sh 1000 privileged /etc/audit/rules.d/privileged.rules
 sed -i '/newgrp/d' /etc/audit/rules.d/privileged.rules
# This is a trick to fail setup of this test in rhel6 systems
ls /usr/lib/systemd/system/auditd.service
