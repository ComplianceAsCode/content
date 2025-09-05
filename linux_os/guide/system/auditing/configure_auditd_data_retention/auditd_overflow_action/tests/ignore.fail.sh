#!/bin/bash
# Ensure test system has proper directories/files for test scenario
bash -x setup.sh

echo "overflow_action = ignore" >> /etc/audit/auditd.conf
