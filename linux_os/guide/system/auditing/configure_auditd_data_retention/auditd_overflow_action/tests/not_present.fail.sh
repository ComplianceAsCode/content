#!/bin/bash
# Ensure test system has proper directories/files for test scenario
bash -x setup.sh
config_file=/etc/audit/auditd.conf
sed -i "s/^.*overflow_action.*$//" $config_file
