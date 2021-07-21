#!/bin/bash
# Ensure test system has proper directories/files for test scenario
bash -x setup.sh

touch /etc/audit/auditd.conf
